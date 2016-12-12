local ts = require 'threescale_utils'
local jwt = require "resty.jwt"

_M = {}

local errors = {}

-- As per RFC for Authorization Code flow: extract params from Authorization header and body
-- If implementation deviates from RFC, this function should be over-ridden
local function extract_params()
  local params = {}
  local header_params = ngx.req.get_headers()

  params.authorization = {}

  if header_params['Authorization'] then
    params.authorization = ngx.decode_base64(header_params['Authorization']:split(" ")[2]):split(":")
  end
  
  ngx.req.read_body()
  local body_params = ngx.req.get_post_args()
  
  params.client_id = params.authorization[1] or body_params.client_id
  params.client_secret = params.authorization[2] or body_params.client_secret
  
  params.grant_type = body_params.grant_type 
  params.redirect_uri = body_params.redirect_uri or body_params.redirect_url 

  if params.grant_type == "refresh_token" then
    params.refresh_token = body_params.refresh_token 
  else
    params.code = body_params.code  
  end

  return params
end

-- Calls the token endpoint to request a token
local function request_token()
  local res = ngx.location.capture("/_oauth/token", { method = ngx.HTTP_POST, copy_all_vars = true })
  return { ["status"] = res.status, ["body"] = res.body }
end

local function error_jwt_verification_failed(service)
  ngx.status = service.auth_missing_status
  ngx.header.content_type = service.auth_missing_headers
  ngx.print(service.error_auth_missing)
  ngx.exit(ngx.HTTP_OK)
end

-- Parses the token - in this case we assume it's a JWT token
-- Here we can extract authenticated user's claims or other information returned in the access_token
-- or id_token by RH SSO
local function parse_token(token)
  local token_obj = cjson.decode(token)
  
  local jwt_token = token_obj.access_token
  local header, body, signature = jwt_token:match("([^.]+).([^.]+).([^.]+)")

  -- Parse the JWT body to extract user's claims
  local payload = cjson.decode(ngx.decode_base64(body))

  return token_obj
end

-- Stores the token in 3scale. You can change the default ttl value of 604800 seconds (7 days) to your desired ttl.
local function store_token(params, token)
  local body = ts.build_query({ app_id = params.client_id, token = token.access_token, user_id = params.user_id, ttl = token.expires_in })
  local stored = ngx.location.capture( "/_threescale/oauth_store_token", { method = ngx.HTTP_POST, body = body } )
  stored.body = stored.body or stored.status
  return { ["status"] = stored.status , ["body"] = stored.body }
end

-- Returns the token to the client
local function send_token(token)
  ngx.header.content_type = "application/json; charset=utf-8"
  ngx.say(cjson.encode(token))
  ngx.exit(ngx.HTTP_OK)
end

-- Get the token from the OAuth Server
local function get_token_idp(params)
  local access_token_required_params = {'client_id', 'client_secret', 'grant_type', 'code', 'redirect_uri'}
  local refresh_token_required_params =  {'client_id', 'client_secret', 'grant_type', 'refresh_token'}

  local res = {}

  if (ts.required_params_present(access_token_required_params, params) and params['grant_type'] == 'authorization_code') or 
    (ts.required_params_present(refresh_token_required_params, params) and params['grant_type'] == 'refresh_token') then
    res = request_token(params)
  else
    res = { ["status"] = 403, ["body"] = '{"error": "invalid_request"}' }
  end

  if res.status ~= 200 then
    ngx.status = res.status
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.print(res.body)
    ngx.exit(ngx.HTTP_FORBIDDEN)
  else
    local token = parse_token(res.body)
    local stored = store_token(params, token)
    
    if stored.status ~= 200 then
      ngx.log(ngx.ERR, 'The token provided by RH-SSO could not be stored in 3scale backend')
      ngx.status = stored.status
      ngx.say('{"error":"'..stored.body..'"}')
      ngx.exit(ngx.HTTP_OK)
    else
      ngx.log(ngx.INFO, 'The token provided by RH-SSO saved successfully in 3scale backend')
      send_token(token)
    end
  end
end

-- Check valid params ( client_id / secret / redirect_url, whichever are sent) against 3scale
local function check_client_credentials(params)

  local args = { 
    app_id = params.client_id,
    redirect_url = params.redirect_uri 
  }
  if (params.client_secret) then
    args.app_key = params.client_secret
  end

  local res = ngx.location.capture("/_threescale/check_credentials", { args = args })
  local ok = res.status == 200
  return ok, res
end

function _M.authorize()
  local params = ngx.req.get_uri_args()

  -- Check Client ID and redirect URL against 3scale
  local ok, res = check_client_credentials(params)

  if not ok then
    ngx.status = res.status
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.print('{"error":"'..res.body..'"}')
    ngx.exit(ngx.HTTP_OK)
  end
end

function _M.get_token()
  local params = extract_params()

  -- Check Client ID, Client Secret and redirect URL against 3scale
  local is_valid = check_client_credentials(params)

  if is_valid then
    -- Get token through RH-SSO
    get_token_idp(params)
  else
    ngx.status = 401
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.print('{"error":"invalid_client"}')
    ngx.exit(ngx.HTTP_OK)
  end
end

return _M
