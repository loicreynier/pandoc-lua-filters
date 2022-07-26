# TikZ pictures builder Lua filter

This Lua filter is used to build figures (images with caption)
from a TikZ source file.

## Usage

```markdown
---
tikz-header-includes: >
  \usepackage{pgfplots}
  \pgfplotsset{compat=1.18}
...

# Source document

Here is my sexy figure:

![Sexy caption](sexy/source/file/path.tikz)
```

## Credits

- [Original filter][source] from Pandoc's manual

[source]: https://pandoc.org/lua-filters.html#building-images-with-tikz
