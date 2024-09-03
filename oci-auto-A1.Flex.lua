#!/usr/bin/env lua
require 'util.sh'
require 'util.oci'
require 'util.dump'

local attach_subnetid do
  local subnetid
  attach_subnetid = function(config)
    if not subnetid then
      subnetid  = oci('network subnet list',
                      '--all',
                      '--compartment-id', config['compartment-id'])
      subnetid = table.remove(subnetid)
      subnetid = assert(subnetid and subnetid.id)
    end
    config['subnet-id'] = subnetid
    return config
  end
end

local attach_imageid do
  local imageid
  attach_imageid = function(config)
    if not imageid then
      imageid = oci('compute image list',
                    '--all',
                    '--compartment-id', config['compartment-id'])
                :filter(function(v)
                  return  v['operating-system'] == "Canonical Ubuntu"
                          and v['operating-system-version']:match "Minimal aarch64$"
                end)
      imageid = table.remove(imageid, 1)
      imageid = assert(imageid and imageid.id)
    end
    config['image-id'] = imageid
    return config
  end
end

local function stringify(t)
  local params = {}

  for k, v in pairs(t) do
    local p = ("--%s %s"):format(k, v)
    table.insert(params, p)
  end
  return table.concat(params, ' ')
end

local iam = oci 'iam availability-domain list'
local configs = iam
                :map(function(v)
                  v.id = nil
                  v['availability-domain'], v.name, v.id = v.name
                  v.shape = "VM.Standard.A1.Flex"
                  v['shape-config'] = [['{"memoryInGBs": 24.0,"ocpus": 4.0}']]
                  return v
                end)
                :map(attach_subnetid)
                :map(attach_imageid)
                :map(stringify)

local log do
  local logfmt = "%s %s Status: %d Message: %s"
  log = function(resp)
    local line  = logfmt:format(os.date '[%m/%d %H:%M:%S]',
                                resp.request_endpoint,
                                resp.status,
                                resp.message)
    print(line)
  end
end

local function pick(configs)
  local i = math.random(1, #configs)
  return configs[i]
end

local res
while true do
  res = oci('compute instance launch',
            '--no-retry',
            pick(configs))
  log(res)
  if res.message ~= "Out of host capacity." then
    break
  end
  sh 'sleep 60'
end

print "*** Stopping Retry ***"
dump(res)