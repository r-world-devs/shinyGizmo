library(shiny)
library(shinyGizmo)
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
    vsCheckboxInput(
      "pci", "Select group and options",
      choices = choices, selected = selected,
      choicesLabels = choices_labels
    ),
    actionButton("up", "Update")
  ),
  mainPanel(
    verbatimTextOutput("out")
  ))
)
server <- function(input, output, session) {
  output$out <- renderPrint({input$pci})
  observeEvent(input$pci, {
    print(input$pci)
  })
  observeEvent(input$up, {
    updateVsCheckboxInput(
      session, "pci",
      choices = list(
        "animals" = c("cat", "dog"),
        "items" = c("box", "rubber", "scissors")
      ),
      selected = list(
        "animals" = "dog"
      ),
      choicesLabels = c("animals" = "Animals", "items" = "Items")
    )
  })
}
shinyApp(ui, server)
