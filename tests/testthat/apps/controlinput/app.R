library(shiny)
library(shinyGizmo)

describe <- function(x) {
  list(
    value = if (is.null(x)) NULL else format(x),
    class = class(x),
    trigger = attr(x, "trigger"),
    group = attr(x, "group")
  )
}

ui <- fluidPage(
  controlInput(selectInput("letter", "Letter", letters), attributes = list(group = "form")),
  controlInput(dateInput("date", "Date", value = "2023-01-02")),
  controlInput(
    sliderInput(
      "date_slider", "Date slider",
      min = as.Date("2023-01-01"), max = as.Date("2023-12-31"), value = as.Date("2023-06-01")
    )
  ),
  controlInput(numericInput("block_program", "Blocked program", value = 1), block = "program"),
  controlInput(numericInput("block_user", "Blocked user", value = 1), block = "user"),
  controlInput(textInput("no_trigger", "No trigger", value = "a"), trigger = FALSE),
  controlInput(selectInput("multi", "Multiple", letters, multiple = TRUE)),
  selectInput("plain", "Plain", letters),
  actionButton("update", "Update"),
  uiOutput("dynamic"),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  ids <- c("letter", "date", "date_slider", "block_program", "block_user", "no_trigger", "multi", "plain", "rendered")
  output$out <- renderPrint(str(stats::setNames(purrr::map(ids, ~ input[[.x]]), ids)))

  output$dynamic <- renderUI(controlInput(textInput("rendered", "Rendered", value = "x")))

  observeEvent(input$update, {
    updateSelectInput(session, "letter", selected = "c")
    updateNumericInput(session, "block_program", value = 5)
    updateNumericInput(session, "block_user", value = 5)
  })

  exportTestValues(
    letter = describe(input$letter),
    date = describe(input$date),
    date_slider = describe(input$date_slider),
    block_program = describe(input$block_program),
    block_user = describe(input$block_user),
    no_trigger = describe(input$no_trigger),
    multi = describe(input$multi),
    plain = describe(input$plain),
    rendered = describe(input$rendered)
  )
}

shinyApp(ui, server)
