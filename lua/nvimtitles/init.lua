-- same api as luv lua package, wraps libuv
local uv = vim.loop
local json = require'nvimtitles.json'

local SOCK = '/tmp/bnpipe'

local M = {}

local function splitlines(str)
  lines = {}
  for l in str:gmatch('([^\n]*)\n') do
    table.insert(lines, l)
  end

  return lines
end

local function encodecmd(params, request_id)
  local cmd = {
    command = params
  }

  if request_id and isnumber(request_id) then
    cmd.request_id = request_id
  end

  return json.encode(cmd)
end

function M.connect()
  M.client = uv.new_pipe(false)
  M.client:connect(SOCK, function(err)
    assert(not err, err)

    M.client:read_start(function(err, chunk)
      if not chunk then
        M.client:close()
        return
      end

      -- sometimes duplicate messages are sent with a newline
      -- this will deduplicate the messages
      lines = splitlines(chunk)

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

function M.play(path)
  local opts = {
    args = { path },
    detached = false,
    stdio = { 0, 1, 2 }, -- tmp
  }

  uv.spawn('mpv', opts)
end

function M.write(data)
  -- newline is required to 'confirm' the command
  -- i.e. mpv buffers command inputs until a newline is received
  M.client:write(data .. '\n')
end

function M.close()
  M.client:close()
end

function M.cycle_pause()
  M.write('cycle pause')
end

function M.get_time()
  local request_id = math.random(2048)
  local cmd = {
    command = {'get_property', 'playback-time'},
    request_id = request_id
  }

  local data = json.encode(cmd)

  M.queue[request_id] = function(msg)
    print(msg.data .. '\n')
  end

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

function M.inc_speed(multiplier)
  multiplier = multiplier or 1.1
  local cmd = {'multiply', 'speed', multiplier}
  local data = encodecmd(cmd)
  M.write(data)
end

function M.dec_speed(multiplier)
  multiplier = multiplier or 1.1
  local cmd = {'multiply', 'speed', 1 / multiplier}
  local data = encodecmd(cmd)
  M.write(data)
end

function M.quit()
  M.write('quit')
end

return M
