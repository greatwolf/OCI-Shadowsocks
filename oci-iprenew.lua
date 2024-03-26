require 'sh'
json = require 'dkjson'

function oci(...)
  local cmd = table.concat({'oci', ...}, ' ')
  local result = assert(shout(cmd))
  return json.decode(result)
end
function dump(t, indent)
  indent = indent or 0
  local ws = string.rep(' ', indent) .. '%s'
  local kv = "  %s = %s"
  print (ws:format'{')
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(ws:format("  " .. k .. " = "))
      dump(v, indent + 2)
    else
      print(ws:format(kv:format(k, v))
    end
  end
  print (ws:format'}')
end

-- get compartment-id & availability-domain
local res = oci 'iam availability-domain list'.data[1]
local compartmentid = res["compartment-id"]
local availdomain   = res.name

print(compartmentid, availdomain)

-- get publicip ocid + address & privateip ocid
res = oci('network public-ip list',
          '--compartment-id', compartmentid,
          '--scope AVAILABILITY_DOMAIN',
          '--availability-domain', availdomain,
          '--lifetime', 'EPHEMERAL')
dump(res)

-- unassign current publicip w/o prompting
-- oci network public-ip delete --force --public-ip-id ocid1.publicip.oc1.ap-osaka-1.amaaaaaawl5wgbqaor6wq2a3ukag4cyvuta4xypphsk4ipxmol7367vkjqpq

-- reassign new publicip
-- oci network public-ip create --compartment-id ocid1.tenancy.oc1..aaaaaaaagyi66dc4o2cawmj4fclkpffuc6igwpx5aqh34mrcyx6qof6trs7a --lifetime EPHEMERAL --private-ip-id ocid1.privateip.oc1.ap-osaka-1.abvwsljrnpnujpkuzbdmem22noq6ik4bhhvoxi3xemisl6f2mji6xisk3qna --debug