function oci(...)
  local cmd = table.concat({'oci', ...}, ' ')
  local result = assert(shout(cmd))
  result = json.decode(result) or {}

  if result.data then result = result.data end
  return result
end
