UTSuite chunk.vim

function! s:BeforeAll()
  source autoload/chnk/chunk.vim
endfunction


function s:Test_should_init_groups()
  let g:chunkSize="5"
  let g:chunkFileLines="100"

  let result = chnk#chunk#initChunkGroups()

  AssertEquals({ 'start':1, 'end':5 }, result.firstChunk)
  AssertEquals({ 'start':6, 'end':10 }, result.middleChunk)
  AssertEquals({ 'start':11, 'end':15 }, result.lastChunk)
  AssertEquals({ 'start':1, 'end':15 }, result.displayedLines)

endfunction

function s:Test_should_init_groups_with_initial_value()
  let g:chunkSize="5"
  let g:chunkFileLines="100"

  let result = chnk#chunk#initChunkGroups(11)

  AssertEquals({ 'start':6, 'end':10 }, result.firstChunk)
  AssertEquals({ 'start':11, 'end':15 }, result.middleChunk)
  AssertEquals({ 'start':16, 'end':20 }, result.lastChunk)
  AssertEquals({ 'start':6, 'end':20 }, result.displayedLines)

endfunction

function s:Test_should_be_able_to_move_to_next_chunk()
  let g:chunkSize="5"
  let g:chunkFileLines="100"
  let input = chnk#chunk#initChunkGroups()

  let result = chnk#chunk#loadNextChunk(input)

  AssertEquals({ 'start':6, 'end':10 }, result.firstChunk)
  AssertEquals({ 'start':11, 'end':15 }, result.middleChunk)
  AssertEquals({ 'start':16, 'end':20 }, result.lastChunk)
  AssertEquals({ 'start':6, 'end':20 }, result.displayedLines)
endfunction

function s:Test_next_chunk_should_not_go_past_last_line()
  let g:chunkSize="5"
  let g:chunkFileLines="100"
  let input = chnk#chunk#initChunkGroups(100)

  let result = chnk#chunk#loadNextChunk(input)

  AssertEquals({ 'start':86, 'end':90 }, result.firstChunk)
  AssertEquals({ 'start':91, 'end':95 }, result.middleChunk)
  AssertEquals({ 'start':96, 'end':100 }, result.lastChunk)
  AssertEquals({ 'start':86, 'end':100 }, result.displayedLines)
endfunction

function s:Test_should_be_able_to_move_to_previous_chunk()
  let g:chunkSize="5"
  let g:chunkFileLines="100"
  let input = chnk#chunk#initChunkGroups(11)

  let result = chnk#chunk#loadPreviousChunk(input)

  AssertEquals({ 'start':1, 'end':5 }, result.firstChunk)
  AssertEquals({ 'start':6, 'end':10 }, result.middleChunk)
  AssertEquals({ 'start':11, 'end':15 }, result.lastChunk)
  AssertEquals({ 'start':1, 'end':15 }, result.displayedLines)
endfunction

function s:Test_prev_chunk_should_not_go_past_first_line()
  let g:chunkSize="5"
  let g:chunkFileLines="100"
  let input = chnk#chunk#initChunkGroups()

  let result = chnk#chunk#loadPreviousChunk(input)

  AssertEquals({ 'start':1, 'end':5 }, result.firstChunk)
  AssertEquals({ 'start':1, 'end':15 }, result.displayedLines)
endfunction

