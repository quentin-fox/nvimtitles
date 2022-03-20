local M = {}

function M.tostring(seconds)
  if seconds == 0 then
    return '00:00:00,000'
  end

  -- https://stackoverflow.com/a/17480764
  local whole_seconds = math.floor(seconds)
  local ts = os.date('!%X', whole_seconds)

  -- os.date can't handle miliseconds, so have to append them afterwards
  local whole_ms = math.floor(seconds * 1000 % 1000)
  local ms = tostring(whole_ms)
  local ms_len = string.len(ms)

  -- stupid padding, but it will work in this limited scope
  if ms_len == 1 then
    ms = '00' .. ms
  elseif ms_len == 2 then
    ms = '0' .. ms
  end

  return ts .. ',' .. ms
end

return M