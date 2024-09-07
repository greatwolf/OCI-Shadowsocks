-- Basic table dump to stdout
function dump(t, indent, crumb)
  indent = indent or 0
  crumb = crumb or {}
  crumb[t] = true
  local ws = string.rep(' ', indent) .. '%s'
  local kv = "  %s = %s"
  print (ws:format'{')
  for k, v in pairs(t) do
    print(ws:format(kv:format(k, tostring(v))))
    if type(v) == 'table' and not crumb[v] then
      dump(v, indent + 2, crumb)
    end
  end
  print (ws:format'}')
  crumb[t] = nil
end
