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

  -- todo add backoff to try reconnecting
  vim.defer_fn(function()
    socket.connect()
    vim.notify("Connected to mpv")
  end, 2000)
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

    print(blank_line_nr .. '\n')
    print(arrow_line_nr .. '\n')
    print(single_ts_line_nr .. '\n')
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

function M.quit()
  socket.quit()
end

return M
