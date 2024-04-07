-- Convenience functions for running shell commands
sh = setmetatable({}, {})
sh.env = os.getenv
getmetatable(sh).__call = function(_, ...)
  return os.execute(...)
end

shout = function(cmd)
  local out = assert(io.popen(cmd)):read '*all'
  assert(type(out) == 'string')
  return out:sub(0, -2) -- drop trailing newline
end
