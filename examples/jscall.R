library(shiny)
library(shinyGizmo)
options("shiny.minified" = FALSE)

ui <- fluidPage(
  tags$style(".boldme {font-weight: bold;}"),
  actionButton("oko", "Oko"),
  textOutput("bu"),
  ifCall(
    tags$button("I'm visible when at least 3 clicks"),
    "input.oko >= 3",
    jsCalls$show()
  ),
  ifCall(
    tags$button("I'm visible when less than 3 clicks"),
    "input.oko >= 3",
    jsCalls$show(on = FALSE)
  ),
  ifCall(
    tags$button("I'm disabled when at least 4 clicks"),
    "input.oko >= 4",
    jsCalls$disable()
  ),
  ifCall(
    tags$button("I'm disabled when less than 4 clicks"),
    "input.oko >= 4",
    jsCalls$disable(on = FALSE)
  ),
  ifCall(
    tags$button("I have class 'boldme' when at least 5 clicks"),
    "input.oko >= 5",
    jsCalls$attachClass("boldme")
  ),
  ifCall(
    tags$button("I change color when at least 6 clicks"),
    "input.oko >= 6",
    jsCalls$custom(
      true = "el.css('background-color', 'red');",
      false = "el.css('background-color', 'green');"
    )
  )
)

server <- function(input, output, session) {
  output$bu <- renderText({
    input$oko
  })
}

shinyApp(ui, server)
