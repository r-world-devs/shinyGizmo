library(shinytest2)

new_valuebutton_app <- function(name) {
  AppDriver$new(
    test_path("apps", "valuebutton"), name = name,
    height = 900, width = 1200,
    variant = platform_variant()
  )
}

test_that("valueButton applies sourced binding input handler (#36)", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_valuebutton_app("valuebutton-binding")
  on.exit(app$stop(), add = TRUE)

  expect_equal(app$get_value(export = "vb_slider"), 2L)
  expect_equal(app$get_value(export = "vl_slider"), 2L)
  # Slider type depends on the element (`getType(el)`)
  expect_equal(app$get_value(export = "vb_date"), "2023-06-01")
  expect_equal(app$get_value(export = "vb_date_class"), "Date")
})

test_that("valueButton with try_binding = FALSE returns raw DOM value", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_valuebutton_app("valuebutton-raw")
  on.exit(app$stop(), add = TRUE)

  # Date slider stores timestamp (in ms) as its DOM value
  expect_equal(app$get_value(export = "vb_date_raw"), "1685577600000")
  expect_equal(app$get_value(export = "vb_date_raw_class"), "character")
})

test_that("valueButton returns non-binding attributes as is", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_valuebutton_app("valuebutton-attributes")
  on.exit(app$stop(), add = TRUE)

  expect_equal(app$get_value(export = "vb_width"), "300px")
  # Objects having `type` field are not mistaken for wrapped binding values
  expect_equal(app$get_value(export = "vb_object"), list(type = "custom", size = 1L))
})

test_that("valueButton sends current value on click", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_valuebutton_app("valuebutton-click")
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(sli = 4)
  # Value is not refreshed until the button is clicked
  expect_equal(app$get_value(export = "vb_slider"), 2L)

  app$click(selector = "#vb_slider")
  app$wait_for_idle()
  expect_equal(app$get_value(export = "vb_slider"), 4L)
})

test_that("valueButton screenshot", {
  skip_on_cran()
  skip_on_ci()
  skip_without_screenshot_tests()

  app <- new_valuebutton_app("valuebutton-screenshot")
  on.exit(app$stop(), add = TRUE)

  app$expect_screenshot(threshold = 3)
})
