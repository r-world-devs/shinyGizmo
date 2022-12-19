#' Take value from selected UI element
#'
#' The components creates button or link that allows to take any value (or attribute) sourced
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
#' @param try_binding When `TRUE` and `selector` points to Shiny Binding and `attribute == "value"`
#'   it tries to convert sourced input value using registered `inputHandler`.
#' @param ... Extra attributes passed to `button` or `a` tag.
#'
#' @return A `shiny.tag` class object defining html structure of the button.
#' @name valueButton
#' @export
valueButton <- function(inputId, label, selector, attribute = "value", icon = NULL, width = NULL, try_binding = TRUE, ...) {

  htmltools::attachDependencies(
    shiny::tags$button(
      id = inputId,
      style = htmltools::css(width = shiny::validateCssUnit(width)),
      type = "button",
      class = "btn btn-default value-button",
      `data-val` = NULL,
      `data-value-attribute` = attribute,
      `data-selector` = selector,
      `data-try_binding` = try_binding,
      list(icon, label),
      ...
    ),
    value_button_dependency
  )
}

#' @rdname valueButton
#' @export
valueLink <- function(inputId, label, selector, attribute = "value", icon = NULL, try_binding = TRUE, ...) {

  htmltools::attachDependencies(
    shiny::tags$a(
      id = inputId,
      class = "value-button",
      href = "#",
      `data-val` = NULL,
      `data-value-attribute` = attribute,
      `data-selector` = selector,
      `data-try_binding` = try_binding,
      list(icon, label),
      ...
    ),
    value_button_dependency
  )
}

value_button_dependency <- htmltools::htmlDependency(
  name = "valuebutton",
  version = utils::packageVersion("shinyGizmo"),
  package = "shinyGizmo",
  src = "www",
  script = "valuebutton.js"
)

# todo implement update method
