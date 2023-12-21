" vim-chunk - Reading large files in chunks
" Maintainer:    Leon Schreuder
" Version:       0.1

if exists("g:loaded_chunk")
  finish
endif
let g:loaded_chunk = 1

let g:chunkSize="1000" " remember 3 chunks are displayed at a time

command! -nargs=? Chunk call Chunk('<args>')
fu! Chunk(...)
  let g:chunkFile=a:1
  let g:chunkFileLines=trim(system("wc -l < " . g:chunkFile))

  :enew

  let g:chunkVisibleStart="1"
  let g:chunkVisibleEnd=g:chunkVisibleStart - 1 + ( g:chunkSize * 3 )

  echom "loading initial 3 chunks: " . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . " (of total " . g:chunkFileLines . " lines)"

  " read specified line range using sed
  let readLines = systemlist("sed -n " . g:chunkVisibleStart . "," . g:chunkVisibleEnd . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)

  call deletebufline(bufname(), 1)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  if g:chunkVisibleEnd >= g:chunkFileLines
    echom "Already at end of file."
    return
  endif

  let nextChunkStart=g:chunkVisibleEnd + 1
  let nextChunkEnd=g:chunkVisibleEnd + g:chunkSize
  if nextChunkEnd >= g:chunkFileLines
    let nextChunkEnd = g:chunkFileLines 
  endif

  let g:chunkVisibleStart=g:chunkVisibleStart + g:chunkSize
  let g:chunkVisibleEnd=nextChunkEnd

  echom "loading next chunk " . nextChunkStart . "-" . nextChunkEnd . " (" . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . ")"

  let removeLinesStart=1 " from beginning of file
  let removeLinesEnd=removeLinesStart - 1 + g:chunkSize
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . nextChunkStart . "," . nextChunkEnd . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  if g:chunkVisibleStart <= 1
    echom "Already at start of file."
    return
  endif
  let prevChunkEnd=g:chunkVisibleStart - 1
  let prevChunkStart=prevChunkEnd - g:chunkSize + 1

  let g:chunkVisibleStart=prevChunkStart
  let g:chunkVisibleEnd=g:chunkVisibleEnd - g:chunkSize

  echom "loading prev chunk " . prevChunkStart . "-" . prevChunkEnd . " (" . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . ")"

  let removeLinesEnd=line('$') " from end of file
  let removeLinesStart=removeLinesEnd - g:chunkSize + 1
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . prevChunkStart . "," . prevChunkEnd . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(0, readLines)
endfu

nnoremap ]c :call ChunkNext()<CR>
nnoremap [c :call ChunkPrevious()<CR>
