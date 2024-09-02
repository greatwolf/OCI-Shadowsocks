#!/usr/bin/env lua
require 'util.sh'
require 'util.oci'
require 'util.dump'
json = require 'dkjson'

function GetIAMInfo()
  -- get compartment-id & availability-domain
  local iam = oci 'iam availability-domain list'
  iam = iam:map(function(v)
          return
          {
            availdomain = v.name,
            compartmentid = v["compartment-id"]
          }
        end)
  return table.remove(iam)
end

function ReleasePublicIP(iam)
  -- note, only instances having a public-ip is returned
  local res = oci('network public-ip list',
                  '--compartment-id', iam.compartmentid,
                  '--scope AVAILABILITY_DOMAIN',
                  '--availability-domain', iam.availdomain,
                  '--lifetime', 'EPHEMERAL')
  -- get publicip ocid + address & privateip ocid
  res = res:map(function(v)
          return
          {
            publicocid = v.id,
            privateocid = res['private-ip-id'],
            publicip = v['ip-address']
          }
        end)

  print "Releasing Public IP:"
  dump(res)

  res:map(function(v)
    -- unassign current publicip w/o prompting
    oci('network public-ip delete',
        '--force',
        '--public-ip-id', v.publicocid)
  end)
end

function RenewPublicIP(iam)
  local instances = oci('compute instance list-vnics',
                        '--compartment-id', iam.compartmentid)
  instances = instances:map(function(v)
                return
                {
                  publicip    = v['public-ip'],
                  privateip   = v['private-ip'],
                  subnetocid  = v['subnet-id'],
                  vnicocid    = v.id
                }
              end)
  local vnics_set = instances:reduce(function(set, n)
                      set[n.vnicocid] = true
                      return set
                    end, {})
  -- assumption is all compute instances are on same subnet
  -- lookup by 'subnet-id' to avoid multiple api calls
  local privateocid = oci('network private-ip list',
                          '--subnet-id', instances[1].subnetocid)
  privateocid = privateocid
                :map(function(v)
                  return
                  {
                    privateip     = v['ip-address'],
                    vnicocid      = v['vnic-id'],
                    privateocid = v.id
                  }
                end)
                :filter(function(v)
                  return vnics_set[v.vnicocid]
                end)
                :map(function(v)
                  -- reassign new publicip
                  local res = oci('network public-ip create',
                                  '--compartment-id', iam.compartmentid,
                                  '--lifetime', 'EPHEMERAL',
                                  '--private-ip-id', v.privateocid)
                  return res
                end)
                :map(function(v)
                  return
                  {
                    publicocid  = v.id,
                    privateocid = v['private-ip-id'],
                    publicip    = v['ip-address']
                  }
                end)
  print "Renewed Public IP:"
  dump(privateocid)
end

local iam = GetIAMInfo()
ReleasePublicIP(iam)
RenewPublicIP(iam)
