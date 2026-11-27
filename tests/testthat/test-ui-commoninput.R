library(shinytest2)

new_commoninput_app <- function(name) {
  AppDriver$new(
    test_path("apps", "commoninput"), name = name,
    height = 900, width = 1200,
    variant = platform_variant()
  )
}

test_that("commonInput merges controllers and applies their input handlers (#36)", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_commoninput_app("commoninput-handlers")
  on.exit(app$stop(), add = TRUE)

  # Names are stripped of the `:<type>` suffix
  expect_equal(app$get_value(export = "val_names"), c("date", "date_slider", "letter", "number"))

  classes <- app$get_value(export = "val_classes")
  expect_equal(classes[["letter"]], "character")
  expect_equal(classes[["number"]], "integer")
  # `shiny.date` handler applied based on type stored in the name
  expect_equal(classes[["date"]], "Date")
  # Slider type depends on the element (`getType(el)`)
  expect_equal(classes[["date_slider"]], "Date")
})

test_that("commonInput updates merged value when a controller changes", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_commoninput_app("commoninput-update")
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(letter = "c", allow_no_input_binding_ = TRUE)
  app$wait_for_idle(duration = 1000)
  expect_equal(app$get_value(input = "val")$letter, "c")

  app$set_inputs(number = 5, allow_no_input_binding_ = TRUE)
  app$wait_for_idle(duration = 1000)
  expect_equal(app$get_value(input = "val")$number, 5)
})

test_that("commonInput block argument controls sending controller values independently", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_commoninput_app("commoninput-block")
  on.exit(app$stop(), add = TRUE)

  expect_equal(app$get_value(input = "val2"), list(letter2 = "a", number2 = 1L))

  # Initial values are sent with Shiny initialization, blocking applies to changes only
  app$set_inputs(letter = "c", letter2 = "c", allow_no_input_binding_ = TRUE)
  app$wait_for_idle(duration = 1000)
  expect_equal(app$get_value(export = "letter"), "a")
  expect_equal(app$get_value(export = "letter2"), "c")
  expect_equal(app$get_value(input = "val")$letter, "c")
  expect_equal(app$get_value(input = "val2")$letter2, "c")
})

test_that("commonInput screenshot", {
  skip_on_cran()
  skip_on_ci()
  skip_without_screenshot_tests()

  app <- new_commoninput_app("commoninput-screenshot")
  on.exit(app$stop(), add = TRUE)

  app$expect_screenshot(threshold = 3)
})
