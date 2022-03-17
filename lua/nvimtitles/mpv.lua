local uv = vim.loop
local constants = require'nvimtitles.constants'

local M = {}

function M.play(filename, mode, timestart, geometry)
  mode = mode or 'video'
  timestart = timestart or '0:00'
  geometry = geometry or '50%x50%'

  args = {
    filename,
    '--input-ipc-server=' .. constants.SOCK,
  }

  if mode == 'video' then
    table.insert(args, '--geometry=' .. geometry)
  end

  extraArgs = {
    '--really-quiet',
    '--sub-auto=fuzzy', -- subs loaded if they fuzzy match the filename
    '--start=' .. timestart,
    '--pause', -- starts the video paused
    '--keep-open=always', -- prevents mpv from quitting when playback reaches end of file
  }

  for _, arg in ipairs(extraArgs) do
    table.insert(args, arg)
  end

  local opts = {
    args = args,
    detached = true, -- so when nvim quits, mpv will quit
  }

  local handle, pid
  handle, pid = uv.spawn('mpv', opts, function()
    handle:close()
  end)
end

return M
