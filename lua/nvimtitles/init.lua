local socket = require'nvimtitles.socket'
local mpv = require'nvimtitles.mpv'
local utils = require'nvimtitles.utils'
local uv = vim.loop

local M = {}

function M.player_open(mode, argstr)
  local args = utils.split(argstr, '%S+')

  filename = args[1]
  timestart = args[2]
  geometry = args[3]

  mpv.play(filename, mode, timestart, geometry)

  -- wait for 250ms to allow for mpv to open
  vim.defer_fn(function()
    socket.connect()
    vim.notify("Connected to mpv")
  end, 250)
end

function M.cycle_pause()
  socket.cycle_pause()
end

function M.quit()
  socket.quit()
end

return M
