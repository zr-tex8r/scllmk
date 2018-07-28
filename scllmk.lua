#!/usr/bin/env texlua
--
-- This is file 'scllmk.lua'.
--
-- Copyright (c) 2018 Takayuki YATO (aka. "ZR")
--   GitHub:   https://github.com/zr-tex8r
--   Twitter:  @zr_tex8r
--
-- This package is distributed under the MIT License.
--
prog_name = 'scllmk'
version = '0.3.1'
mod_date = "2018-07-29"
---------------------------------------- global parameters
verbose = 0
in_files = nil
color = {}
color_snowman = {
  muffler = 'red', fore = 'black', back = 'white'
}
color_duck = {
  muffler = 'black', fore = 'white', back = 'blue!90!green!70!black!50'
}
show_debug = {
  config = false, parser = false, zr = false
}
default_name = "scllmk"
---------------------------------------- helpers
require 'lfs'
unpack = unpack or table.unpack
do

  function str(val)
    return (type(val) == "table") and "{"..concat(val, ",").."}"
        or tostring(val)
  end
  function concat(tbl, ...)
    local t = {}
    for i = 1, #tbl do t[i] = str(tbl[i]) end
    return table.concat(t, ...)
  end
  function merged(tbl1, tbl2)
    local t = {}
    for k, v in pairs(tbl1) do t[k] = tbl2[k] or tbl1[k] end
    return t
  end

  function read_whole(fname)
    local f = sure(io.open(fname, 'rb'),
      "Can't read from file \"%s\"", fname)
    local ret = f:read("*a") or ""
    f:close()
    return ret
  end
  function write_whole(fname, data)
    local f = sure(io.open(fname, 'wb'),
      "Can't write to file \"%s\"", fname)
    f:write(data)
    f:close()
  end

end
---------------------------------------- catalog
do
  local meta_catalog = {
    __newindex = function(tbl, key, val)
      table.insert(tbl._data, {key, val})
    end;
    __pairs = function(tbl)
       local iter, data, z = ipairs(tbl._data)
       return function(tbl, k)
         local k, v = iter(tbl, k)
         return k, table.unpack(v or {})
       end, data, z
     end
  }
  function make_catalog()
    return setmetatable({_data={}}, meta_catalog)
  end
end
---------------------------------------- logging
do
  local es_ok, es_err, es_err_parse, es_failure =  0, 1, 2, 3

  local function log(level, label, fmt, ...)
    if level and verbose < level then return end
    io.stderr:write(prog_name.." "..label..": "..fmt:format(...).."\n")
  end
  function finish() os.exit(os.ok) end
  function info(...) log(1, 'info', ...) end
  function warn(...) log(1, 'warning', ...) end
  function abort(es, ...) log(nil, 'error', ...); os.exit(es) end
  function debug(kind, ...)
    if show_debug[kind] then log(nil, 'debug-'..kind, ...) end
  end

  function sure(val, ...)
    if val then return val else abort(es_err, ...) end
  end

end
---------------------------------------- essential source
do
  local source_snowman = [[
% <NAME>.tex
\RequirePackage{luatex85}
\documentclass{article}
\usepackage[papersize={100mm,100mm},margin=0mm,noheadfoot]{geometry}
\usepackage{xcolor,scsnowman,fontspec}
\setmainfont{IPAexGothic}
\color{<FORE>}
\pagecolor{<BACK>}
\begin{document}
\fontsize{32pt}{32pt}\selectfont
\centering\vspace*{5mm}
\makebox[80mm][s]{^^^^3086\hfill
  \raisebox{4mm}{^^^^304d}\hfill
  \raisebox{6mm}{^^^^3060}\hfill
  \raisebox{4mm}{^^^^308b}\hfill 
  ^^^^307e}
\vfill
\scsnowman[hat,arms,snow,buttons,scale=6,muffler=<MUFFLER>]
\par\vspace*{7mm}
\end{document}
]]
  local source_duck = [[
% <NAME>.tex
\RequirePackage{luatex85}
\documentclass{article}
\usepackage[papersize={100mm,100mm},margin=0mm,noheadfoot]{geometry}
\usepackage{graphicx,xcolor,tikzducks,fontspec}
\setmainfont{IPAexGothic}
\color{<FORE>}
\pagecolor{<BACK>}
\begin{document}
\fontsize{32pt}{32pt}\selectfont
\centering\vspace*{5mm}
\makebox[80mm][s]{^^^^3086\hfill
  \raisebox{4mm}{^^^^304d}\hfill
  \raisebox{6mm}{^^^^30a2}\hfill
  \raisebox{4mm}{^^^^30d2}\hfill 
  ^^^^30eb}
\vfill
\scalebox{2.5}{\begin{tikzpicture}
\duck[body=white,eye=white,tophat=black,buttons=black]
\draw[very thick,<MUFFLER>] (0.9,0.3) -- (1.2,1) (1.2,1) --
(1,1.3) (1.2,1) -- (1.3,1.3) (1.2,1) -- (1.5,1.4)
(1.32,1.15) -- (1.6,1.3);
\end{tikzpicture}}
\par\vspace*{7mm}
\end{document}
]]

  function make_source(name)
    local src, c
    if name:lower():match('duck') then
      src, c = source_duck, merged(color_duck, color)
    else
      src, c = source_snowman, merged(color_snowman, color)
    end
    return (src:gsub('<(%w+)>', {
      NAME = name, MUFFLER = c.muffler, FORE = c.fore, BACK = c.back
    }))
  end

