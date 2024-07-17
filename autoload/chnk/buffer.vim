
fu! chnk#buffer#edit(file)
  exec 'e ' . a:file
  set readonly
  set nomodifiable
endfu

" opens a special chunk buffer. Creates it if it doesn't exist yet.
fu! chnk#buffer#changeToNormalWindow()
  if getwininfo(win_getid())[0]['quickfix']
    wincmd p " if we're in a quickfix/locationlist switch to previous window
  endif
endfu
