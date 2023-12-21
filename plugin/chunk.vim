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

  let g:chunksVisible = chunk#big()
  let g:chunkVisibleStart=g:chunksVisible.start
  let g:chunkVisibleEnd=g:chunksVisible.end

  echom "loading initial 3 chunks: " . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . " (of total " . g:chunkFileLines . " lines)"

  " read specified line range using sed
  let readLines = systemlist("sed -n " . g:chunkVisibleStart . "," . g:chunkVisibleEnd . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)

  call deletebufline(bufname(), 1)
endfu

command! -nargs=? ChunkTo call ChunkTo('<args>')
fu! ChunkTo(...)
  let g:chunksVisible = chunk#big(a:1)
  let g:chunkVisibleStart = g:chunksVisible.start
  let g:chunkVisibleEnd = g:chunksVisible.end

  echom "loading 3 chunks from ". a:1 .": " . g:chunksVisible.start . "-" . g:chunksVisible.end . " (of total " . g:chunkFileLines . " lines)"

  " read specified line range using sed
  let readLines = systemlist("sed -n " . g:chunksVisible.start . "," . g:chunksVisible.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)
  let removeLinesStart=1 " from beginning of file
  let removeLinesEnd=removeLinesStart - 1 + g:chunkSize * 3
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  if g:chunkVisibleEnd >= g:chunkFileLines
    echom "Already at end of file."
    return
  endif

  let nextChunk = chunk#next(g:chunkVisibleEnd)

  let g:chunksVisible = #{start: g:chunksVisible.start + g:chunkSize, end: nextChunk.end}
  let g:chunkVisibleStart=g:chunkVisibleStart + g:chunkSize
  let g:chunkVisibleEnd=nextChunk.end

  echom "loading next chunk " . nextChunk.start . "-" . nextChunk.end . " (" . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . ")"

  let firstHunk = chunk#firstHunk()
  call deletebufline(bufname(), firstHunk.start, firstHunk.end)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . nextChunk.start . "," . nextChunk.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  if g:chunkVisibleStart <= 1
    echom "Already at start of file."
    return
  endif
  let prevChunk = chunk#previous(g:chunkVisibleStart)

  let g:chunkVisibleStart=prevChunk.start
  let g:chunkVisibleEnd=g:chunkVisibleEnd - g:chunkSize

  echom "loading prev chunk " . prevChunk.start . "-" . prevChunk.end . " (" . g:chunkVisibleStart . "-" . g:chunkVisibleEnd . ")"

  let removeLinesEnd=line('$') " from end of file
  let removeLinesStart=removeLinesEnd - g:chunkSize + 1
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . prevChunk.start . "," . prevChunk.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(0, readLines)
endfu

fu! chunk#previous(visibleStart)
  let prevChunkEnd=a:visibleStart - 1
  let prevChunkStart=prevChunkEnd - g:chunkSize + 1

  if prevChunkStart <= 1
    let prevChunkStart = 1
  endif
  return #{start: prevChunkStart, end: prevChunkEnd}
endfu

fu! chunk#big(start = 1)
  let l:start=a:start
  let l:end=l:start - 1 + ( g:chunkSize * 3 )
  return #{start: l:start, end: l:end}
endfu

fu! chunk#next(visibleEnd)
  let l:nextChunkStart=a:visibleEnd + 1
  let l:nextChunkEnd=a:visibleEnd + g:chunkSize
  if l:nextChunkEnd >= g:chunkFileLines
    let l:nextChunkEnd = g:chunkFileLines 
  endif
  return #{start: l:nextChunkStart, end: l:nextChunkEnd}
endfu

" the large file is read in chunks, and displayed in hunks
"
" A chunk refers to a a part of the (large) file we are reading parts of
" A hunk refers to the portion of the visible lines in the buffer

fu! chunk#firstHunk()
  return #{start: 1, end: g:chunkSize}
endfu

fu! chunk#lastHunk()
  return #{start: 1, end: g:chunkSize}
endfu


nnoremap ]c :call ChunkNext()<CR>
nnoremap [c :call ChunkPrevious()<CR>
