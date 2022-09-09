--[[
beamer-highlight - add Beamer alert highlighting

This Lua filter add a `alert` class to be used to add Beamer alert
highlighting.

```
This [word]{.alert}
```

]]

if FORMAT:match("beamer") then
  function Span(el)
    if el.classes[1] == "alert" then
      table.insert(el.content, 1, pandoc.RawInline("latex", "\\alert{"))
      table.insert(el.content, pandoc.RawInline("latex", "}"))
    end
    return el
  end
  return { { Span = Span } }
end
