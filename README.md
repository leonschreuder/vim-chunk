# vim-chunk

Read huge files in chunks

Vim runs in to problems when you want to read really really big files.
Generally some features, like syntax highlighting, indentation etc, make vim
unresponsive with big files.

You can disable some features, or use the
[BigFile](https://github.com/LunarVim/bigfile.nvim) to do it for you, but
another way to solve the problem would be to simply not read the entire file in
at once, but Chunking it.

This plugin provides the following Commands:

`:Chunk <file>`  - Read the provided file in chunks
`:ChunkNext`     - Load the next Chunk into the buffer
`:ChunkPrevious` - Load the previous Chunk into the buffer

