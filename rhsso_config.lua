
-- Set your RH SSO configuration below: 
local server = "https://192.168.100.1:8180"
local realm = "demo"
local initial_access_token = "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiIyZjBjMGIyOC1jNTMyLTQ0OTQtOWEwYy1kMjU3YjMyNzhhZmQiLCJleHAiOjAsIm5iZiI6MCwiaWF0IjoxNDg3NTk0MTg5LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgxODAvYXV0aC9yZWFsbXMvZGVtbyIsImF1ZCI6Imh0dHA6Ly9sb2N9hbGhvc3Q6ODE4MC9hdXRoL3JlYWxtcy9kZW1vIiwidHlwIjoiSW5pdGlhbEFjY2Vzc1Rva2VuIn0.wR5Qysd5iRnps0zaHihVoCeduiHLCjmE8E-mVwJ_OWZXaVOI4rvgPPfmnQuBjPNGzu1DVFLWeHc6f5zaBhWA_HBZ6Z2tLqF9BhcUYB6HFim75Q69o4tq_i9bYd5_-Idi4Sb_4DJ68H-i-H-a4OTDRYPqSvNuXcRl-KQ89QBHvR6VSOL0X887mB1lN9WyIa-5sQlBfIv2Q_qg9jglLLveR5gYRd9o6JJyirTq7_BRHj11h97bfICadSAEKPeI_wS3r-OAOxbsbAB2w9hlM2lp-w5TfhgDJO5xiOVpeoTFgAYMCUP_GpV0UKe7_-q5Eao5iGyezQKZNTaVywulvKcdCA"
local public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzJKTLDNkButPJvXlutLICqB6E2PxoEentwXIEIrxZUNuJ+wg/2Ozyam+Uq0qIsHDTAXbPAKsq84W/rDDTZqRIGSUQWvo/s46GjdmSayicM1xuyWheow+4UokBshxtuAQXbhbMF5AJ+Fo7ZtMH5/2/MJE0AdxSZMdZPWst93zXjjetGoSE5DDR8gsX69YCrYchuq36+6mmFX5F1wGNSXM4EhMSV9vHSfLoogljRj87wCvWfeDQzsxN//69cxHdjjZ31f7t1AFsolHK5mptKdsEr49htWNVW8Fc00IR+LprlaI6ETTVVu/bj9e6D2/MMhP6csqhXGngsIBDPEV5FK1MwIDAQAB"


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