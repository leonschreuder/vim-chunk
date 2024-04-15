UTSuite Chunky Tests

function! s:BeforeAll()
  source plugin/chunk.vim
endfunction

function s:Setup()
  unlet! g:loaded_chunk
  let g:chunkQuiet = 1
endfunction

function s:Teardown()
  :b# " switch back to previous buffer

  " delete all chunk buffers
  for item in getbufinfo()
    if match(item.name, "[chunk tab") >= 0
      eval "bdelete! " . item.name
    endif
  endfor
endfunction

function s:Test_loads_chunks()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)

  AssertBufferMatch << trim EOF
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  EOF
endfunction


function s:Test_loads_next_chunk()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkNext()

  AssertBufferMatch << trim EOF
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  16
  17
  18
  19
  20
  EOF
endfunction

function s:Test_loads_previous_chunk()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkNext()
  call ChunkPrevious()

  AssertBufferMatch << trim EOF
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  EOF
endfunction


function s:Test_jumping_around_chunks_should_not_be_a_problem()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkNext()
  call ChunkNext()
  call ChunkPrevious()
  call ChunkNext()
  call ChunkPrevious()

  AssertBufferMatch << trim EOF
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  16
  17
  18
  19
  20
  EOF
endfunction

function s:Test_loads_last_chunk()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkLast()

  AssertBufferMatch << trim EOF
  86
  87
  88
  89
  90
  91
  92
  93
  94
  95
  96
  97
  98
  99
  100
  EOF
endfunction

function s:Test_loads_first_chunk()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkLast()
  call ChunkFirst()

  AssertBufferMatch << trim EOF
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  EOF
endfunction

function s:Test_loads_chunk_with_line_number()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call ChunkTo('50', tmpfile)

  AssertBufferMatch << trim EOF
  45
  46
  47
  48
  49
  50
  51
  52
  53
  54
  55
  56
  57
  58
  59
  EOF
endfunction

function s:Test_loads_chunk_with_line_number_when_in_first_chunk()
  let g:chunkSize="5"
  let tmpfile = tempname()
  call system('seq 1 100 > ' . tmpfile)
  call Chunk(tmpfile)
  call ChunkTo('7') " empties the buffer and starts at 2 (7-chunkSize)

  AssertBufferMatch << trim EOF
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  16
  EOF
endfunction
