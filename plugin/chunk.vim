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
  call chnk#buffer#changeToNormalWindow()
  let g:chunkModel = chnk#chunk#initChunkGroups()

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call chunk#logChunkUpdate("Loaded first 3 chunks.", g:chunkModel)
endfu

" loads 3 chunks with the specified line number in the middle chunk
command! -nargs=+ ChunkTo call ChunkTo(<f-args>)
fu! ChunkTo(...)
  if exists("a:2")
    call chnk#file#load(a:2)
  else
    " use global variables
  endif
  if !exists("g:chunkFile")
    echoerr "Error: Please provide a chunk-file"
    return
  endif
  call chnk#buffer#changeToNormalWindow()

  let g:chunkModel = chnk#chunk#initChunkGroups(a:1)

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call cursor(g:chunkSize + 1, 1)
  call chunk#logChunkUpdate("Loading 3 chunks centered around line " . a:1 . ".", g:chunkModel)
endfu

command! ChunkNext call ChunkNext()
fu! ChunkNext()
  call chnk#buffer#changeToNormalWindow()
  let g:chunkModel = chnk#chunk#loadNextChunk(g:chunkModel)

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call chunk#logChunkUpdate("Loaded next chunk.", g:chunkModel)
endfu

command! ChunkLast call ChunkLast()
fu! ChunkLast()
  call chnk#buffer#changeToNormalWindow()
  let g:chunkModel = chnk#chunk#loadLastChunk(g:chunkModel)

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call chunk#logChunkUpdate("Loaded last 3 chunks.", g:chunkModel)
endfu

command! ChunkFirst call ChunkFirst()
fu! ChunkFirst()
  call chnk#buffer#changeToNormalWindow()
  let g:chunkModel = chnk#chunk#loadFirstChunk(g:chunkModel)

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call chunk#logChunkUpdate("Loaded first 3 chunks.", g:chunkModel)
endfu

command! ChunkPrevious call ChunkPrevious()
fu! ChunkPrevious()
  call chnk#buffer#changeToNormalWindow()
  let g:chunkModel = chnk#chunk#loadPreviousChunk(g:chunkModel)

  call chnk#file#sendLinesToFile(g:chunkFile, g:chunkTmpFile, g:chunkModel.displayedLines.start, g:chunkModel.displayedLines.end)
  call chnk#buffer#edit(g:chunkTmpFile)
  call chunk#logChunkUpdate("Loaded previous chunk.", g:chunkModel)
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
  call chunk#log(a:msg, "Line " . a:model.displayedLines.start . "-" . a:model.displayedLines.end . " of " . g:chunkFileLines . " in " . g:chunkFile)
endfu

fu! chunk#log(...)
  if !exists("g:chunkQuiet")
    echom join(a:000)
  endif
endfu
