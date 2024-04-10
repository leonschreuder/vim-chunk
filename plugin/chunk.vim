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

  call chunk#logChunkUpdate("Loading first 3 chunks.", g:chunkModel)

  call chnk#buffer#clear()
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
    return
  endif
  call chnk#buffer#activateOrOpen()

  let g:chunkModel = chnk#chunk#initChunkGroups(a:1)

  call chunk#logChunkUpdate("Loading 3 chunks centered around line " . a:1 . ".", g:chunkModel)

  call chnk#buffer#clear()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#removeDefaultFirstLine()
  call cursor(g:chunkSize, 1)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  call chnk#buffer#activateOrOpen()
  let g:chunkModel = chnk#chunk#loadNextChunk(g:chunkModel)

  call chunk#logChunkUpdate("Loading next chunk.", g:chunkModel)

  call chnk#buffer#removeFirstChunk()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.lastChunk.start, g:chunkModel.lastChunk.end)
endfu

command! ChunkLast call ChunkLast()
fu! ChunkLast()
  call chnk#buffer#activateOrOpen()
  let g:chunkModel = chnk#chunk#loadLastChunk(g:chunkModel)

  call chunk#logChunkUpdate("Loading last 3 chunks.", g:chunkModel)

  call chnk#buffer#clear()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#removeDefaultFirstLine()
endfu

command! ChunkFirst call ChunkFirst()
fu! ChunkFirst()
  call chnk#buffer#activateOrOpen()
  let g:chunkModel = chnk#chunk#loadFirstChunk(g:chunkModel)

  call chunk#logChunkUpdate("Loading first 3 chunks.", g:chunkModel)

  call chnk#buffer#clear()
  call chnk#file#loadLinesToBufferEnd(g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#removeDefaultFirstLine()
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  call chnk#buffer#activateOrOpen()
  let g:chunkModel = chnk#chunk#loadPreviousChunk(g:chunkModel)

  call chunk#logChunkUpdate("Loading previous chunk.", g:chunkModel)

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

fu! chunk#logChunkUpdate(msg, model)
  call chunk#log(a:msg, "Line " . a:model.displayedLines.start . "-" . a:model.displayedLines.end . " of " . g:chunkFileLines . " in " . g:chunkFile . ")")
endfu

fu! chunk#log(...)
  if !exists("g:chunkQuiet")
    echom join(a:000)
  endif
endfu
