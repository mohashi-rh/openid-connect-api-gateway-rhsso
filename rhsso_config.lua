
-- Set your RH SSO configuration below: 
local server = "http://192.168.100.1:8180"
local realm = "demo"
local initial_access_token = "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJiZTZiYmI0NC1hNzM3LTQ2YzQtYjlmNi0zZGI2MzlkN2I5MjEiLCJleHAiOjAsIm5iZiI6MCwiaWF0IjoxNDg3NjIxMDM0LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgxODAvYXV0aC9yZWFsbXMvZGVtbyIsImF1ZCI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODE4MC9hdXRoL3JlYWxtcy9kZW1vIiwidHlwIjoiSW5pdGlhbEFjY2Vzc1Rva2VuIn0.fgBr3DlPo6KAXiqIvnr-oW1KNuPyD7C-LII-5KOLoGJZ9wxXu95Gi62ncTAjkEH5ZofHLmHegScZnPOMkHiyGkYej5ChbFsdhyptOYCkXfmTL5I3d_uXvbm4K9By44Y7AyMC7isej4ihld8THTVS-9j63AYk3CVixfwA0BVHshbV9pVzGB-kg5JCb5anZiQgcrD_Lf0CA48IGaKON6TTPGSZ19gcq4SVbJ4YVKACD2c14REoyzu0cRQZjiHEX2v_gODC3VenerYj0tI8LLiw1tUCZGt4GsSpX1G83TGxudxMjapJK8HCmLF0cf_aMEy024yMO3NIEPXtxaziISQydA"
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