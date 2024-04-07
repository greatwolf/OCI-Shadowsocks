require 'util.sh'
require 'util.oci'
require 'util.dump'
json = require 'dkjson'

-- get compartment-id & availability-domain
local res = oci 'iam availability-domain list'
local compartmentid = res["compartment-id"]
local availdomain   = res.name

-- get publicip ocid + address & privateip ocid
res = oci('network public-ip list',
          '--compartment-id', compartmentid,
          '--scope AVAILABILITY_DOMAIN',
          '--availability-domain', availdomain,
          '--lifetime', 'EPHEMERAL')
local publicocid = res.id
local privateocid = res['private-ip-id']
print "Current Public IP:"
dump(res)

-- only do a 'public-ip delete' if compute instance has a public ip assigned
-- otherwise get private-ip ocid from compute instance's vnic
-- this is needed for 'public-ip create' below
if not publicocid then
  res = oci('compute vnic-attachment list',
            '--compartment-id', compartmentid)
  local vnicocid = res['vnic-id']
  res = oci('network private-ip list',
            '--vnic-id', vnicocid)
  privateocid = res.id
else
  -- unassign current publicip w/o prompting
  oci('network public-ip delete',
      '--force',
      '--public-ip-id', publicocid)
end

-- reassign new publicip
res = oci('network public-ip create',
          '--compartment-id', compartmentid,
          '--lifetime', 'EPHEMERAL',
          '--private-ip-id', privateocid)
print "New Public IP:"
dump(res)
