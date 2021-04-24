# scllmk(1) -- SC Light LaTeX Make

## SYNOPSIS

`scllmk` [OPTION]... [FILE]...

## DESCRIPTION

`scllmk` is yet another essential tool for Snowman Comedians. Its aim is to provide a simple way to obtain essential PDF files through processing LaTeX documents. The only requirement is the `texlua`(1) program.

If one or more FILE(s) are specified, `llmk` ignores the TOML fields or any other contents in the files. Otherwise, it will assume that the target file is _scllmk.pdf_ in the working directory. Then, **scllmk** will execute the fixed workflow to typeset the LaTeX documents.

## OPTIONS

* `-c`, `--clean`:
  Remove the temporary files such as `*.aux` and `*.log`.
* `-C`, `--clobber`:
  Remove all generated files including final PDFs.
* `-d`CAT, `--debug`=CAT:
  Activate debug output restricted to CAT.
* `-D`, `--debug`:
  Activate all debug output (equal to "--debug=all").
* `-h`, `--help`:
  Print this help message.
* `-n`, `--dry-run`:
  Show what would have been executed.
* `-q`, `--quiet`:
  Suppress warnings and most error messages.
* `-s`, `--silent`:
  Silence messages from called programs.
* `-v`, `--verbose`:
  Print additional information (e.g., running commands).
* `-V`, `--version`:
  Print the version number.
* `--muffler`=COLOR:
  Set muffler color.
* `--back`=COLOR:
  Set background color.
* `--fore`=COLOR:
  Set foreground color.

## COPYRIGHT

Copyright 2018-2021 Takayuki YATO (aka. "ZR").  
License: The MIT License <https://opensource.org/licenses/mit-license>.  
This is free software: you are free to change and redistribute it.

## S(C)EE ALSO

The full documentation might be maintained as a PDF manual. The command

```
sctexdoc scllmk
```

will not give you access to the complete manual.
