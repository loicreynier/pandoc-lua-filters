--[[
center - center the text (bruh)

This Lua filter add a `center` class to be used to create centered blocks:

```
::: center
Centered text
:::
```

]]

local center_for = {
  latex = {
    pre = pandoc.RawBlock("latex", "\\begin{center}"),
    post = pandoc.RawBlock("latex", "\\end{center}"),
  },
  beamer = {
    pre = pandoc.RawBlock("latex", "\\begin{center}"),
    post = pandoc.RawBlock("latex", "\\end{center}"),
  },
}

function Div(div)
  if div.classes:includes("center") then
    if center_for[FORMAT] then
      local el = {}
      if center_for[FORMAT].pre then
        el[#el + 1] = center_for[FORMAT].pre
      end
      el[#el + 1] = div
      if center_for[FORMAT].post then
        el[#el + 1] = center_for[FORMAT].post
      end
      return el
    end
  end
  return nil
end
