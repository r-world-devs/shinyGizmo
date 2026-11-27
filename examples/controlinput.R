library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  controlInput(selectInput("letter", "Letter", letters), attributes = list(group = "form")),
  controlInput(numericInput("number", "Number (program updates blocked)", value = 1), block = "program"),
  controlInput(dateInput("date", "Date (user changes blocked)", value = Sys.Date()), block = "user"),
  actionButton("update", "Update programmatically"),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint({
    str(list(letter = input$letter, number = input$number, date = input$date))
    cat("Date trigger:", attr(input$date, "trigger"))
  })
  observeEvent(input$update, {
    updateSelectInput(session, "letter", selected = sample(letters, 1))
    updateNumericInput(session, "number", value = sample(1:10, 1))
    updateDateInput(session, "date", value = Sys.Date() + sample(1:10, 1))
  })
}

shinyApp(ui, server)
