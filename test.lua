local uv = require'luv'

local opts = {
	args = { '/Users/quentin/nvimtitles/video.mkv' },
	detached = false,
	stdio = { 0, 1, 2 }
}

local function cb(code, signal)
	print('code', code)
	print('signal', signal)
end

uv.spawn('mpv', opts, cb)
uv.run('default')
