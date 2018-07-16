SCllmk: SC-Variant of [llmk] (the Light LaTeX Make)
---------------------------------------------------

[llmk]: https://github.com/wtsnjp/llmk

![Snowman Status](https://raw.githubusercontent.com/zr-tex8r/scllmk/badge/snowman-nice-green.png)
![TeX Status](https://raw.githubusercontent.com/zr-tex8r/scllmk/badge/TeX-are-red.png)

This is yet another *essential* tool for Snowman Comedians. The features of **scllmk** are:

* works solely with texlua,
* the source file can be in TOML, YAML, JSON, XML, LaTeX, SATySFi, or
  any other format; or can be free mixture of those formats,
* the source file even need not exist since the content or existence of the
  source files is not *essential* at all,
* no complicated or simplistic configuration, and
* modern fixed settings (always using LuaTeX!)


## Basic Usage

The basic (but not easiest) way to use **scllmk** is to write arbitrary text to your source file. The text can be written in an arbitrary format.

Here's a very simple example:

    HELLO **scllmk**!
    -----------------
    * list item
    ** nested list item
    Oops, Markdown doesn't go that way, I suspect....

Suppose we save this file as `hello.rst`, then run

    $ scllmk hello.rst

will produce an *essential* PDF document (`hello.pdf`) with LuaLaTeX since it is so supposed.

You can find other example document files in the [examples](./examples) directory.

## Advanced Usage

### Using No Files

Alternatively, you can do without any tiresome work to write source files.

If you run scllmk without any argument, scllmk will assume the target file name is `scllmk.pdf`, and compile (possibly nonexistent) source files to produce that file.

    $ scllmk

### Custom Muffler Color

You can setup custom muffler colors for snowman figures; use the `--muffler` option to specify the name of the muffler color in the form of the “color expression” as defined in the LaTeX xcolor package.

### For Duck Enthusiasts

Because of the author’s personal preference, the *essential* thing will usually come as a snowman, but it is very easy to get duck consequence; name your source file with a string containing `duck`.

## License

This package released under [the MIT license](./LICENSE).

--------------------
Takayuki YATO (aka. "ZR")  
https://github.com/zr-tex8r
