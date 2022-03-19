local M = {}

function M.tostring(seconds)
  if seconds == 0 then
    return '00:00:00,000'
  end

  -- https://stackoverflow.com/a/17480764
  ts = os.date('!%X', seconds)

  ms = tostring(seconds * 1000 % 1000)
  ts = ts .. ',' .. ms
  return ts
end

return M
