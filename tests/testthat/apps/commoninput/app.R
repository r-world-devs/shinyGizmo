library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  commonInput("val", selectInput("letter", "Letter", letters)),
  commonInput("val", numericInput("number", "Number", min = 0, max = 10, value = 1)),
  commonInput("val", dateInput("date", "Date", value = "2023-01-02")),
  commonInput(
    "val",
    sliderInput(
      "date_slider", "Date slider",
      min = as.Date("2023-01-01"), max = as.Date("2023-12-31"), value = as.Date("2023-06-01")
    )
  ),
  commonInputs(
    "val2",
    selectInput("letter2", "Letter", letters),
    numericInput("number2", "Number", min = 0, max = 10, value = 1),
    block = FALSE
  ),
  verbatimTextOutput("out"),
  verbatimTextOutput("out2")
)

server <- function(input, output, session) {
  output$out <- renderPrint(str(input$val))
  output$out2 <- renderPrint(str(input$val2))

  exportTestValues(
    val_names = sort(names(input$val)),
    val_classes = purrr::map_chr(input$val, ~ class(.x)[1]),
    letter = input$letter,
    letter2 = input$letter2
  )
}

shinyApp(ui, server)
