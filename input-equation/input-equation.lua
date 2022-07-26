--[[
input-equation - add LaTeX equations as images.

This Lua filter is used to add LaTeX equations to document
using the same syntax as for images:

  `![Label](source/file/path.eq.tex)`.

Equations source file must have a `.eq.tex` extension.
]]

function Image(img)
  if img.src:match("(%..*)$") ~= ".eq.tex" then
    return
  end
  return pandoc.RawInline("tex", "\\input{" .. img.src .. "}\\unskip")
end
