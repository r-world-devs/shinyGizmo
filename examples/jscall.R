library(shiny)
library(shinyGizmo)
options("shiny.minified" = FALSE)

ui <- fluidPage(
  tags$style(".boldme {font-weight: bold;}"),
  sliderInput("value", "Value", min = 1, max = 9, value = 1),
  textOutput("bu"),
  conditionalJS(
    tags$button("I'm visible when value at least 3"),
    "input.value >= 3",
    jsCalls$show()
  ),
  hr(),
  conditionalJS(
    tags$button("I'm visible when value less than 3"),
    "input.value >= 3",
    jsCalls$show(when =FALSE)
  ),
  hr(),
  conditionalJS(
    tags$button("I'm disabled when value at least 4"),
    "input.value >= 4",
    jsCalls$disable()
  ),
  hr(),
  conditionalJS(
    tags$button("I'm disabled when value less than 4"),
    "input.value >= 4",
    jsCalls$disable(when =FALSE)
  ),
  hr(),
  conditionalJS(
    tags$button("I have class 'boldme' when value at least 5"),
    "input.value >= 5",
    jsCalls$attachClass("boldme")
  ),
  hr(),
  conditionalJS(
    tags$button("I change color when value at least 6"),
    "input.value >= 6",
    jsCalls$custom(
      true = "$(this).css('background-color', 'red');",
      false = "$(this).css('background-color', 'green');"
    )
  ),
  hr(),
  conditionalJS(
    tags$button("I change border when value at least 7"),
    "input.value >= 7",
    jsCalls$css(
      border = "dashed"
    )
  ),
  hr(),
  conditionalJS(
    tags$button("I'm disabled permanently when value at least 8"),
    "input.value >= 8",
    jsCalls$disable()["true"] # remove false condition
  )
)

server <- function(input, output, session) {
  output$bu <- renderText({
    input$oko
  })
}

shinyApp(ui, server)
