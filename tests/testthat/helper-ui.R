# Shared helpers for UI tests

skip_on_ci <- function() {
  if (nzchar(Sys.getenv("CI"))) {
    testthat::skip("UI tests skipped on CI")
  }
}

skip_without_screenshot_tests <- function() {
  if (!nzchar(Sys.getenv("SCREENSHOT_TESTS"))) {
    testthat::skip("Set SCREENSHOT_TESTS=1 to run screenshot tests")
  }
}

skip_if_screenshot_only <- function() {
  if (nzchar(Sys.getenv("SCREENSHOT_ONLY"))) {
    testthat::skip("SCREENSHOT_ONLY mode - skipping non-screenshot tests")
  }
}
