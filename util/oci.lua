local functional = require 'util.functional'

function oci(...)
  local cmd = table.concat({'oci', ...}, ' ')
  local result = assert(shout(cmd))
  result = json.decode(result) or {}

  return functional.list(result.data or result)
end
