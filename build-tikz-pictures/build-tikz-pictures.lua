--[[
build-tikz-pictures - build TikZ figures from TikZ source files.

This Lua filter is used to build figures (images with caption)
from a TikZ source file using  Markdown syntax:

  `![Caption](source/file/path.tikz)`

TikZ source file must have a `.tikz` extension.
]]

local system = require("pandoc.system")
local utils = require("pandoc.utils")

--- Convert data to string
-- @param s element to convert.
local function stringify(s)
  return type(s) == "string" and s or utils.stringify(s)
end

local tikz_header_includes = ""

--- LaTeX template used to compile TikZ images.
-- Takes `header-includes` as first the argument
-- and the actual TikZ code as the second argument.
local tikz_latex_template = [[
\documentclass[crop,tikz]{standalone}
%s
\begin{document}
%s
\end{document}
]]

-- Beamer template used to compile TikZ images.
--- Takes `header-includes` as first the argument
-- and the actual TikZ code as the second argument.
local tikz_beamer_template = [[
\documentclass[beamer,crop,tikz]{standalone}
%s
\begin{document}
%s
\end{document}
]]

template_for = {
  latex = tikz_latex_template,
  beamer = tikz_beamer_template,
}

local tikz_doc_template = template_for[FORMAT] or tikz_latex_template

extension_for = {
  docx = "png",
  html = "svg",
  html4 = "svg",
  html5 = "svg",
  latex = "pdf",
  beamer = "pdf",
}

function Meta(meta)
  tikz_header_includes = stringify(
    meta["tikz-header-includes"] or tikz_header_includes
  )
end

--- Build image with TikZ.
-- @param src TikZ sources.
-- @param filetype Output file type.
-- @param outfile_name Output file path.
local function tikz2image(src, filetype, outfile_name)
  shaname = pandoc.sha1(src)
  srcfile_name = shaname .. ".tex"
  pdffile_name = shaname .. ".pdf"
  local f = io.open(srcfile_name, "w")
  f:write(tikz_doc_template:format(tikz_header_includes, src))
  f:close()
  os.execute("lualatex " .. srcfile_name)
  if filetype == "pdf" then
    os.rename(pdffile_name, outfile_name)
  else
    os.execute("pdf2svg " .. pdffile_name .. " " .. outfile_name)
  end
  os.execute("rm " .. shaname .. "*")
end

--- Whether file exists.
-- @param path File to check.
local function file_exists(path)
  local file = io.open(path, "r")
  if file ~= nil then
    io.close(file)
    return true
  else
    return false
  end
end

--- Figure label associted with given path.
-- Label corresponds to the file basename with dashes converted to
-- underscores.
-- @param path File path converted to label.
-- @return Figure label.
local function fig_label(path)
  basename = path:gsub("(.*/)(.*)", "%2"):match("(.+)%..+$")
  return "fig:" .. basename:gsub("%-", "_")
end

function Image(img)
  -- Ignore images whose source is not a `.tikz` file
  if img.src:match("(%..*)$") ~= ".tikz" then
    return
  end

  -- Set output filetype
  local filetype = extension_for[FORMAT] or "svg"

  local srcfile_path = img.src
  local outfile_path = "build/"
    .. FORMAT
    .. "/"
    .. srcfile_path:match("^.+/(.+)$")
    .. "."
    .. filetype
  local srcfile = io.open(srcfile_path)
  if not srcfile then
    io.stderr:write(
      "Cannot open file " .. srcfile_path .. " | Skipping image\n"
    )
    return
  else
    if not file_exists(outfile_path) then
      tikz2image(srcfile:read("*a"), filetype, outfile_path)
    end
  end
  srcfile:close()

  local attr = img.attr
  local attributes = img.attributes
  img = pandoc.Image(img.caption, outfile_path, "fig:", fig_label(img.src))
  -- Dirty hack to set old attributes to the new image object.
  -- Couldn't figure out how to pass them to the above constructor.
  img.attr.classes = attr.classes
  img.attributes = attributes
  return img
end

-- Custom Pandoc execution order to parse metadata before images
return {
  { Meta = Meta },
  { Image = Image },
}
