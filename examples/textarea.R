library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(actionButton("update", "Update"), width = 1),
    mainPanel(textArea(
      "lorem",
      label = "Lorem Ipsum",
      value = paste(stringi::stri_rand_lipsum(n_paragraphs = 200), collapse = "\n"),
      height = "300px"
    ), width = 11)
  )
)

server <- function(input, output, session) {
  observeEvent(input$update, {
    updateTextArea(
      session, "lorem",
      stringi::stri_rand_lipsum(n_paragraphs = 100, FALSE)
    )
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)
