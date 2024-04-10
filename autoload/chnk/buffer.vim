
" opens a special chunk buffer. Creates it if it doesn't exist yet.
fu! chnk#buffer#activateOrOpen()
  if getwininfo(win_getid())[0]['quickfix']
    wincmd p " switch to previous window
  endif
  if bufname() != "current-chunk"
    if !bufexists("current-chunk")
      ene " edit new
      file current-chunk " rename buffer
      set buftype=nofile
    else
      e current-chunk " edit current-chunk buffer
    endif
  endif
endfu

" Buffers are never empty, so if you open a new buffer, the first line is and
" empty line. This function deletes that first line (should be used after
" filling the buffer)
fu! chnk#buffer#removeDefaultFirstLine()
  call deletebufline(bufname(), 1)
endfu

fu! chnk#buffer#clear()
  :1,$d " delete all lines in buffer
endfu


fu! chnk#buffer#removeFirstChunk()
  let removeLinesEnd=line('$') " from end of file
  let removeLinesStart=removeLinesEnd - g:chunkSize + 1
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
endfu

fu! chnk#buffer#removeLastChunk()
  call deletebufline(bufname(), 1, g:chunkSize)
endfu
