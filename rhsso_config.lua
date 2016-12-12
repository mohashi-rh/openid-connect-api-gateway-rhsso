
-- Set your RH SSO configuration below: 
local server = "https://CHANGE_ME_RED_HAT_SSO_SERVER:8443"
local realm = "CHANGE_ME_REALM"
local initial_access_token = "CHANGE_ME_INITIAL_ACCESS_TOKEN"
local public_key = "CHANGE_ME_PUBLIC_KEY"


local function format_public_key(key)
  local formatted_key = "-----BEGIN PUBLIC KEY-----\n"
  local len = string.len(key)
  for i=1,len,64 do
    formatted_key = formatted_key..string.sub(key, i, i+63).."\n"
  end
  formatted_key = formatted_key.."-----END PUBLIC KEY-----"
  return formatted_key
end

return {
  server = server,
  authorize_url = server..'/auth/realms/'..realm..'/protocol/openid-connect/auth',
  token_url = server..'/auth/realms/'..realm..'/protocol/openid-connect/token',
  client_registrations_url = server..'/auth/realms/'..realm..'/clients-registrations/default',
  initial_access_token = initial_access_token,
  public_key = format_public_key(public_key)
}