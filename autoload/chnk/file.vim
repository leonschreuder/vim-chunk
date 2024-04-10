
fu! chnk#file#load(file)
  let g:chunkFile=a:file
  let g:chunkFileLines=trim(system("wc -l < " . g:chunkFile))
endfu

fu! chnk#file#loadLinesToBufferStart(start, end)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . a:start . "," . a:end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(0, readLines)
endfu

fu! chnk#file#loadLinesToBufferEnd(start, end)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . a:start . "," . a:end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)
endfu
