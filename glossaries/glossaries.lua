local function starts_with(start, str)
  return str:sub(1, #start) == start
end

function Span(span)
  local text = span.content[1].text
  if not starts_with("+", text) then
    return
  end
  text = string.sub(text, 2)
  local command = "gls"
  if span.classes:includes("plural") then
    command = command .. "pl"
  end
  if span.classes:includes("caps") then
    command = command:gsub("%a", string.upper, 1)
  end
  return pandoc.RawInline("tex", string.format("\\%s{%s}", command, text))
end

function Str(str)
  front, acr, back = str.text:match("(%g*)%[%+(%g*)%](%g*)")
  if not acr then
    return
  end
  return pandoc.RawInline(
    "tex",
    string.format("%s\\%s{%s}%s", front, "gls", acr, back)
  )
end
