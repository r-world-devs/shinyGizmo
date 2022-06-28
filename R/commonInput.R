#' @export
commonInput <- function(inputId, controller, block = TRUE) {
  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(type = "text/javascript", src = "shinyGizmo/commoninput.js")
      )
    ),
    shiny::tagAppendAttributes(
      controller,
      `data-common_id` = inputId,
      `data-block` = if (block) "true" else "false",
      class = "sg_common_input"
    ),
    shiny::singleton(
      shiny::div(
        id = inputId, class = "sg_common_storage",
        style = htmltools::css(
          "visibility!" = "hidden",
          "margin!" = 0,
          "padding!" = 0,
          "overflow!" = "hidden",
          "max-height" = 0,
          "max-width" = 0
        )
      )
    )
  )
}

#' @export
commonInputs <- function(inputId, ..., block = TRUE) {
  controllers <- list(...) %>%
    purrr::map(~commonInput(inputId, .x, block))
  shiny::tagList(!!!controllers)
}
