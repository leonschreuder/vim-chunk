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
  let g:chunkModel = chnk#chunk#initChunkGroups()

  call chunk#log("loading initial 3 chunks: " . g:chunkModel.displayedLines.start . "-" . g:chunkModel.displayedLines.end . " (of total " . g:chunkFileLines . " lines)")

  call chnk#file#loadLinesToBufferEnd(g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
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

  let g:chunkModel = chnk#chunk#initChunkGroups(a:1)

  call chunk#log("loading 3 chunks from ". g:chunkFile .": " . g:chunkModel.displayedLines.start . "-" . g:chunkModel.displayedLines.end . " (of total " . g:chunkFileLines . " lines)")

  call chnk#buffer#clear()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#removeDefaultFirstLine()
  call cursor(g:chunkSize, 1)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  let g:chunkModel = chnk#chunk#loadNextChunk(g:chunkModel)

  call chunk#log("loading next chunk " . g:chunkModel.lastChunk.start . "-" . g:chunkModel.lastChunk.end . " (" . g:chunkModel.displayedLines.start . "-" . g:chunkModel.displayedLines.end . ")")

  call chnk#buffer#removeFirstChunk()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.lastChunk.start, g:chunkModel.lastChunk.end)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  let g:chunkModel = chnk#chunk#loadPreviousChunk(g:chunkModel)

  call chunk#log("loading prev chunk " . g:chunkModel.firstChunk.start . "-" . g:chunkModel.firstChunk.end . " (" . g:chunkModel.displayedLines.start . "-" . g:chunkModel.displayedLines.end . ")")

  call chnk#buffer#removeLastChunk()
  call chnk#file#loadLinesToBufferStart(g:chunkModel.firstChunk.start, g:chunkModel.firstChunk.end)
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
