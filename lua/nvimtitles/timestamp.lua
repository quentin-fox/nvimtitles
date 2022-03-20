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

-- parses a string like 15:52 or 9:10 to seconds
function M.fromshortstring(ts)
  local pattern = "(%d+):(%d%d)"
  local m, s = ts:match(pattern)

  local seconds = 0
  seconds = seconds + tonumber(s)
  seconds = seconds + (tonumber(m) * 60)

  return seconds
end

function M.fromstring(ts)
  local pattern = "(%d+):(%d%d):(%d%d),(%d%d%d)"
  local h, m, s, ms = ts:match(pattern)

  local seconds = 0
  seconds = seconds + tonumber(s)
  seconds = seconds + (tonumber(m) * 60)
  seconds = seconds + (tonumber(h) * 60 * 60)
  seconds = seconds + (tonumber(ms) / 1000)

  return seconds
end

-- splits a full timestamp with arrow split
-- returns both timestamps as strings
-- assumes that the full_ts passed in is already in the correct format
function M.split(full_ts)
  local pattern = "^(.*) %-%-> (.*)$"
  local ts1, ts2 = full_ts:match(pattern)
  return ts1, ts2
end

-- returns the first timestamp encountered in a line
function M.first(line)
  local pattern = "(%d+:%d%d:%d%d,%d%d%d).*"
  local ts = line:match(pattern)

  return ts
end

return M
