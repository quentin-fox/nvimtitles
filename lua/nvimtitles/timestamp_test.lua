local lu = require 'luaunit'
-- when running this file, timestamp package is relative to current file
-- not entire lua runtime (which loads lua/nvimtitles)
local timestamp = require 'timestamp'

-- must be a global for luaunit to pick up
TestToString = {}

function TestToString:testZero()
  local ts = timestamp.tostring(0)
  lu.assertEquals(ts, '00:00:00,000')
end

function TestToString:testOne()
  local ts = timestamp.tostring(1)
  lu.assertEquals(ts, '00:00:01,000')
end

function TestToString:testMinute()
  local ts = timestamp.tostring(72)
  lu.assertEquals(ts, '00:01:12,000')
end

function TestToString:testMs()
  local ts = timestamp.tostring(95.119)
  lu.assertEquals(ts, '00:01:35,119')
end

function TestToString:testMsLong()
  local ts = timestamp.tostring(95.119123)
  lu.assertEquals(ts, '00:01:35,119')
end

TestFromString = {}

function TestFromString:testZero()
  local seconds = timestamp.fromstring('00:00:00,000')
  lu.assertEquals(seconds, 0)
end

function TestFromString:testOne()
  local seconds = timestamp.fromstring('00:00:01,000')
  lu.assertEquals(seconds, 1)
end

function TestFromString:testMinute()
  local seconds = timestamp.fromstring('00:02:31,000')
  lu.assertEquals(seconds, 151)
end

function TestFromString:testMs()
  local seconds = timestamp.fromstring('00:02:31,028')
  lu.assertEquals(seconds, 151.028)
end

TestSplit = {}

function TestSplit.test()
  local ts1, ts2 = timestamp.split('00:00:00,000 --> 00:00:15,123')
  lu.assertEquals(ts1, '00:00:00,000')
  lu.assertEquals(ts2, '00:00:15,123')
end

TestFirst = {}

function TestFirst:testSingle()
  local ts = timestamp.first('00:00:00,000')
  lu.assertEquals(ts, '00:00:00,000')
end

function TestFirst:testSingleWithArrow()
  local ts = timestamp.first('00:00:15,000 -->')
  lu.assertEquals(ts, '00:00:15,000')
end

function TestFirst:testPair()
  local ts = timestamp.first('00:00:15,000 --> 00:00:34,000')
  lu.assertEquals(ts, '00:00:15,000')
end

os.exit(lu.LuaUnit.run())
