#!/usr/bin/env Rscript
# Run shinyGizmo UI tests sequentially with screenshot tests enabled.
#
# Usage:
#   Rscript run_tests.R
#   Rscript run_tests.R ui-commoninput
#   Rscript run_tests.R ui-commoninput ui-valuebutton

# Ensure system library is available (renv may isolate it)
.libPaths(c(.libPaths(), "/usr/local/lib/R/site-library", "/usr/local/lib/R/library"))

Sys.setenv(SCREENSHOT_TESTS = "1", NOT_CRAN = "true")

filters <- commandArgs(trailingOnly = TRUE)
if (length(filters) == 0) {
  filters <- c(
    "ui-commoninput",
    "ui-conditionaljs",
    "ui-controlinput",
    "ui-valuebutton"
  )
}

pkgload::load_all(".")

results <- list()
for (f in filters) {
  cat(sprintf("\n══ Running: %s ══\n", f))
  results[[f]] <- testthat::test_dir(
    "tests/testthat",
    filter = f,
    stop_on_failure = FALSE
  )
}

# Summary
cat("\n══ Summary ══\n")
total_pass <- 0L
total_fail <- 0L
total_skip <- 0L
for (f in names(results)) {
  r <- as.data.frame(results[[f]])
  pass <- sum(r$passed)
  fail <- sum(r$failed)
  skip <- sum(r$skipped)
  total_pass <- total_pass + pass
  total_fail <- total_fail + fail
  total_skip <- total_skip + skip
  status <- if (fail == 0) "✅" else "❌"
  cat(sprintf("  %s %-20s pass: %d  fail: %d  skip: %d\n", status, f, pass, fail, skip))
}
cat(sprintf("\n  Total: %d passed, %d failed, %d skipped\n", total_pass, total_fail, total_skip))

if (total_fail > 0) quit(status = 1)
