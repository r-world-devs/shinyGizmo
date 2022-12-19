library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      tags$head(tags$style("body {margin: 20px}")),
      valueButton("vb2", "Attribute 'width' of 'Text Area'", "#txt", "style.width", width = "250px"),
      verbatimTextOutput("out2"),
      hr(),
      valueButton("vb3", "Attribute 'value' of 'Slider'", "#sli", "value", width = "250px"),
      verbatimTextOutput("out3"),
      hr(),
      valueLink("vb1", "Get application window height", "window", "innerHeight", width = "250px"),
      verbatimTextOutput("out1")
    ),
    mainPanel(
      shiny::tags$label(`for` = "#txt", "Text Area"), br(),
      tags$textarea(id = "txt", "Lorem Ipsum", style = "width: 300px"),
      hr(),
      sliderInput("sli", "Slider", value = 1, min = 1, max = 5, step = 1)
    )
  )
)

server <- function(input, output, session) {
  output$out1 <- renderPrint(print(input$vb1))
  output$out2 <- renderPrint(print(input$vb2))
  output$out3 <- renderPrint(print(input$vb3))
}

shinyApp(ui, server)
