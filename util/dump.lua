-- Basic table dump to stdout
function dump(t, indent, crumb)
  indent = indent or 0
  crumb = crumb or {}
  crumb[t] = true
  local ws = string.rep(' ', indent) .. '%s'
  local kv = "  %s = %s"
  print (ws:format'{')
  for k, v in pairs(t) do
    if type(v) == 'table' and not crumb[v] then
      print(ws:format("  " .. k .. " = "))
      dump(v, indent + 2, crumb)
    else
      print(ws:format(kv:format(k, v)))
    end
  end
  print (ws:format'}')
  crumb[t] = nil
end
