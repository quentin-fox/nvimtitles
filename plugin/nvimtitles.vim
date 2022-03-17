if exists('g:loaded_nvimtitles')
	finish
endif

let s:save_cpo = &cpo
set cpo&vim

" register commands

autocmd ExitPre *.srt lua require'nvimtitles'.quit()
