#!/usr/bin/env lua
require 'util.sh'

-- check config file exist
assert(type(arg[1]) == 'string',
[[
  Pass in config file to use
      eg. ./oci-config-swap.lua config.ashburn
]])
assert(io.open(arg[1])):close()

-- Copy OCI config to right place
sh 'mkdir -p ~/.oci'
sh('cp ' .. arg[1] .. ' ~/.oci/config')
-- tighten permissions so oci doesn't complain
sh 'chmod 600 ~/.oci/config'
