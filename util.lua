local util = {}

util.get_separator = function()
  if util.is_windows then
    return '\\'
  end
  return '/'
end

util.join_paths = function(...)
  local separator = util.get_separator()
  return table.concat({ ... }, separator)
end

util.extend = function(policy, ...)
  local result = {}

  for _,t in ipairs{ ... } do
    for k,v in pairs(t) do
      result[k] = v
    end
  end

  return result
end

util.deep_extend = function(policy, ...)
  local result = {}
  local function helper(policy, k, v1, v2)
    if type(v1) ~= 'table' or type(v2) ~= 'table' then
      if policy == 'error' then
        error('Key ' .. vim.inspect(k) .. ' is already present with value ' .. vim.inspect(v1))
      elseif policy == 'force' then
        return v2
      else
        return v1
      end
    else
      return util.deep_extend(policy, v1, v2)
    end
  end

  for _, t in ipairs { ... } do
    for k, v in pairs(t) do
      if result[k] ~= nil then
        result[k] = helper(policy, k, result[k], v)
      else
        result[k] = v
      end
    end
  end

  return result
end

util.is_dir = function(path)
  local f = io.open(path, "r")
  if f == nil then
    return false
  end

  local ok, err, code = f:read(1)
  f:close()
  return code == 21
end

return util
