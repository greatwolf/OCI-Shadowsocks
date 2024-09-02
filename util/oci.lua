-- Simple wrapper for invoking oci-cli
local functional = require 'util.functional'
local sh    = require 'util.sh'
local json  = require 'dkjson'

function oci(...)
  local cmd = table.concat({'oci', ...}, ' ')
  local result = assert(sh.out(cmd))
  result = json.decode(result) or {}

  return functional.list(result.data or result)
end
