library(shiny)
library(shinyGizmo)
options("shiny.minified" = FALSE)

ui <- fluidPage(
  tags$style(".boldme {font-weight: bold;}"),
  sliderInput("value", "Value", min = 1, max = 10, value = 1),
  textOutput("slid_val"),
  conditionalJS(
    tags$button("I'm visible when value at least 3"),
    "input.value >= 3",
    jsCalls$show()
  ),
  hr(),
  conditionalJS(
    tags$button("Show me with animation when slider value at least 3"),
    "input.value >= 3",
    jsCalls$animateVisibility(ignoreInit = TRUE, duration = 500)
  ),
  hr(),
  conditionalJS(
    tags$button("I'm visible when value less than 3"),
    "input.value >= 3",
    jsCalls$show(when = FALSE)
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
    jsCalls$disable(when = FALSE)
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
  ),
  hr(),
  conditionalJS(
    tags$button("I bounce when value at least 9"),
    "input.value >= 9",
    jsCalls$custom(true = runAnimation(animation("bounce"))),
    once = FALSE
  )
)

server <- function(input, output, session) {
  output$slid_val <- renderText({
    input$value
  })
}

shinyApp(ui, server)
