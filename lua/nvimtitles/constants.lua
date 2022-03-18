local TS_FORMAT = [[\d\d:\d\d:\d\d,\d\d\d]]
local ARROW = ' --> '

return {
  SOCK = '/tmp/nvimtitles.sock',
  BLANK_LINE = [[^\s*$]],
  ARROW = ARROW,
  TS_FORMAT = TS_FORMAT,
  SINGLE_TS_FORMAT = '^' .. TS_FORMAT .. '$',
  FULL_TS_FORMAT = '^' .. TS_FORMAT .. ARROW .. TS_FORMAT .. '$',
}
