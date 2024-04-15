
" opens a special chunk buffer. Creates it if it doesn't exist yet.
fu! chnk#buffer#activateOrOpen()
  if getwininfo(win_getid())[0]['quickfix']
    wincmd p " if we're in a quickfix/locationlist switch to previous window
  endif
  let bufNameForTab = "[chunk tab" . tabpagenr() . "]"
  if bufname() != bufNameForTab
    if !bufexists(bufNameForTab)
      ene " edit new
      " rename buffer
      exec "file " . bufNameForTab
      set buftype=nofile
    else
      " switch to current-chunk buffer
      exec 'e ' . bufNameForTab
    endif
  endif
endfu

" Buffers are never empty, so if you open a new buffer, the first line is and
" empty line. This function deletes that first line (should be used after
" filling the buffer)
fu! chnk#buffer#removeDefaultFirstLine()
  call deletebufline(bufnr(), 1)
endfu

fu! chnk#buffer#clear()
  silent %d_ " delete all lines in buffer
endfu


fu! chnk#buffer#removeLastChunk()
  let removeLinesEnd=line('$') " from end of file
  let removeLinesStart=removeLinesEnd - g:chunkSize + 1
  call deletebufline(bufnr(), removeLinesStart, removeLinesEnd)
endfu

fu! chnk#buffer#removeFirstChunk()
  call deletebufline(bufnr(), 1, g:chunkSize)
endfu
