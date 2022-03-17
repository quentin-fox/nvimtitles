-- same api as luv lua package, wraps libuv
local uv = vim.loop
local json = require'nvimtitles.json'

local SOCK = "/tmp/bnpipe"

local M = {}

local function splitlines(str)
  lines = {}
  for l in str:gmatch('([^\n]*)\n') do
    table.insert(lines, l)
  end

  return lines
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

function M.pause()
  M.client:write("cycle pause")
end

function M.timestamp()
  local request_id = math.random(2048)
  local cmd = {
    command = {"get_property", "playback-time"},
    request_id = request_id
  }

  local data = json.encode(cmd)

  M.queue[request_id] = function(msg)
    print(msg.data .. '\n')
  end

  M.client:write(data .. '\n')
end

function M.close()
  M.client:close()
end

return M
