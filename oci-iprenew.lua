require 'sh'
json = require 'dkjson'

local res = shout 'oci iam availability-domain list'

print(res)
if res then
  print(json.decode(res))
end
