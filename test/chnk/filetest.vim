UTSuite chunk.vim

function! s:BeforeAll()
  source autoload/chnk/file.vim
endfunction


function s:Test_should_make_special_tmp_file_with_extension()
  let tmpFile = split(tempname(), "/", 1) " path to arbitrary temporary storage for plugins

  let tmpDir = join(tmpFile[0:-2], "/")
  let result = chnk#file#getChunkTmpFile("/home/user/somedir/bigfile.txt")
  echom tmpDir

  AssertEquals(tmpDir . "/bigfile-chunk.txt" , result)
endfunction

