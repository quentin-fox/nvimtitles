-- same api as luv lua package, wraps libuv
local uv = vim.loop
local json = require'nvimtitles.json'
local constants = require'nvimtitles.constants'
local utils = require'nvimtitles.utils'

local M = {}

function M.connect(resolve, reject)
  M.client = uv.new_pipe(false)
  M.client:connect(constants.SOCK, function(err)
    if err then
      if reject then
        reject()
        return
      end

      assert(not err, err)
    end

    resolve()

    M.client:read_start(function(err, chunk)
      if not chunk then
        M.client:close()
        return
      end

      -- sometimes duplicate messages are sent with a newline
      -- this will deduplicate the messages
      lines = utils.split(chunk, '([^\n]*)\n')

      for i, l in ipairs(lines) do
        local success, msg, err = pcall(function() return json.decode(l) end)

        if success and msg.request_id and M.queue[msg.request_id] then
          M.queue[msg.request_id](msg)
          M.queue[msg.request_id] = nil
        end
      end
    end)
  end)

  M.queue = {}
end

function M.write(data, silent)
  silent = silent or false
  -- newline is required to 'confirm' the command
  -- i.e. mpv buffers command inputs until a newline is received
  if not M.client or uv.is_closing(M.client) then
    local msg = 'communication with mpv process is not open'

    if not silent then
      vim.notify(msg, vim.log.levels.ERROR)
    end
    return
  end

  M.client:write(data .. '\n')
end

function M.close()
  if M.client then
    M.client:close()
  end
end

function M.cycle_pause()
  M.write('cycle pause')
end

local function encodecmd(params, request_id)
  local cmd = {
    command = params
  }

  if request_id and type(request_id) == 'number' then
    cmd.request_id = request_id
  end

  return json.encode(cmd)
end

function M.get_time(fn)
  local request_id = math.random(2048)
  local cmd = {'get_property', 'playback-time'}
  local data = encodecmd(cmd, request_id)

  -- wrap in case fn contains a vimL call
  M.queue[request_id] = vim.schedule_wrap(function(msg)
    fn(msg.data)
  end)

  M.write(data)
end

function M.seek(seconds)
  local cmd = {'seek', tostring(seconds), 'relative'}
  local data = encodecmd(cmd)
  M.write(data)
end

function M.seek_abs(seconds)
  local cmd = {'seek', tostring(seconds), 'absolute'}
  local data = encodecmd(cmd)
  M.write(data)
end

function M.loop(start, stop)
  local cmda = {'set_property', 'ab-loop-a', start}
  local dataa = encodecmd(cmda)

  local cmdb = {'set_property', 'ab-loop-a', stop}
  local datab = encodecmd(cmdb)

  M.write(dataa)
  M.write(datab)
end

function M.stop_loop()
  M.write('ab-loop')
end

function M.multiply_speed(multiplier, fn)
  multiplier = multiplier
  local cmd1 = {'multiply', 'speed', multiplier}
  local data1 = encodecmd(cmd1)

  M.write(data1)

  if not fn then
    return
  end

  local request_id = math.random(2048)
  local cmd2 = {'get_property', 'speed'}
  local data2 = encodecmd(cmd2, request_id)

  M.queue[request_id] = vim.schedule_wrap(function(msg)
    fn(msg.data)
  end)

  M.write(data2)
end

function M.reload_subs()
  M.write('sub-reload')
end

function M.quit()
  local silent = true
  M.write('quit', silent)
  M.close()
end

return M
