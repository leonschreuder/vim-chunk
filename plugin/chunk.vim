" vim-chunk - Reading large files in chunks
" Maintainer:    Leon Schreuder
" Version:       0.1

if exists("g:loaded_chunk")
  finish
endif
let g:loaded_chunk = 1

let g:chunkSize="5000" " 3 chunks are displayed at any time

command! -nargs=1 Chunk call Chunk(<q-args>)
fu! Chunk(...)
  call chunk#loadFile(a:1)
  call chunk#editChunkBuffer()

  let g:chunksVisible = chunk#big()

  call chunk#log("loading initial 3 chunks: " . g:chunksVisible.start . "-" . g:chunksVisible.end . " (of total " . g:chunkFileLines . " lines)")

  " read specified line range using sed
  let readLines = systemlist("sed -n " . g:chunksVisible.start . "," . g:chunksVisible.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)

  call deletebufline(bufname(), 1) " because of the new buffer, the first line is empty, delete it
endfu

" loads 3 chunks with the specified line number in the middle chunk
command! -nargs=+ ChunkTo call ChunkTo(<f-args>)
fu! ChunkTo(...)

  if exists("a:2")
    call chunk#loadFile(a:2)
  endif
  if !exists("g:chunkFile")
    echoerr "Error: Please provide a chunk-file"
  endif
  call chunk#editChunkBuffer()

  let g:chunksVisible = chunk#big(a:1)
  let g:chunksVisible.start = g:chunksVisible.start

  call chunk#log("loading 3 chunks from ". g:chunkFile .": " . g:chunksVisible.start . "-" . g:chunksVisible.end . " (of total " . g:chunkFileLines . " lines)")

  " read specified line range using sed
  let readLines = systemlist("sed -n " . g:chunksVisible.start . "," . g:chunksVisible.end . "p " . g:chunkFile)
  :1,$d " delete all lines in buffer first
  " add new lines at the end of the file
  call append(line('$'), readLines)
  call deletebufline(bufname(), 1) " because of the new buffer, the first line is empty, delete it
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  if g:chunksVisible.end >= g:chunkFileLines
    echom "Already at end of file."
    return
  endif

  let nextChunk = chunk#next(g:chunksVisible.end)

  let g:chunksVisible.start=g:chunksVisible.start + g:chunkSize
  let g:chunksVisible.end=nextChunk.end

  call chunk#log("loading next chunk " . nextChunk.start . "-" . nextChunk.end . " (" . g:chunksVisible.start . "-" . g:chunksVisible.end . ")")

  let firstHunk = chunk#firstHunk()
  call deletebufline(bufname(), firstHunk.start, firstHunk.end)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . nextChunk.start . "," . nextChunk.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(line('$'), readLines)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  if g:chunksVisible.start <= 1
    echom "Already at start of file."
    return
  endif
  let prevChunk = chunk#previous(g:chunksVisible.start)

  let g:chunksVisible.start=prevChunk.start
  let g:chunksVisible.end=g:chunksVisible.end - g:chunkSize

  call chunk#log("loading prev chunk " . prevChunk.start . "-" . prevChunk.end . " (" . g:chunksVisible.start . "-" . g:chunksVisible.end . ")")

  let removeLinesEnd=line('$') " from end of file
  let removeLinesStart=removeLinesEnd - g:chunkSize + 1
  call deletebufline(bufname(), removeLinesStart, removeLinesEnd)
  " read specified line range using sed
  let readLines = systemlist("sed -n " . prevChunk.start . "," . prevChunk.end . "p " . g:chunkFile)
  " add read lines at the end of the file
  call append(0, readLines)
endfu


" can be called when in the quickfix window to open the line under the cursor
fu! LoadChunkFromQuickfix()
  let line = getline('.')
  let result = split(line, '|')
  let file=result[0]
  let line = result[1]
  call ChunkTo(line, file)
endfu



fu! chunk#loadFile(file)
  let g:chunkFile=a:file
  let g:chunkFileLines=trim(system("wc -l < " . g:chunkFile))
endfu

fu! chunk#previous(visibleStart)
  let prevChunkEnd=a:visibleStart - 1
  let prevChunkStart=prevChunkEnd - g:chunkSize + 1

  if prevChunkStart <= 1
    let prevChunkStart = 1
  endif
  return #{start: prevChunkStart, end: prevChunkEnd}
endfu

" Returns a big chunk. Which is 3 chunks, the middelest starting at the
" provided line number, then one chunk before and one after that.
" Use this to fill the initial screen.
fu! chunk#big(start = 1)
  let prevChunk = chunk#previous(a:start)
  let l:start=prevChunk.start
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

" opens a special chunk buffer. Creates it if it doesn't exist yet.
fu! chunk#editChunkBuffer()
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

fu chunk#log(...)
  if !exists("g:chunkQuiet")
    echom join(a:000)
  endif
endfu

nnoremap ]c :call ChunkNext()<CR>
nnoremap [c :call ChunkPrevious()<CR>
