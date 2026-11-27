library(shinytest2)

new_conditionaljs_app <- function(name) {
  AppDriver$new(
    test_path("apps", "conditionaljs"), name = name,
    height = 900, width = 1200,
    variant = platform_variant()
  )
}

has_class <- function(app, id, class) {
  app$get_js(sprintf("$('#%s').hasClass('%s')", id, class))
}

is_disabled <- function(app, id) {
  app$get_js(sprintf("$('#%s').prop('disabled')", id))
}

test_that("conditionalJS applies stacked rules independently (#40)", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_conditionaljs_app("conditionaljs-stacked")
  on.exit(app$stop(), add = TRUE)

  expect_false(has_class(app, "stacked", "boldme"))
  expect_false(is_disabled(app, "stacked"))

  app$set_inputs(value = 6)
  expect_true(has_class(app, "stacked", "boldme"))
  expect_false(is_disabled(app, "stacked"))

  app$set_inputs(lock = TRUE)
  expect_true(has_class(app, "stacked", "boldme"))
  expect_true(is_disabled(app, "stacked"))

  app$set_inputs(value = 2)
  expect_false(has_class(app, "stacked", "boldme"))
  expect_true(is_disabled(app, "stacked"))
})

test_that("conditionalJS applies vectorised rules (#40)", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_conditionaljs_app("conditionaljs-vectorised")
  on.exit(app$stop(), add = TRUE)

  color <- function() app$get_js("document.getElementById('vectorised').style.color")

  expect_true(has_class(app, "vectorised", "sg_hidden"))
  expect_equal(color(), "")

  app$set_inputs(value = 4)
  expect_false(has_class(app, "vectorised", "sg_hidden"))
  expect_equal(color(), "")

  app$set_inputs(value = 8)
  expect_false(has_class(app, "vectorised", "sg_hidden"))
  expect_equal(color(), "red")
})

test_that("conditionalJS respects `once` per rule", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_conditionaljs_app("conditionaljs-once")
  on.exit(app$stop(), add = TRUE)

  count <- function(name) app$get_js(sprintf("window.%s", name))
  once_init <- count("count_once")
  every_init <- count("count_every")

  # Condition state unchanged
  app$set_inputs(other = "a")
  app$set_inputs(other = "b")
  expect_equal(count("count_once"), once_init)
  expect_gt(count("count_every"), every_init)

  # Condition state changed
  app$set_inputs(value = 6)
  expect_equal(count("count_once"), once_init + 1)
})

test_that("conditionalJS stacked rules keep ignoreInit and module namespace", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_conditionaljs_app("conditionaljs-ns")
  on.exit(app$stop(), add = TRUE)

  # Hidden on init (without animation), next rule still applied
  expect_true(has_class(app, "animated", "sg_hidden"))
  app$set_inputs(lock = TRUE)
  expect_true(has_class(app, "animated", "locked"))
  app$set_inputs(value = 4)
  app$wait_for_js("!$('#animated').hasClass('sg_hidden')")
  expect_true(has_class(app, "animated", "locked"))

  # Namespaced rule combined with global one
  expect_false(has_class(app, "mod-btn", "flagged"))
  app$set_inputs(`mod-flag` = TRUE)
  expect_true(has_class(app, "mod-btn", "flagged"))
  expect_false(is_disabled(app, "mod-btn"))
  app$set_inputs(value = 6)
  expect_true(is_disabled(app, "mod-btn"))
})

test_that("conditionalJS single rule attributes can be modified directly", {
  skip_on_cran()
  skip_on_ci()
  skip_if_screenshot_only()

  app <- new_conditionaljs_app("conditionaljs-single")
  on.exit(app$stop(), add = TRUE)

  expect_null(app$get_js("$('#single').attr('data-call-rules')"))
  app$run_js("$('#single').attr('data-call-if-true', \"$(this).addClass('modified');\")")
  app$set_inputs(value = 6)
  expect_true(has_class(app, "single", "modified"))
  expect_false(has_class(app, "single", "single"))
})

test_that("conditionalJS screenshot", {
  skip_on_cran()
  skip_on_ci()
  skip_without_screenshot_tests()

  app <- new_conditionaljs_app("conditionaljs-screenshot")
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(value = 8, lock = TRUE)
  app$wait_for_js("!$('#animated').hasClass('animated')")
  app$expect_screenshot(threshold = 3)
})
