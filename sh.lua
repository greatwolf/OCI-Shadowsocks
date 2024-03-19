-- Convenience functions for running shell commands
sh    = os.execute
shout = function(cmd)
  local out = assert(io.popen(cmd)):read '*all'
  assert(type(out) == 'string')
  return out:sub(0, -2) -- drop trailing newline
end
