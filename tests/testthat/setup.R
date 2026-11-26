# Prevent testthat from deleting screenshot snapshots during normal test runs.
#
# When SCREENSHOT_TESTS is unset, screenshot tests are skipped but testthat
# still sees the test files. It then treats their snapshots as "unused" and
# deletes them. There is no built-in option to disable this — the cleanup is
# hardcoded in SnapshotReporter$end_reporter — so we replace the cleanup
# function with a no-op.
if (!nzchar(Sys.getenv("SCREENSHOT_TESTS"))) {
  suppressMessages(
    utils::assignInNamespace(
      "snapshot_cleanup",
      function(path, test_files_seen = character(), snap_files_seen = character()) {
        invisible(character())
      },
      ns = "testthat"
    )
  )
}
