gen_id <- function() {
  paste0(sample(letters, 5), collapse = "")
}

#' Merge multiple input controllers into one
#'
#' @description
#' Select which input controllers should be treated as one.
#' Use `commonInput` to group selected controllers or `commonInputs` to group
#' multiple controllers at once.
#'
#'
#' @param inputId Id to be used to send the grouped controllers input values to application server.
#' @param controller Shiny input controller e.g. `shiny::sliderInput` or `shinyWidgets::pickerInput`.
#' @param block Should the `controller` value be sent to the server independently?
#' @param ... Input controllers to be grouped in case of using `commonInputs`.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     commonInput("val", selectInput("letter", "Letter", letters)),
#'     commonInput("val", numericInput("number", "Number", min = 0, max = 10, value = 1)),
#'     commonInputs(
#'       "val2",
#'       selectInput("letter2", "Letter", letters),
#'       numericInput("number2", "Number", min = 0, max = 10, value = 1)
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     observeEvent(input$val, {
#'       print(input$val)
#'     })
#'     observeEvent(input$val2, {
#'       print(input$val2)
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
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

#' @rdname commonInput
#' @export
commonInputs <- function(inputId, ..., block = TRUE) {
  controllers <- rlang::dots_list(...) %>%
    purrr::map(~commonInput(inputId, .x, block))
  shiny::tagList(!!!controllers)
}
