#!/usr/bin/env texlua
--
-- This is file 'scllmk.lua'.
--
-- Copyright (c) 2018-2021 Takayuki YATO (aka. "ZR")
--   GitHub:   https://github.com/zr-tex8r
--   Twitter:  @zr_tex8r
--
-- This package is distributed under the MIT License.
--
prog_name = 'scllmk'
version = '0.8.0'
mod_date = '2021-04-24'
---------------------------------------- global parameters
verbose = 0
dry_run = false
silent = false
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
random = math.random
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
    if dry_run then return "" end
    local f = sure(io.open(fname, 'rb'),
      "Can't read from file \"%s\"", fname)
    local ret = f:read("*a") or ""
    f:close()
    return ret
  end
  function write_whole(fname, data)
    if dry_run then return end
    local f = sure(io.open(fname, 'wb'),
      "Can't write to file \"%s\"", fname)
    f:write(data)
    f:close()
  end

  function remove_file(fname)
    if dry_run then return true end
    return os.remove(fname)
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
  function errorlog(...) log(nil, 'error', ...) end
  function abort(es, ...) log(nil, 'error', ...); os.exit(es) end
  function debug(kind, ...)
    if show_debug[kind] then log(nil, 'debug-'..kind, ...) end
  end

  function dryinfo(msg)
    io.stdout:write(("Dry running: %s\n"):format(msg))
  end

  function sure(val, ...)
    if val then return val else abort(es_err, ...) end
  end

