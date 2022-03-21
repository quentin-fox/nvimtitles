local socket = require'nvimtitles.socket'
local mpv = require'nvimtitles.mpv'
local utils = require'nvimtitles.utils'
local buffer = require'nvimtitles.buffer'
local constants = require'nvimtitles.constants'
local timestamp = require'nvimtitles.timestamp'

local uv = vim.loop

local M = {}

function M.player_open(mode, argstr)
  local args = utils.split(argstr, '%S+')

  filename = args[1]
  timestart = args[2]
  geometry = args[3]

  mpv.play(filename, mode, timestart, geometry)

  -- run whenever the socket connects successfully
  local function resolve()
    vim.defer_fn(function()
      vim.notify("Connected to mpv")
    end, 0)
  end

  -- is run the first time the socket fails to connect
  -- the second time it fails (after a backoff) it will bubble the error
  -- this lets mpv connect quickly if it's already booted up
  -- but not throw errors if it's slow to start
  local function reject()
    vim.defer_fn(function()
      socket.connect(resolve)
    end, 2000)
  end

  vim.defer_fn(function()
    socket.connect(resolve, reject)
  end, 250)
end

function M.cycle_pause()
  socket.cycle_pause()
end

function M.seek_forward()
  local seconds = vim.g.nvimtitles_skip_amount
  seconds = seconds or 5

  socket.seek(seconds)
end

function M.seek_backward()
  local seconds = vim.g.nvimtitles_skip_amount
  seconds = seconds or 5

  seconds = seconds * -1
  socket.seek(seconds)
end

function M.inc_speed()
  local multiplier = vim.g.nvimtitles_speed_shift_multiplier
  multiplier = multiplier or 1.1

  socket.multiply_speed(multiplier)
end

function M.dec_speed()
  local multiplier = vim.g.nvimtitles_speed_shift_multiplier
  multiplier = multiplier or 1.1

  multiplier = 1 / multiplier
  socket.multiply_speed(multiplier)
end

function M.set_timestamp()
  local function fn(seconds)
    local blank_line_nr = buffer.get_last_blank_line()
    local arrow_line_nr = buffer.get_last_arrow_timestamp()
    local single_ts_line_nr = buffer.get_last_single_timestamp()

    ts = timestamp.tostring(seconds)

    if blank_line_nr == -1 and arrow_line_nr == -1 and single_ts_line_nr == -1 then
      buffer.insert_line(0, ts)
    elseif blank_line_nr > arrow_line_nr and blank_line_nr > single_ts_line_nr then
      buffer.replace_line(blank_line_nr, ts)
    elseif single_ts_line_nr > blank_line_nr then
      buffer.append_line(single_ts_line_nr, constants.ARROW .. ts)
    end
  end

  socket.get_time(fn)
end

function M.seek_by_start()
  local ts_line_nr = buffer.get_last_partial_timestamp()
  local ts_line = buffer.get_line(ts_line_nr)
  local ts = timestamp.first(ts_line)

  if not ts then
    return
  end

  local seconds = timestamp.fromstring(ts)
  socket.seek_abs(seconds)
end

function M.seek_by_stop()
  local ts_line_nr = buffer.get_last_full_timestamp()
  local ts_line = buffer.get_line(ts_line_nr)

  local _, ts = timestamp.split(ts_line)

  if not ts then
    return
  end

  local seconds = timestamp.fromstring(ts)
  socket.seek_abs(seconds)
end

function M.loop()
  local ts_line_nr = buffer.get_last_full_timestamp()
  local ts_line = buffer.get_line(ts_line_nr)

  local ts1, ts2 = timestamp.split(ts_line)

  if not ts1 or not ts2 then
    return
  end

  local seconds1 = timestamp.fromstring(ts1)
  local seconds2 = timestamp.fromstring(ts2)

  socket.loop(seconds1, seconds2)
end

function M.stop_loop()
  socket.stop_loop()
end

function M.seek(arg)
  local seconds

  if arg:match(":") then
    -- either as the mm:ss or m:ss format
    if arg:len() == 4 or arg:len() == 5 then
      seconds = timestamp.fromshortstring(arg)
    elseif arg:len() == 12 then
      -- uses full ts format (hh:mm:ss,mss)
      seconds = timestamp.fromstring(arg)
    else
      -- todo handle case with incorrectly formatted timestamp
      return
    end
  else
    seconds = tonumber(arg)
  end

  socket.seek_abs(seconds)
end

function M.find_current_sub()
  local function fn(seconds)
    local lines = buffer.get_lines()

    local found_line = -1
    for line_num, line in ipairs(lines) do
      -- returns nil, nil if the line is not a timestamp line
      local ts1, ts2 = timestamp.split(line)

      if ts1 and ts2 then
        local seconds1 = timestamp.fromstring(ts1)
        local seconds2 = timestamp.fromstring(ts2)

        if seconds >= seconds1 and seconds <= seconds2 then
          found_line = line_num
          break
        end
      end
    end

    if found_line == -1 then
      return
    end

    -- both lua and the cursor rows are 1-indexed
    -- so only add 1 to go to the text below the timestamp
    local row = found_line + 1
    local col = 0

    vim.api.nvim_win_set_cursor(0, {row, col})
  end

  socket.get_time(fn)
end

function M.quit()
  socket.quit()
end

return M
