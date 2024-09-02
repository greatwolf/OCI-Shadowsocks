#!/usr/bin/env lua
require 'util.sh'
require 'util.oci'
require 'util.dump'

local config =
{
  ['compartment-id'] = "ocid1.tenancy.oc1..aaaaaaaasp7dsmvw3jxm5qzk7i5e4tjx7v3os36lshkdjragdyjgj5h53mrq",
  ['availability-domain'] = "yvnv:US-ASHBURN-AD-1",
  ['subnet-id'] = "ocid1.subnet.oc1.iad.aaaaaaaaj4c6vgrtt7e6sxkpesduef6bkavbgvpd2gxig72xnhqto5knla5q",
  ['image-id'] = "ocid1.image.oc1.iad.aaaaaaaai42i6avvfxqawj3bjl5uzhlyq5lqkqhbeg4lpo5corvwqgnvrloq",
  ['shape'] = "VM.Standard.A1.Flex",
  ['shape-config'] = [['{"memoryInGBs": 16.0,"ocpus": 2.0}']]
}
local params = {}

for k, v in pairs(config) do
  local p = ("--%s %s"):format(k, v)
  table.insert(params, p)
end

local logfmt = "%s %s Status: %d Message: %s"
function log(resp)
  local line  = logfmt:format(os.date '[%m/%d %H:%M:%S]',
                              resp.request_endpoint,
                              resp.status,
                              resp.message)
  print(line)
end

local res = oci('compute instance launch',
                '--no-retry',
                table.concat(params, ' '))
log(res)

while res.message == "Out of host capacity." do
  sh 'sleep 30'
  res = oci('compute instance launch',
            '--no-retry',
            table.concat(params, ' '))
  log(res)
end
dump(res)