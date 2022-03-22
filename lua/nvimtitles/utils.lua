local M = {}

function M.split(str, sep)
  local lines = {}
  for l in str:gmatch(sep) do
    table.insert(lines, l)
  end

  return lines
end

return M
