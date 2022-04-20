library(shiny)
styled_item <- function(id, header_text, content_text, active = FALSE) {
  accordionItem(
    id, header_text, content_text, active = active,
    enroll_callback = TRUE,
    # enroll_callback = FALSE,
    header_class = "acc-header", content_class = "acc-content"
  )
}
activator <- function(disabled = FALSE) {
  shiny::tags$div(
    tags$button(
      class = activatorClass, onclick = accordionEnrollOnClick(),
      shiny::icon("eye"),
      type = "btn-outline-dark btn-xs",
      disabled = if (isTRUE(disabled)) NA else NULL
    ),
    style = "float: right;"
  )
}
ui <- fluidPage(
  tags$head(tags$style(
    ".acc-header, .acc-content {border: 1px solid; border-radius: 5px; padding: 3px;} body {padding: 5px};"
  )),
  accordion(
    "acc",
    styled_item(
      "first",
      "Hello" ,
      #div("Hello", activator(TRUE), style = "display: inline-block; min-width: 180px;"),
      "There",
      active = TRUE
    ),
    styled_item(
      "second",
      "General",
      # div("General", activator(FALSE), style = "display: inline-block; min-width: 180px;"),
      "Kenobi"
    )
  )
)
server <- function(input, output, session) {}

shinyApp(ui, server)
