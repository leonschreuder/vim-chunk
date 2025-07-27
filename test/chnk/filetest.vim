UTSuite chunk.vim

function! s:BeforeAll()
  source autoload/chnk/file.vim
endfunction


function s:Test_should_make_special_tmp_file_with_extension()

  let result = chnk#file#getChunkTmpFile("/home/user/somedir/bigfile.txt")

  AssertEquals(chnk#file#getTempdir() . "/bigfile-chunk.txt" , result)
endfunction


function s:Test_should_split_and_join_paths()

  let splitResult = chnk#file#splitpath("/home/user/somedir/bigfile.txt")
  AssertEquals(["", "home","user","somedir","bigfile.txt"], splitResult)

  let joinResult = chnk#file#joinpath(["", "home","user","somedir","bigfile.txt"])
  AssertEquals("/home/user/somedir/bigfile.txt", joinResult)
endfunction


function s:Test_should_write_lines_to_file()
  let tmpFileBig = tempname()
  let tmpFileSmall = tempname()
  call system('seq 1 100 > ' . tmpFileBig)

  call chnk#file#sendLinesToFile(tmpFileBig, tmpFileSmall, 10, 20)

  AssertEquals(['10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'], readfile(tmpFileSmall))
  
endfunction

function s:Test_should_allow_updating_main_file_from_cunk_file()
  let tmpFileBig = tempname()
  let tmpFileSmall = tempname()
  call system('seq 1 15 > ' . tmpFileBig)
  call chnk#file#sendLinesToFile(tmpFileBig, tmpFileSmall, 5, 10)

  " modify the file, like someone deleting some lines and changing some others
  call system('echo "5" > ' . tmpFileSmall)
  call system('echo "A" >> ' . tmpFileSmall)
  call system('echo "10" >> ' . tmpFileSmall)

  call chnk#file#updateLinesFromFile(tmpFileBig, tmpFileSmall, 5, 10)
  AssertEquals(['5', 'A', '10'], readfile(tmpFileSmall))
  AssertEquals(['1', '2' , '3', '4', '5', 'A', '10', '11', '12', '13', '14', '15'], readfile(tmpFileBig))
  
endfunction

