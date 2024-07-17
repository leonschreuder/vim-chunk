
fu! chnk#file#load(file)
  let g:chunkFile = a:file
  let g:chunkTmpFile = chnk#file#getChunkTmpFile(a:file)
  let g:chunkFileLines = trim(system("wc -l < " . a:file))
endfu

" Finds vims tmpdir creates a tempfile matching the provided file's name.
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
  return chnk#file#joinpath(chnk#file#splitpath(tempname())[0:-2])
endfu

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
