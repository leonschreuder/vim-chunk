
fu! chnk#file#load(file)
  let g:chunkFile = a:file
  let g:chunkTmpFile = chnk#file#getChunkTmpFile(a:file)
  let g:chunkFileLines = trim(system("wc -l < " . a:file))
endfu

" Finds vim's tmpdir, and creates a tempfile matching the provided file's name.
fu! chnk#file#getChunkTmpFile(file)
  let tmpDir = chnk#file#getTempdir()
  let fileName = chnk#file#splitpath(a:file)[-1:][0]
  if fileName =~ "\\."
    let split = split(fileName, "\\.")
    let basename = join(split[0:-2], ".")
    let extension = split[-1]
    let chunkFileName = basename . "-chunk" . '.' . extension
  else
    let chunkFileName = fileName . "-chunk"
  endif

  return chnk#file#joinpath([tmpDir, chunkFileName])
endfu

fu! chnk#file#getTempdir()
  " tmpname() will generate a unique file, in temp directory for this session
  " So get the temp directory by generating a file and getting the parent
  return chnk#file#joinpath(chnk#file#splitpath(tempname())[0:-2])
endfu

" Split path into an array on the fileseparator. First element is empty for
" absolute paths
fu! chnk#file#splitpath(file)
  return split(a:file, "[/\\\\]", 1)
endfu

" joins a list of paths with the path separator
fu! chnk#file#joinpath(fileList)
  return join(a:fileList, "/") " no need to treat windows paths here as vim uses unix paths internally
endfu

" reads the lines between 'start' and 'end' from inFile, and write them to outFile
fu! chnk#file#sendLinesToFile(inFile, outFile, start, end)
  echom system("sed -n " . a:start . "," . a:end . "p " . a:inFile . " > " . a:outFile)
endfu

" reverse of sendLinesToFile. It updates the section between start and end,
" with the content of the fileWithModifiedChunk
fu! chnk#file#updateLinesFromFile(sourceFileToUpdate, fileWithModifiedChunk, start, end)
  let tmpFile = tempname()
  let lastLineOfFirstBlock = a:start - 1
  let firstLineOfLastBlock = a:end + 1
  " copy first block before the section we pulled out, into a tmpFile
  let command = "head -" . lastLineOfFirstBlock . " " . a:sourceFileToUpdate . " > " . tmpFile
  " copy the updated file to the tmpFile next
  let command .= "; cat " . a:fileWithModifiedChunk . " >> " . tmpFile
  " copy last block after the section we pulled out, into the tmpFile
  let command .= "; tail +" . firstLineOfLastBlock . " " . a:sourceFileToUpdate . " >> " . tmpFile
  " replace the sourfile with the update content from the tmpfile
  let command .= "; mv " . tmpFile . " " . a:sourceFileToUpdate
  echom system(command)
endfu
