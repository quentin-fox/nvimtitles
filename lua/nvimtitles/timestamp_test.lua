local lu = require'luaunit'
-- when running this file, timestamp package is relative to current file
-- not entire lua runtime (which loads lua/nvimtitles)
local timestamp = require'timestamp'

-- must be a global for luaunit to pick up
TestToString = {}

function TestToString:testZero()
  ts = timestamp.tostring(0)
  lu.assertEquals(ts, '00:00:00,000')
end

function TestToString:testOne()
  ts = timestamp.tostring(1)
  lu.assertEquals(ts, '00:00:01,000')
end

function TestToString:testMinute()
  ts = timestamp.tostring(72)
  lu.assertEquals(ts, '00:01:12,000')
end

function TestToString:testMs()
  ts = timestamp.tostring(95.119)
  lu.assertEquals(ts, '00:01:35,119')
end

function TestToString:testMsLong()
  ts = timestamp.tostring(95.119123)
  lu.assertEquals(ts, '00:01:35,119')
end

os.exit(lu.LuaUnit.run())
