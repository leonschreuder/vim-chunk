
fu! chnk#buffer#edit(file)
  exec 'e ' . a:file
  " copy the content of the chunkfile to the original file
  autocmd! BufWritePost <buffer> call chnk#buffer#BufWritePostAction()
endfu

" Function called by the BufWritePost action.
" In a separate function as tests don't work on autocmds
fu! chnk#buffer#BufWritePostAction()
  call chnk#file#updateLinesFromFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
endfu

" opens a special chunk buffer. Creates it if it doesn't exist yet.
fu! chnk#buffer#changeToNormalWindow()
  if getwininfo(win_getid())[0]['quickfix']
    wincmd p " if we're in a quickfix/locationlist switch to previous window
  endif
endfu
