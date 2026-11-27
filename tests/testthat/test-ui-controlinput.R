library(shinytest2)

new_controlinput_app <- function(name) {
  AppDriver$new(
    test_path("apps", "controlinput"), name = name,
    height = 900, width = 1200,
    variant = platform_variant()
  )
}

# Trusted (real) user interaction, unlike events triggered with JS
press_key <- function(app) {
  chromote <- app$get_chromote_session()
  chromote$Input$dispatchKeyEvent(type = "keyDown", key = "Shift")
  chromote$Input$dispatchKeyEvent(type = "keyUp", key = "Shift")
}

test_that("controlInput sends initial values with attributes (#20)", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_controlinput_app("controlinput-init")
  on.exit(app$stop(), add = TRUE)

  letter <- app$get_value(export = "letter")
  expect_equal(letter$value, "a")
  expect_equal(letter$trigger, "init")
  expect_equal(letter$group, "form")

  # Original input handlers are applied
  expect_equal(app$get_value(export = "date")$class, "Date")
  expect_equal(app$get_value(export = "date")$trigger, "init")
  expect_equal(app$get_value(export = "date_slider")$class, "Date")
  expect_equal(app$get_value(export = "date_slider")$value, "2023-06-01")

  # Rendered with renderUI
  expect_equal(app$get_value(export = "rendered")$trigger, "init")

  # No trigger attribute
  expect_equal(app$get_value(export = "no_trigger")$value, "a")
  expect_null(app$get_value(export = "no_trigger")$trigger)

  # NULL value is passed as is
  expect_null(app$get_value(export = "multi")$value)

  # Inputs outside controlInput are not affected
  plain <- app$get_value(export = "plain")
  expect_equal(plain$class, "character")
  expect_null(plain$trigger)
  expect_equal(app$get_value(input = "plain"), "a")
})

test_that("controlInput detects whether value was changed by user or programmatically", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_controlinput_app("controlinput-trigger")
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(letter = "b", date = "2023-02-01")
  expect_equal(app$get_value(export = "letter")[c("value", "trigger", "group")], list(value = "b", trigger = "user", group = "form"))
  expect_equal(app$get_value(export = "date")[c("value", "class", "trigger")], list(value = "2023-02-01", class = "Date", trigger = "user"))

  app$click("update")
  app$wait_for_idle()
  expect_equal(app$get_value(export = "letter")[c("value", "trigger")], list(value = "c", trigger = "program"))

  # User interaction resets the program flag
  press_key(app)
  app$set_inputs(letter = "d")
  expect_equal(app$get_value(export = "letter")[c("value", "trigger")], list(value = "d", trigger = "user"))

  app$set_inputs(multi = c("a", "b"))
  expect_equal(app$get_value(export = "multi")[c("value", "trigger")], list(value = c("a", "b"), trigger = "user"))
})

test_that("controlInput blocks values depending on change source", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_controlinput_app("controlinput-block")
  on.exit(app$stop(), add = TRUE)

  app$click("update")
  app$wait_for_idle()
  # Updated in browser but blocked
  expect_equal(app$get_js("$('#block_program').val()"), "5")
  expect_equal(app$get_value(export = "block_program")$value, "1")
  # Program updates of user-blocked input are sent
  expect_equal(app$get_value(export = "block_user")[c("value", "trigger")], list(value = "5", trigger = "program"))

  press_key(app)
  app$set_inputs(block_program = 3, block_user = 7, wait_ = FALSE)
  app$wait_for_idle(duration = 1000)
  expect_equal(app$get_value(export = "block_program")[c("value", "trigger")], list(value = "3", trigger = "user"))
  expect_equal(app$get_value(export = "block_user")$value, "5")
})

test_that("controlInput screenshot", {
  skip_on_cran()
  skip_on_ci()
  skip_without_screenshot_tests()

  app <- new_controlinput_app("controlinput-screenshot")
  on.exit(app$stop(), add = TRUE)

  app$expect_screenshot(threshold = 3)
})
