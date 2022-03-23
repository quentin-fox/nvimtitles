local uv = vim.loop
local constants = require'nvimtitles.constants'

local M = {}

function M.play(filename, mode, timestart, geometry)
  mode = mode or 'video'
  timestart = timestart or '0:00'
  geometry = geometry or '50%x50%'

  local args = {
    filename,
    '--input-ipc-server=' .. constants.SOCK,
  }

  if mode == 'video' then
    table.insert(args, '--geometry=' .. geometry)
  end

  local extraArgs = {
    '--msg-level=all=error', -- only echo error messages to stdout
    '--sub-auto=fuzzy', -- subs loaded if they fuzzy match the filename
    '--start=' .. timestart,
    '--pause', -- starts the video paused
    '--keep-open=always', -- prevents mpv from quitting when playback reaches end of file
  }

  for _, arg in ipairs(extraArgs) do
    table.insert(args, arg)
  end

  local stdout = uv.new_pipe()

  local opts = {
    args = args,
    detached = false, -- so when nvim quits, mpv will quit
    stdio = {nil, stdout, nil}
  }

  local handle
  handle, _ = uv.spawn('mpv', opts, function()
    handle:close()
  end)

  stdout:read_start(function(err, data)
    assert(not err, err)
    if data then
      vim.defer_fn(function()
        vim.notify(data, vim.log.levels.ERROR)
      end, 0)
    end
  end)
end

return M
