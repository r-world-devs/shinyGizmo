#' Control how input controller value is sent to the server
#'
#' @description
#' Wrap Shiny input controller to:
#' - detect whether its value was changed by the user or programmatically (with `update*` functions),
#' - block sending the value to the server depending on the change source,
#' - attach custom attributes to the input value.
#'
#' The original input handler (e.g. converting `shiny::dateInput` value to `Date`) is applied before
#' attributes are attached.
#'
#' @param controller Shiny input controller e.g. `shiny::selectInput` or `shinyWidgets::pickerInput`.
#' @param block Sources of value change that should not be sent to the server.
#'   Any of `"user"` (change made directly in the browser) and `"program"` (change made with
#'   `update*` function). The initial value is always sent.
#' @param trigger When `TRUE`, the value has `"trigger"` attribute attached that stores source of the change:
#'   `"init"` (initial value or the controller was rendered), `"user"` or `"program"`.
#' @param attributes Named list of extra (static) attributes attached to the input value.
#'
#' @return Nested list of `shiny.tag` objects - the `controller` with extra attributes and dependency attached.
#'
#' @details
#' The attributes can't be attached to `NULL` values, so in this case the input value is passed as is.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     controlInput(selectInput("letter", "Letter", letters), attributes = list(group = "form")),
#'     controlInput(numericInput("number", "Number", value = 1), block = "program"),
#'     actionButton("update", "Update programmatically"),
#'     verbatimTextOutput("out")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$out <- renderPrint({
#'       str(list(letter = input$letter, number = input$number))
#'     })
#'     observeEvent(input$update, {
#'       updateSelectInput(session, "letter", selected = sample(letters, 1))
#'       # value updated in browser but not sent to the server
#'       updateNumericInput(session, "number", value = sample(1:10, 1))
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
controlInput <- function(controller, block = NULL, trigger = TRUE, attributes = list()) {
  if (!is.null(block)) {
    block <- match.arg(block, c("user", "program"), several.ok = TRUE)
  }
  if (length(attributes) > 0 && (is.null(names(attributes)) || any(names(attributes) == ""))) {
    stop("All `attributes` elements have to be named.")
  }
  if ("trigger" %in% names(attributes) && isTRUE(trigger)) {
    stop("`trigger` attribute name is reserved when `trigger = TRUE`.")
  }

  htmltools::attachDependencies(
    shiny::tagAppendAttributes(
      controller,
      `data-control_block` = if (!is.null(block)) paste(block, collapse = ",") else NULL,
      `data-control_trigger` = if (isTRUE(trigger)) "true" else "false",
      `data-control_attributes` = if (length(attributes) > 0) {
        jsonlite::toJSON(attributes, auto_unbox = TRUE)
      } else {
        NULL
      },
      class = "sg_control_input"
    ),
    htmltools::htmlDependency(
      name = "controlinput",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "controlinput.js"
    ),
    append = TRUE
  )
}
