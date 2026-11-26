---
name: r-explore
description: Explore and inspect R data frames, objects, and environments interactively. Use when the user wants to understand data structure, preview data, or investigate R objects.
---

# R Data Exploration

Use btw MCP tools for interactive R data exploration. These tools connect to a live R session with persistent state.

## Key Tools

| Tool | Purpose |
|------|---------|
| `btw_tool_env_describe_data_frame` | Inspect structure, types, and summary of a data frame |
| `btw_tool_env_describe_environment` | List all objects in the R global environment |
| `btw_tool_run_r` | Run R code in the live session (state persists across calls) |
| `btw_tool_sessioninfo_platform` | Check R version, OS, locale |
| `btw_tool_sessioninfo_is_package_installed` | Check if a package is available |

## Workflow

1. **Start with the environment** — use `btw_tool_env_describe_environment` to see what's loaded
2. **Inspect data frames** — use `btw_tool_env_describe_data_frame` for structure and summary
3. **Explore interactively** — use `btw_tool_run_r` for custom queries, filtering, and aggregation

## Common Exploration Patterns

```r
# Preview rows
head(df, 10)
dplyr::glimpse(df)

# Value distributions
dplyr::count(df, column, sort = TRUE)
summary(df$column)

# Missing data
colSums(is.na(df))

# Unique values
purrr::map_int(df, dplyr::n_distinct)

# Cross-tabulation
table(df$col1, df$col2)
```

## Anti-patterns

- Don't use `Bash` + `Rscript` for data exploration — use `btw_tool_run_r` to keep session state
- Don't call `str()` when `btw_tool_env_describe_data_frame` gives richer output
- Don't `print()` entire large data frames — use `head()` or `dplyr::slice_sample()`
