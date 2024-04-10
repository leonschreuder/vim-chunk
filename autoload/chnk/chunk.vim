
" Returns a group of 3 chunks. The middelest starting at the provided line
" number, and one chunk before and one after that. Use this to (re)load the
" chunk buffer.
fu! chnk#chunk#threeChunks(start = 1)
  let prevChunk = chnk#chunk#before(a:start)
  let l:start=prevChunk.start
  let l:end=l:start - 1 + ( g:chunkSize * 3 )
  return #{start: l:start, end: l:end}
endfu

fu! chnk#chunk#before(visibleStart)
  let prevChunkEnd=a:visibleStart - 1
  let prevChunkStart=prevChunkEnd - g:chunkSize + 1

  if prevChunkStart <= 1
    let prevChunkStart = 1
  endif
  return #{start: prevChunkStart, end: prevChunkEnd}
endfu

fu! chnk#chunk#after(visibleEnd)
  let l:nextChunkStart=a:visibleEnd + 1
  let l:nextChunkEnd=a:visibleEnd + g:chunkSize
  if l:nextChunkEnd >= g:chunkFileLines
    let l:nextChunkEnd = g:chunkFileLines 
  endif
  return #{start: l:nextChunkStart, end: l:nextChunkEnd}
endfu

fu! chnk#chunk#addToEndOfGroup(currentGroup)
  let a:currentGroup.start=a:currentGroup.start + g:chunkSize
  let a:currentGroup.end=nextChunk.end
endfu
