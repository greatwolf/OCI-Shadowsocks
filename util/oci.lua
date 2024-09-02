-- Simple wrapper for invoking oci-cli
require 'util.sh'
require 'util.functional'
local json  = require 'dkjson'

function oci(...)
  local params = table.concat({...}, ' ')
  local cmd = ("oci %s 2>&1"):format(params)

  local result = assert(sh.out(cmd))
  result = json.decode(result)
        or json.decode(result:match "^ServiceError:(.+)" or "{}")

  return functional.list(result.data or result)
end
