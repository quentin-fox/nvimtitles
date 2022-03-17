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
