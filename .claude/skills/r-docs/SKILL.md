---
name: r-docs
description: Access R package documentation and learn about packages. Use when exploring packages, finding function help, or understanding package capabilities.
---

# R Documentation

How to discover and access R package documentation.

## BTW MCP Tools (Preferred)

Always use these btw MCP tools first — they provide direct access to R documentation without running R code:

| Tool | Purpose |
|------|---------|
| `btw_tool_docs_help_page` | Get help page for a function (`?pkg::fun`) |
| `btw_tool_docs_package_help_topics` | List all help topics in a package |
| `btw_tool_docs_available_vignettes` | List vignettes for a package |
| `btw_tool_docs_vignette` | Read a vignette in plain text |
| `btw_tool_docs_package_news` | Read package NEWS/changelog |
| `btw_tool_cran_search` | Search for packages on CRAN |
| `btw_tool_cran_package` | Describe a CRAN package |

Only fall back to R commands below if btw tools are unavailable.

## Quick Reference

| Task | Command |
|------|---------|
| Function help | `?dplyr::filter` or `help("filter", package = "dplyr")` |
| Package overview | `help(package = "dplyr")` |
| List vignettes | `vignette(package = "dplyr")` |
| Open vignette | `vignette("dplyr", package = "dplyr")` |
| Search docs | `help.search("linear model")` or `??linear` |
| Function args | `args(dplyr::filter)` |
| Function source | `dplyr::filter` (print without parens) |
| Package news | `news(package = "dplyr")` |

## Function Documentation

```r
# Help for a specific function
?dplyr::filter
help("filter", package = "dplyr")

# See function arguments
args(dplyr::filter)

# See function source code
dplyr::filter
getAnywhere("filter")

# Find methods for a generic
methods("print")
methods(class = "data.frame")
```

## Package Overview

```r
# List all functions in a package
help(package = "dplyr")

# List exported functions
ls("package:dplyr")
getNamespaceExports("dplyr")

# Package description
packageDescription("dplyr")

# Package version
packageVersion("dplyr")

# Package dependencies
tools::package_dependencies("dplyr")
```

## Vignettes

Vignettes are long-form documentation with examples:

```r
# List available vignettes
vignette(package = "dplyr")
browseVignettes("dplyr")

# Open a specific vignette
vignette("dplyr", package = "dplyr")
vignette("programming", package = "dplyr")
```

## Searching Documentation

```r
# Search across all installed packages
help.search("linear model")
??linear

# Search for functions by name pattern
apropos("mean")
apropos("^str")  # starts with "str"

# Find which package a function belongs to
find("filter")
getAnywhere("filter")
```

## Online Resources

### pkgdown Sites

Most tidyverse and r-lib packages have pkgdown sites:

- Pattern: `https://<pkg>.r-lib.org/` or `https://<org>.github.io/<pkg>/`
- Examples:
  - https://dplyr.tidyverse.org/
  - https://rlang.r-lib.org/
  - https://testthat.r-lib.org/

### CRAN Pages

```r
# Open CRAN page in browser
browseURL(paste0("https://cran.r-project.org/package=", "dplyr"))
```

CRAN pages include:
- Reference manual (PDF)
- Vignettes
- NEWS
- Dependencies
- Reverse dependencies

### GitHub/GitLab

Find source code and issues:

```r
# Package URL (if set in DESCRIPTION)
packageDescription("dplyr")$URL
packageDescription("dplyr")$BugReports
```

## Exploring Package Contents

```r
# List datasets in a package
data(package = "ggplot2")

# Load a dataset
data("mpg", package = "ggplot2")

# List all objects (including internal)
ls(getNamespace("dplyr"))

# Check if function is exported
"filter" %in% getNamespaceExports("dplyr")
```

## Understanding Function Behavior

```r
# See default argument values
formals(dplyr::filter)

# Check if function is S3 generic
pryr::is_s3_generic("print")
sloop::is_s3_generic("print")

# Find S3 method for a class
getS3method("print", "data.frame")
sloop::s3_dispatch(print(mtcars))

# See all methods for a generic
methods("print")
sloop::s3_methods_generic("print")
```

## Useful Packages for Exploration

| Package | Purpose |
|---------|---------|
| `sloop` | Understand S3/S4 OOP |
| `pryr` | Inspect R internals |
| `lobstr` | Visualize data structures |
| `pkgapi` | Extract package API |

## Anti-patterns

- **Installing packages without user approval** - always ask before running `install.packages()`
- Using `library()` just to access help (use `?pkg::fun` instead)
- Ignoring vignettes (they often have the best explanations)
- Not checking examples in help pages
- Searching the web before checking built-in docs

## References

- [R Documentation](https://www.rdocumentation.org/)
- [rdrr.io](https://rdrr.io/) - searchable R documentation
- [CRAN Task Views](https://cran.r-project.org/web/views/) - packages by topic