end
---------------------------------------- process
do

  local temp_base = nil
  local function get_temp_base()
    if not temp_base then
      for i = 1, 99 do
        local ok, b = true, ("%s_%02d"):format(default_name, i)
        for _, e in ipairs{'.tex', '.aux', '.log', '.pdf'} do
          if lfs.attributes(b..e, 'ino') then ok = false end
        end
        if ok then temp_base = b; break end
      end
    end
    return sure(temp_base, "Can't get temp file base.")
  end

  local function run(command)
    info("Running %s", command)
    local ok, r1, r2 = os.execute(command)
    if type(ok) == 'number' then return ok end
    return (not ok and r2 == 0) and 1 or r2
  end

  function process(pname)
    if lfs.isfile(pname) then
      debug('config', "Fetching NOTHING from the file \"%s\".", pname)
    else
      info("No file \"%s\" found (that's no matter).", pname)
    end

    local pbase = pname:gsub('%.%w+$', '')
    local fbase = pbase:gsub('^.*[/\\]', ''):gsub('[\128-\255]', '?')
    local tbase = get_temp_base()
    debug('zr', "temp base = \"%s\", base = \"%s\"", tbase, fbase)

    info("Begining a sequence for \"%s\"", pname)
    write_whole(tbase..'.tex', make_source(fbase))
    local cmd = "lualatex -halt-on-error -interaction=nonstopmode"..
        " -no-shell-escape "..tbase
    local ces = run(cmd)
    local ok = (ces == 0) and lfs.isfile(tbase..'.pdf')
    if ok then
      write_whole(pbase..'.pdf', read_whole(tbase..'.pdf'))
      os.remove(pbase..'.log')
    else
      write_whole(pbase..'.log', read_whole(tbase..'.log'))
    end

    for _, v in ipairs{'.tex', '.aux', '.log', '.pdf'} do
      os.remove(tbase..v)
    end
    if not ok then
      abort(es_failure, "Fail running %s (exit code: %s)", cmd, ces)
    end
  end

end
---------------------------------------- main
do

  local function show_usage()
    io.stdout:write(([[
Usage: %s[.lua] [OPTION...] [FILE...]

Options:
  -h, --help            Print this help message.
  -V, --version         Print the version number.

  -q, --quiet           Suppress warnings and most error messages.
  -v, --verbose         Print additional information.
  -D, --debug           Activate all debug output (equal to "--debug=all").
  -d CAT, --debug=CAT   Activate debug output restricted to CAT.

  -m COLOR, --muffler=COLOR Set muffler color.
  -b COLOR, --back=COLOR    Set background color.
  -f COLOR, --fore=COLOR    Set foreground color.

Please report bugs to <https://github.com/zr-tex8r/scllmk/issues>.
]]):format(prog_name))
    finish()
  end

  local function show_version()
    io.stdout:write(([[
%s %s

Copyright 2018 T.Yato (aka 'ZR').
License: The MIT License <https://opensource.org/licenses/mit-license>.
This is free software: you are free to change and redistribute it.
]]):format(prog_name, version))
    finish()
  end

  -- cf. Alternative Get Opt http://lua-users.org/wiki/AlternativeGetOpt
  local function getopt( arg, options )
    local tab, nonopt, skip = make_catalog(), {}, false
    for k, v in ipairs(arg) do
      if string.sub( v, 1, 2) == "--" then
        local x = string.find( v, "=", 1, true )
        if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
        else      tab[ string.sub( v, 3 ) ] = true
        end
      elseif string.sub( v, 1, 1 ) == "-" then
        local y = 2
        local l = string.len(v)
        local jopt
        while ( y <= l ) do
          jopt = string.sub( v, y, y )
          if string.find( options, jopt, 1, true ) then
            if y < l then
              tab[ jopt ] = string.sub( v, y+1 )
              y = l
            else
              tab[ jopt ] = arg[ k + 1 ]
              skip = true
            end
          else
            tab[ jopt ] = true
          end
          y = y + 1
        end
      else -- non-option
        if skip then skip = false
        else table.insert(nonopt, v)
        end
      end
    end
    return tab, nonopt
  end

  local function sanitize_color(name)
    return name:gsub('[^%w%-%+%.:,;!]', '?')
  end

  local function read_option()
    local opt, files = getopt(arg, 'dmfb')
    local action = nil
    for _, key, val in pairs(opt) do
      local option = ((#key > 1) and '--' or '-')..key
      local function required(val)
        sure(val and val ~= true, "no value given for option: %s", option)
        return val
      end
      if key == 'h' or key == 'help' then
        action = 'help'
      elseif key == 'V' or key == 'version' then
        action = 'version'
      elseif key == 'D' or
          (key == 'debug' and (val == 'all' or val == true)) then
        for k in pairs(show_debug) do show_debug[k] = true end
      elseif key == 'd' or key == 'debug' then
        if show_debug[val] ~= nil then show_debug[val] = true
        else warn("unknown debug category: %s", val)
        end
      elseif key == 'q' or key == 'quiet' then
        verbose = -1
      elseif key == 'v' or key == 'verbose' then
        verbose = 1
      elseif key == 'm' or key == 'muffler' then
        color.muffler = sanitize_color(required(val))
      elseif key == 'f' or key == 'fore' then
        color.fore = sanitize_color(required(val))
      elseif key == 'b' or key == 'back' then
        color.back = sanitize_color(required(val))
      else
        abort(es_err, "unknown option: %s", option)
      end
    end
    if action == 'help' then show_usage()
    elseif action == 'version' then show_version()
    end
    in_files = files
  end

  function main()
    read_option()
    if #in_files == 0 then
      in_files[1] = default_name
    end
    for _, fname in ipairs(in_files) do
      process(fname)
    end
  end

end
---------------------------------------- done
main()
-- EOF
