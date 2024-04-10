
" returns a new group of 3 chunks centered around the specified line number
" uses the beginning of the file as a fallback.
fu! chnk#chunk#initChunkGroups(centeredAroundLine = 1)
  let prevChunkStart = a:centeredAroundLine - g:chunkSize
  if prevChunkStart < 1
    let prevChunkStart = 1
  endif

  let chunkIncrement = (g:chunkSize - 1)
  let model = {}
  let model.firstChunk = {'start' : prevChunkStart }
  let model.firstChunk.end = model.firstChunk.start + chunkIncrement
  let model.middleChunk = {'start': model.firstChunk.end + 1}
  let model.middleChunk.end = model.middleChunk.start + chunkIncrement
  let model.lastChunk = {'start': model.middleChunk.end + 1 }
  let model.lastChunk.end = model.lastChunk.start + chunkIncrement
  let model.displayedLines = { 'start':model.firstChunk.start, 'end':model.lastChunk.end }
  return model
endfu

" Return a new model that is moved down the file one chunk. At the end of the
" file it simply returns the last group of chunks.
fu! chnk#chunk#loadNextChunk(model)
  let chunkIncrement = (g:chunkSize - 1)
  let newModel = {}

  let newModel.firstChunk = a:model.middleChunk
  let newModel.middleChunk = a:model.lastChunk
  let newModel.lastChunk = { 'start': newModel.middleChunk.end + 1 }
  let newModel.lastChunk.end = newModel.lastChunk.start + (g:chunkSize - 1)
  if newModel.lastChunk.end > g:chunkFileLines
    return chnk#chunk#loadLastChunk(a:model)
  else
    let newModel.displayedLines = { 'start':newModel.firstChunk.start, 'end':newModel.lastChunk.end }
    return newModel
  endif
endfu

" Return a new model that is moved up the file one chunk. At the beginning of
" the file, it simply returns the first group of chunks.
fu! chnk#chunk#loadPreviousChunk(model)
  let chunkIncrement = (g:chunkSize - 1)
  let newModel = {}

  let newModel.firstChunk = { 'start': a:model.firstChunk.start - g:chunkSize }
  if newModel.firstChunk.start < 1
    return chnk#chunk#loadFirstChunk(a:model)
  else
    let newModel.firstChunk.end = newModel.firstChunk.start + (g:chunkSize - 1)
    let newModel.middleChunk = a:model.firstChunk
    let newModel.lastChunk = a:model.middleChunk
    let newModel.displayedLines = { 'start':newModel.firstChunk.start, 'end':newModel.lastChunk.end }
    return newModel
  endif
endfu

fu! chnk#chunk#loadLastChunk(model)
  return chnk#chunk#initChunkGroups(g:chunkFileLines - g:chunkSize * 2 + 1)
endfu

fu! chnk#chunk#loadFirstChunk(model)
  return chnk#chunk#initChunkGroups() " simply create a new set of groups
endfu
