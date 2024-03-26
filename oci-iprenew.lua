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
      print(ws:format(kv:format(k, v)))
    end
  end
  print (ws:format'}')
end

-- get compartment-id & availability-domain
local res = oci 'iam availability-domain list'.data[1]
local compartmentid = res["compartment-id"]
local availdomain   = res.name

-- get publicip ocid + address & privateip ocid
res = oci('network public-ip list',
          '--compartment-id', compartmentid,
          '--scope AVAILABILITY_DOMAIN',
          '--availability-domain', availdomain,
          '--lifetime', 'EPHEMERAL').data[1]
local publicocid = res.id
local privateocid = res['private-ip-id']
dump(res)

-- unassign current publicip w/o prompting
oci('network public-ip delete',
    '--force',
    '--public-ip-id', publicocid)

-- reassign new publicip
res = oci('network public-ip create',
          '--compartment-id', compartmentid,
          '--lifetime', 'EPHEMERAL',
          '--private-ip-id', privateocid)
dump(res)
