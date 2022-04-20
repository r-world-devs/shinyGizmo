library(shiny)
choices <- list(
  fruits = c("Orange" = "orange", "Apple" = "apple", "Lemon" = "lemon"),
  vegetables = c("Potato" = "potato", "Carrot" = "carrot", "Broccoli" = "broccoli")
)
selected <- list(
  fruits = c("orange"),
  vegetables = NA
)
choices_labels <- list(
  "fruits" = "Fruits",
  "vegetables" = "Vegetables"
)

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    pickCheckboxInput(
      "pci", "Select group and options",
      choices = choices, selected = selected,
      choicesLabels = choices_labels
    )
  ),
  mainPanel(
    verbatimTextOutput("out")
  ))
)
server <- function(input, output, session) {
  output$out <- renderPrint({input$pci})
}
shinyApp(ui, server)
