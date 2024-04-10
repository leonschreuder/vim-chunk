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
  call chnk#file#load(a:1)
  call chnk#buffer#activateOrOpen()

  let g:chunksVisible = chnk#chunk#threeChunks()

  call chunk#log("loading initial 3 chunks: " . g:chunksVisible.start . "-" . g:chunksVisible.end . " (of total " . g:chunkFileLines . " lines)")

  call chnk#file#loadLinesToBufferEnd(g:chunksVisible.start, g:chunksVisible.end)
  call chnk#buffer#removeDefaultFirstLine()
endfu

" loads 3 chunks with the specified line number in the middle chunk
command! -nargs=+ ChunkTo call ChunkTo(<f-args>)
fu! ChunkTo(...)

  if exists("a:2")
    call chnk#file#load(a:2)
  endif
  if !exists("g:chunkFile")
    echoerr "Error: Please provide a chunk-file"
  endif
  call chnk#buffer#activateOrOpen()

  let g:chunksVisible = chnk#chunk#threeChunks(a:1)

  call chunk#log("loading 3 chunks from ". g:chunkFile .": " . g:chunksVisible.start . "-" . g:chunksVisible.end . " (of total " . g:chunkFileLines . " lines)")

  " read specified line range using sed
  call chnk#buffer#clear()
  call chnk#file#loadLinesToBufferEnd(g:chunksVisible.start, g:chunksVisible.end)
  call chnk#buffer#removeDefaultFirstLine()
  call cursor(g:chunkSize, 1)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  if g:chunksVisible.end >= g:chunkFileLines
    echom "Already at end of file."
    return
  endif

  let nextChunk = chnk#chunk#after(g:chunksVisible.end)

  let g:chunksVisible.start=g:chunksVisible.start + g:chunkSize
  let g:chunksVisible.end=nextChunk.end

  call chunk#log("loading next chunk " . nextChunk.start . "-" . nextChunk.end . " (" . g:chunksVisible.start . "-" . g:chunksVisible.end . ")")

  call chnk#buffer#removeLastChunk()
  call chnk#file#loadLinesToBufferEnd(nextChunk.start, nextChunk.end)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  if g:chunksVisible.start <= 1
    echom "Already at start of file."
    return
  endif

  let prevChunk = chnk#chunk#before(g:chunksVisible.start)

  " let g:chunksModel.firstChunk = #{startLine: 1, lastLine: 10}
  

  let g:chunksVisible.start=prevChunk.start
  let g:chunksVisible.end=g:chunksVisible.end - g:chunkSize

  call chunk#log("loading prev chunk " . prevChunk.start . "-" . prevChunk.end . " (" . g:chunksVisible.start . "-" . g:chunksVisible.end . ")")

  call chnk#buffer#removeFirstChunk()
  call chnk#file#loadLinesToBufferStart(prevChunk.start, prevChunk.end)
endfu

" can be called when in the quickfix window to open the line under the cursor
fu! LoadChunkFromQuickfix()
  let line = getline('.')
  let result = split(line, '|')
  let file=result[0]
  let line = result[1]
  call ChunkTo(line, file)
endfu


" the large file is read in chunks, and displayed in hunks
"
" A chunk refers to a a part of the (large) file we are reading parts of
" A hunk refers to the portion of the visible lines in the buffer

fu chunk#log(...)
  if !exists("g:chunkQuiet")
    echom join(a:000)
  endif
endfu
