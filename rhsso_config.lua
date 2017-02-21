
-- Set your RH SSO configuration below: 
local server = "https://192.168.100.1:8543"
local realm = "demo"
local initial_access_token = "eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI5YzUwMjUzNS00N2Y0LTRhYTYtODg4OC0yODk3YzNiYzg5ZDAiLCJleHAiOjAsIm5iZiI6MCwiaWF0IjoxNDg3NjQ1NDU4LCJpc3MiOiJodHRwczovLzE5Mi4xNjguMTAwLjE6ODU0My9hdXRoL3JlYWxtcy9kZW1vIiwiYXVkIjoiaHR0cHM6Ly8xOTIuMTY4LjEwMC4xOjg1NDMvYXV0aC9yZWFsbXMvZGVtbyIsInR5cCI6IkluaXRpYWxBY2Nlc3NUb2tlbiJ9.Q9Kk5hGK7qImByB65aOo9n1STOJ5r1qQsP_fBkrZukrK6POCfj9r0QlgOvL8geFKpoPo2zoy_ZpPiIdekQt1JLblv0ihTCdEHf-oHadFSqd0AtE8o8PVa_3HwGWmjt1B4PgZipDFpPvmm7CCM6Annsqx_JU5mOwM_E0YAXN2PphkXSRzEv39WvI5XYOh0YfGfO235rM-CsJvtBJVFPEh2iifwdteWvI4UT1TwhdZGQ6MalNZ6jLxaD3SMHpFQ_HhXEd1EcQEARYxWU07i1G_KZ_BTXLrR-PskU2MKvVsMn7aVP5-7plhoCWvn7m2JQMXEDD1T_B-YvZYIvVlLRXprQ"
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