end
---------------------------------------- random color
do
  local hue = {
    {1, 1, 0}, {0, 1, 0}, {0, 1, 1}, {0, 0, 1}, {1, 0, 1}, {1, 0, 0}
  }
  hue[0] = hue[#hue]
  function random_color()
    local c, h = {}, random() * #hue; local hi = math.floor(h)
    local h0, h1, hf = hue[hi], hue[hi + 1], h - hi
    for i = 1, 3 do
      c[i] = (random() * 0.4 + 0.6) * (h0[i] * (1 - hf) + h1[i] * hf)
    end
    local y0 = 0.299 * c[1] + 0.587 * c[2] + 0.114 * c[3]
    local y1 = random() * 0.1 + 0.4
    for i = 1, 3 do
      v = c[i] * ((y1 / y0) ^ 0.8)
      c[i] = (v > 1) and 1 or (v < 0) and 0 or v
    end
    return unpack(c)
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
<RANDCOLOR>\color{<FORE>}
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
<RANDCOLOR>\color{<FORE>}
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
    local randcolor, src, c = ''
    if name:lower():match('duck') then
      src, c = source_duck, merged(color_duck, color)
    else
      src, c = source_snowman, merged(color_snowman, color)
    end
    if concat({c.muffler, c.fore, c.back}, ' '):match('random') then
      randcolor = ("\\definecolor{random}{rgb}{%.3f,%.3f,%.3f}\n")
          :format(random_color())
    end
    return (src:gsub('<(%w+)>', {
      NAME = name, MUFFLER = c.muffler, FORE = c.fore, BACK = c.back,
      RANDCOLOR = randcolor
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
        for _, e in ipairs{'.tex', '.aux', '.log', '.pdf', '.out', '.err'} do
          if lfs.attributes(b..e, 'ino') then ok = false end
        end
        if ok then temp_base = b; break end
      end
    end
    return sure(temp_base, "Can't get temp file base.")
  end

  local function run(command)
    if dry_run then
      dryinfo(command)
      return 0
    end
    info("Running command: %s", command)
    local ok, r1, r2
    if silent then
      local t = get_temp_base()
      local redirect = ' 1>'..t..'.out 2>'..t..'.err'
      ok, r1, r2 = os.execute(command..redirect)
      os.remove(t..'.out'); os.remove(t..'.err')
    else
      ok, r1, r2 = os.execute(command)
    end
    if type(ok) == 'number' then return ok end
    return (not ok and r2 == 0) and 1 or r2
  end

  local function prepare(pname)
    if lfs.isfile(pname) then
      debug('config', "NOT Looking for config in the file \"%s\"", pname)
    else
      info("Source file \"%s\" does not exist (that's no matter)", pname)
    end

    local pbase = pname:gsub('%.[^%./\\]*$', '')
    return pbase
  end

  local function process_build(pname, pbase)
    local fbase = pbase:gsub('^.*[/\\]', ''):gsub('[\128-\255]', '?')
    local tbase = get_temp_base()
    debug('zr', "temp base = \"%s\", base = \"%s\"", tbase, fbase)

    info("Beginning a sequence for \"%s\"", pname)
    write_whole(tbase..'.tex', make_source(fbase))
    local cmd = "lualatex -halt-on-error -interaction=nonstopmode"..
        " -no-shell-escape "..tbase
    local ces = run(cmd)
    local ok = dry_run or ((ces == 0) and lfs.isfile(tbase..'.pdf'))
    if ok then
      write_whole(pbase..'.pdf', read_whole(tbase..'.pdf'))
      remove_file(pbase..'.log')
    else
      write_whole(pbase..'.log', read_whole(tbase..'.log'))
    end

    for _, v in ipairs{'.tex', '.aux', '.log', '.pdf'} do
      remove_file(tbase..v)
    end
    if not ok then
      abort(es_failure, "Fail running %s (exit code: %s)", cmd, ces)
    end
  end

  local function remove(pname)
    if not lfs.isfile(pname) then return end
    if dry_run then
      dryinfo("removing file \""..pname.."\"")
      return
    end
    if remove_file(pname) then
      info("Removed \"%s\"", pname)
    else
      errorlog("Failed to remove \"%s\"", pname)
    end
  end

  local function process_clean(pname, pbase)
    info("Begining cleaning for \"%s\"", pname)
    remove(pbase..'.log')
  end
  local function process_clobber(pname, pbase)
    info("Begining clobbering for \"%s\"", pname)
    remove(pbase..'.log')
    remove(pbase..'.pdf')
  end

  function process(pname, action)
    local pbase = prepare(pname)
    if action == 'clean' then
      process_clean(pname, pbase)
    elseif action == 'clobber' then
      process_clobber(pname, pbase)
    else
      process_build(pname, pbase)
    end
  end

end
---------------------------------------- main
do

  local function show_usage()
    io.stdout:write(([[
Usage: %s[.lua] [OPTION]... [FILE]...

Options:
  -c, --clean           Remove the temporary files such as aux and log files.
  -C, --clobber         Remove all generated files including final PDFs.
  -d CAT, --debug=CAT   Activate debug output restricted to CAT.
  -D, --debug           Activate all debug output (equal to "--debug=all").
  -h, --help            Print this help message.
  -n, --dry-run         Show what would have been executed.
  -q, --quiet           Suppress most messages.
  -s, --silent          Silence messages from called programs.
  -v, --verbose         Print additional information.
  -V, --version         Print the version number.

  --muffler=COLOR       Set muffler color.
  --back=COLOR          Set background color.
  --fore=COLOR          Set foreground color.

Please report bugs to <https://github.com/zr-tex8r/scllmk/issues>.
]]):format(prog_name))
    finish()
  end

  local function show_version()
    io.stdout:write(([[
%s %s

Copyright 2018-2020 T.Yato (aka 'ZR').
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
    local opt, files = getopt(arg, 'd')
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
      elseif key == 'c' or key == 'clean' then
        action = 'clean'
      elseif key == 'C' or key == 'clobber' then
        action = 'clobber'
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
      elseif key == 's' or key == 'silent' then
        silent = true
      elseif key == 'n' or key == 'dry-run' then
        dry_run = true
      elseif key == 'muffler' then
        color.muffler = sanitize_color(required(val))
      elseif key == 'fore' then
        color.fore = sanitize_color(required(val))
      elseif key == 'back' then
        color.back = sanitize_color(required(val))
      else
        abort(es_err, "unknown option: %s", option)
      end
    end
    if action == 'help' then show_usage()
    elseif action == 'version' then show_version()
    end
    in_files = files
    return action
  end

  function main()
    local action = read_option()
    if #in_files == 0 then
      in_files[1] = default_name
    end
    for _, fname in ipairs(in_files) do
      process(fname, action)
    end
  end

end
---------------------------------------- done
main()
-- EOF
