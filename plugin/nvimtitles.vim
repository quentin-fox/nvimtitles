if exists('g:loaded_nvimtitles')
	finish
endif

let s:save_cpo = &cpo
set cpo&vim

" register commands

command! NVTStart lua require('nvimtitles.main').test()
