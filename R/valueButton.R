#' Take value from selected UI element
#'
#' The components creates button that allows to take any value (or attribute) sourced
#' from DOM element existing in Shiny application and pass it to application server.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   shinyApp(
#'     ui = fluidPage(
#'       tags$textarea(id = "txt"),
#'       valueButton("val", "Take textarea value", "#txt", attribute = "value")
#'     ),
#'     server = function(input, output, session) {
#'       observeEvent(input$val, print(input$val))
#'     }
#'   )
#' }
#'
#' @param inputId Id of the button. The value can be accessed in server with `input[[inputId]]`.
#' @param label Button label.
#' @param selector CSS selector of element the attribute should be taken from.
#'   Set `"window"` or `"document"` to access application `window` or `document` object.
#' @param attribute Name of the attribute that should be taken from desired element.
#'   For nested properties use `.`, e.g. `style.width` or `navigator.appName`.
#' @param icon Icon included in button.
#' @param width Width of the button.
#' @param ... Extra attributes passed to button.
#'
#' @return A `shiny.tag` class object defining html structure of the button.
#' @export
valueButton <- function(inputId, label, selector, attribute = "value", icon = NULL, width = NULL, ...) {

  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(type = "text/javascript", src = "shinyGizmo/valuebutton.js")
      )
    ),
    shiny::tags$button(
      id = inputId,
      style = htmltools::css(width = shiny::validateCssUnit(width)),
      type = "button",
      class = "btn btn-default value-button",
      `data-val` = NULL,
      `data-value-attribute` = attribute,
      `data-selector` = selector,
      list(icon, label),
      ...
    )
  )
}

# todo implement update method
