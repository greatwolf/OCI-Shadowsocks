local functional = {}
local mt = {__index = functional}

function functional.makeseq(seq)
  if #seq == 0 and next(seq) then
    return setmetatable({seq}, mt)
  end
  return setmetatable(seq, mt)
end

function functional.map(seq, pred)
  assert(type(pred) == 'function')

  local r = setmetatable({}, mt)
  for i, v in ipairs(seq) do
    r[i] = pred(v, i)
  end
  return r
end

function functional.filter(seq, pred)
  assert(type(pred) == 'function')

  local r = setmetatable({}, mt)
  for i, v in ipairs(seq) do
    if pred(v, i) then table.insert(r, v) end
  end
  return r
end

function functional.reduce(seq, op, init)
  if type(op) ~= 'function' then
    init = op
    op = function(a, b) return a + b end
  end

  local i, r = next(seq)
  if init then
    r = op(init, r)
  end
  for _, v in next, seq, i do
    r = op(r, v)
  end
  return r
end

return functional