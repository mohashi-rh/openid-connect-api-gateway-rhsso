local ts = require 'threescale_utils'
local jwt = require 'resty.jwt'
local rhsso = require 'rhsso_config'

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

local function error_jwt_verification_failed(service, reason)
  ngx.status = service.auth_failed_status
  ngx.header.content_type = service.auth_failed_headers
  ngx.print(service.error_auth_failed .. ': '.. reason)
  ngx.exit(ngx.HTTP_OK)
end

-- Parses the token - in this case we assume it's a JWT token
-- Here we can extract authenticated user's claims or other information returned in the access_token
-- or id_token by RH SSO
local function parse_and_verify_token(service, jwt_token)
  local jwt_obj = jwt:verify(rhsso.public_key, jwt_token)
  if not jwt_obj.verified then
    ngx.log(ngx.INFO, "[jwt] failed verification for token: "..jwt_token)
    error_jwt_verification_failed(service, jwt_obj.reason)
  end
  return jwt_obj
end

-- Check client_id against 3scale
local function check_client_id(params)
  local args = { 
    app_id = params.client_id
  }
  local res = ngx.location.capture("/_threescale/check_credentials", { args = args })
  local ok = res.status == 200
  return ok, res
end

local function oauth_error(error_description)
  ngx.status = 401
  ngx.header.content_type = "application/json; charset=utf-8"
  ngx.print('{"error":"invalid_request","error_description":"'..error_description..'"}')
  ngx.exit(ngx.HTTP_OK)
end

function _M.authorize()
  local params = ngx.req.get_uri_args()

  -- Check client_id against 3scale
  local ok, res = check_client_id(params)

  if not ok then
    oauth_error(res.body)
  end
end

function _M.get_token()
  local params = extract_params()

  -- Check Client ID against 3scale
  local ok, res = check_client_id(params)

  if not ok then
    oauth_error(res.body)
  end
end

function _M.get_credentials_from_token(service)
  -- As per RFC6750 (https://tools.ietf.org/html/rfc6750) the access_token is extracted from (in this order):
  -- 1) Authorization header if Bearer scheme is used
  -- 2) request body if content-type is application/x-www-form-urlencoded
  -- 3) URI query parameter

  local access_token

  if ngx.var.http_authorization then
    access_token = string.match(ngx.var.http_authorization, "^Bearer%s*(.*)$")
  end

  if not access_token and ngx.var.http_content_type == "application/x-www-form-urlencoded" then
    ngx.req.read_body()
    access_token = ngx.req.get_post_args().access_token
  end

  if not access_token then
    access_token = ngx.req.get_uri_args().access_token
  end

  if not access_token then
    return { access_token = nil }
  end

  -- Parse the JWT token, validate it and extract client_id from it
  local jwt_obj = parse_and_verify_token(service, access_token)
  local client_id = jwt_obj.payload.aud

  -- NOTE: the credentials of the application extracted and used for authenticating in 3scale is client_id (app_id), 
  -- however it is referred to as access_token to allow reusing most of the nginx_XXXX.lua code
  return { access_token = client_id }
end

return _M
