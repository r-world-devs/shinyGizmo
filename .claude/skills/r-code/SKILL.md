---
name: r-code
description: Write R code following tidyverse style guide. Use when writing R functions, scripts, or any R code.
---

# R Code Style

Write R code following tidyverse conventions.

## Naming

- **snake_case** for variables and functions
- **Functions are verbs**, variables are nouns
- Avoid reusing names of common functions (`c`, `mean`, `T`, `F`)

```r
# Good
day_one
calculate_mean()

# Bad
DayOne
calculateMean()
dayOne
```

## Assignment

Use `<-`, not `=`:

```r
# Good
x <- 5

# Bad
x = 5
```

## Spacing

- Space after commas: `x[, 1]`
- Space around infix operators: `x <- y + z`
- No space around `::`, `$`, `@`, `[`, `[[`, `^`, `:`
- Space before/after `()` with `if`, `for`, `while`
- Embracing `{{ }}` has inner spaces

```r
# Good
mean(x, na.rm = TRUE)
df$column
x <- 1:10
sqrt(x^2 + y^2)

if (debug) {
  show(x)
}

data |>
  dplyr::group_by({{ by }}) |>
  dplyr::summarise(max = max({{ var }}))

# Bad
mean(x,na.rm=TRUE)
df $ column
x <- 1 : 10
if(debug){show(x)}
```

## Functions

1. **Only use `return()` for early returns**
   ```r
   # Good
   find_abs <- function(x) {
     if (x > 0) {
       return(x)
     }
     x * -1
   }

   add_two <- function(x, y) {
     x + y
   }

   # Bad
   add_two <- function(x, y) {
     return(x + y)
   }
   ```

2. **Lambda syntax `\(x)`** for short anonymous functions
   ```r
   # Good
   purrr::map(xs, \(x) x + 1)

   # Bad
   purrr::map(xs, ~ .x + 1)
   ```

3. **Multi-line definitions** - single indent style
   ```r
   long_function_name <- function(
     a = "a long argument",
     b = "another argument"
   ) {
     # body
   }
   ```

4. **Side-effect functions** return first argument invisibly
   ```r
   print.my_class <- function(x, ...) {
     cat("Value: ", x$value, "\n", sep = "")
     invisible(x)
   }
   ```

## Control Flow

- Use `&&` and `||` in `if` conditions, never `&` or `|`
- Braces required for multi-line `if`
- `else` on same line as `}`
- Control flow modifiers get own `{}` block

```r
# Good
if (y < 0) {
  rlang::abort("y must be positive")
}

if (x > 10) {
  x * 2
} else {
  x * 3
}

# Bad
if (y < 0) stop("y must be positive")
```

## Pipes

- Use native pipe `|>` (R 4.1+)
- One function per line
- Indent piped operations

```r
# Good
df |>
  dplyr::filter(x > 0) |>
  dplyr::mutate(y = x * 2) |>
  dplyr::summarise(mean_y = mean(y))

# Bad
df |> dplyr::filter(x > 0) |> dplyr::mutate(y = x * 2)
```

## Namespace Usage

Always use explicit namespaces for non-base R functions:

```r
# Good
dplyr::filter(df, x > 0)
rlang::abort("Error message")
purrr::map(xs, \(x) x + 1)

# Bad
filter(df, x > 0)
abort("Error message")
```

## Data

- Use `"` for strings, not `'`
- Use `TRUE`/`FALSE`, never `T`/`F`
- Use `seq_along(x)` not `1:length(x)`

```r
# Good
"Text"
TRUE
seq_along(x)

# Bad
'Text'
T
1:length(x)
```

## Comments

- Start with `# ` (hash + space)
- Explain "why", not "what"
- Sentence case, period only if multiple sentences

```r
# Objects like data frames are treated as leaves
x <- purrr::map_if(x, rlang::is_bare_list, recurse)
```

## Anti-patterns

- Using `=` for assignment
- Using `T` and `F` instead of `TRUE` and `FALSE`
- Using `1:length(x)` instead of `seq_along(x)`
- Using `sapply()` (use `vapply()` or `purrr::map_*()`)
- Calling functions without namespace prefix
- Using semicolons to combine statements
- Implicit type coercion in `if` conditions

## Running R Code

When the btw MCP server is available, prefer `btw_tool_run_r` over `Bash` + `Rscript -e "..."`:

- **Stateful** — loaded packages and objects persist across calls
- **Iterative** — explore data step by step without reloading
- **Cleaner** — no shell escaping issues with R expressions

```r
# Use btw_tool_run_r for multi-step work
# Call 1: load and inspect
df <- readr::read_csv("data.csv")
str(df)

# Call 2: objects from call 1 are still available
df |> dplyr::count(category, sort = TRUE)
```

Reserve `Bash` + `Rscript` only for one-off commands where session state doesn't matter.

## References

- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [Advanced R](https://adv-r.hadley.nz/)
- [Deep R](https://deepr.gagolewski.com/)