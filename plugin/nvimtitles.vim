if exists('g:loaded_nvimtitles')
	finish
endif

let s:save_cpo = &cpo
set cpo&vim

" register commands

autocmd ExitPre * lua require'nvimtitles'.quit()

command -nargs=+ -complete=file PlayerOpenVideo lua require'nvimtitles'.player_open('video', "<args>")
command -nargs=+ -complete=file PlayerOpenAudio lua require'nvimtitles'.player_open('audio', "<args>")
command PlayerCyclePause lua require'nvimtitles'.cycle_pause()
command PlayerQuit lua require'nvimtitles'.quit()
command SetTimestamp lua require'nvimtitles'.set_timestamp()
command PlayerSeekForward lua require'nvimtitles'.seek_forward()
command PlayerSeekBackward lua require'nvimtitles'.seek_backward()
command PlayerIncSpeed lua require'nvimtitles'.inc_speed()
command PlayerDecSpeed lua require'nvimtitles'.dec_speed()
command PlayerSeekByStart lua require'nvimtitles'.seek_by_start()
command PlayerSeekByStop lua require'nvimtitles'.seek_by_stop()
command -nargs=1 PlayerSeekAbs lua require'nvimtitles'.seek("<args>")
