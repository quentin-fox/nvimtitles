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

command PlayerSeekForward lua require'nvimtitles'.seek_forward()
command PlayerSeekBackward lua require'nvimtitles'.seek_backward()

command PlayerIncSpeed lua require'nvimtitles'.inc_speed()
command PlayerDecSpeed lua require'nvimtitles'.dec_speed()

command SetTimestamp lua require'nvimtitles'.set_timestamp()

command PlayerSeekByStart lua require'nvimtitles'.seek_by_start()
command PlayerSeekByStop lua require'nvimtitles'.seek_by_stop()

command PlayerLoop lua require'nvimtitles'.loop()
command PlayerStopLoop lua require'nvimtitles'.stop_loop()

command -nargs=1 PlayerSeekAbs lua require'nvimtitles'.seek("<args>")

command FindCurrentSub lua require'nvimtitles'.find_current_sub()

command AddSubNumbers lua require'nvimtitles'.add_sub_numbers()
command RemoveSubNumbers lua require'nvimtitles'.remove_sub_numbers()

command ReloadSubs lua require'nvimtitles'.reload_subs()

command -nargs=1 ShiftSubs lua require'nvimtitles'.shift_subs("<args>")

command PlayerQuit lua require'nvimtitles'.quit()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvimtitles = 1
