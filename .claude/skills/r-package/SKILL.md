---
name: r-package
description: Develop R packages following best practices. Use when creating packages, writing package functions, documentation, or tests.
---

# R Package Development

Build R packages following tidyverse and CRAN best practices.

## Package Structure

```
mypkg/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   └── *.R
├── man/
│   └── *.Rd
├── tests/
│   └── testthat/
├── vignettes/
└── inst/
```

## Core Rules

1. **Never use `library()` or `require()`** in package code
2. **Always use `pkg::fun()` syntax** for external functions
3. **Use roxygen2** for documentation and NAMESPACE management
4. **Run `devtools::check()`** before committing

## Dependencies

### DESCRIPTION Imports

```
Imports:
    dplyr (>= 1.0.0),
    rlang,
    cli
```

### Using Dependencies in Code

```r
# Good - explicit namespace
my_function <- function(df) {
  df |>
    dplyr::filter(x > 0) |>
    dplyr::mutate(y = x * 2)
}

# Bad - relies on attached package
my_function <- function(df) {
  df |>
    filter(x > 0) |>
    mutate(y = x * 2)
}
```

## Documentation (roxygen2)

```r
#' Calculate the mean of positive values
#'
#' @param x A numeric vector.
#' @param na.rm Logical. Remove NA values? Default `TRUE`.
#'
#' @return A single numeric value.
#' @export
#'
#' @examples
#' positive_mean(c(-1, 2, 3, NA))
positive_mean <- function(x, na.rm = TRUE) {
  x <- x[x > 0]
  mean(x, na.rm = na.rm)
}
```

### Key Tags

- `@export` - make function available to users
- `@param` - document each parameter
- `@return` - describe return value
- `@examples` - runnable examples
- `@noRd` - internal function, no documentation
- `@keywords internal` - document but hide from index

## File Organization

- One main function per file, or group related functions
- File name matches primary function: `positive_mean.R`
- Helper functions can share file with main function
- `R/utils.R` for small utilities used across functions

## Error Handling

Use rlang/cli for informative errors:

```r
my_function <- function(x) {
  if (!is.numeric(x)) {
    cli::cli_abort(
      "{.arg x} must be numeric, not {.obj_type_friendly {x}}."
    )
  }
  # ...
}
```

## State Management

Use withr for temporary state changes:

```r
# Good
my_function <- function() {
  withr::local_options(list(digits = 3))
  withr::local_envvar(c(TZ = "UTC"))
  # code runs with modified state
  # state automatically restored on exit
}

# Bad
my_function <- function() {
  old <- options(digits = 3)
  on.exit(options(old))
  # ...
}
```

## Testing (testthat)

### Test File Structure

```
tests/
├── testthat.R
└── testthat/
    ├── test-positive-mean.R
    └── test-utils.R
```

### Writing Tests

```r
testthat::test_that("positive_mean calculates correctly", {
  testthat::expect_equal(positive_mean(c(1, 2, 3)), 2)
  testthat::expect_equal(positive_mean(c(-1, 2, 4)), 3)
  testthat::expect_equal(positive_mean(c(-1, -2)), NaN)
})

testthat::test_that("positive_mean handles NA", {
  testthat::expect_equal(positive_mean(c(1, NA, 3)), 2)
  testthat::expect_equal(positive_mean(c(1, NA, 3), na.rm = FALSE), NA_real_)
})

testthat::test_that("positive_mean errors on non-numeric", {
  testthat::expect_error(positive_mean("a"), "must be numeric")
})
```

## Build-time vs Run-time

Code outside functions runs at build time, not when users call functions:

```r
# Bad - path cached at build time
data_path <- system.file("data", package = "mypkg")

# Good - path resolved at call time
get_data_path <- function() {
  system.file("data", package = "mypkg")
}
```

## Development Workflow

```r
# Load all package code for interactive testing
pkgload::load_all()

# Run tests (when in an R package)
testthat::test_package()

# Check package

1. Build package in terminal `R CMD BUILD <pkg-directory>`
2. Check package with `R CMD check <pkg>_<version>.tar.gz`

# Build documentation
roxygen2::roxygenize()

# Install package locally
renv::install()
```

## CRAN Considerations

- No `Depends` on packages (use `Imports`)
- Examples must run in < 5 seconds
- No writing to user directories without permission
- Use `\dontrun{}` for examples that can't run on CRAN
- Check with `--as-cran` flag

## Anti-patterns

- Using `library()` or `require()` in R/ files
- Using `source()` to load code
- Modifying global options without restoration
- Using `setwd()`
- Relying on side effects at build time
- Writing to user's home directory
- Using `:::` to access internal functions from other packages
- Skipping `@return` in documentation

## References

- [R Packages (2e)](https://r-pkgs.org/)
- [Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html)
- [Tidyverse Design Guide](https://design.tidyverse.org/)
- [usethis package](https://usethis.r-lib.org/)