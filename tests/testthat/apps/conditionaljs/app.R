library(shiny)
library(shinyGizmo)

count_call <- function(name) {
  sprintf("window.%1$s = (window.%1$s || 0) + 1;", name)
}

module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    checkboxInput(ns("flag"), "Module flag"),
    tags$button(id = ns("btn"), "Module button") |>
      conditionalJS("input.flag", jsCalls$attachClass("flagged"), ns = ns) |>
      conditionalJS("input.value >= 5", jsCalls$disable())
  )
}

ui <- fluidPage(
  tags$style(".boldme {font-weight: bold;}"),
  sliderInput("value", "Value", min = 1, max = 10, value = 1),
  checkboxInput("lock", "Lock"),
  textInput("other", "Other input"),
  tags$button(id = "stacked", "Stacked") |>
    conditionalJS("input.value >= 5", jsCalls$attachClass("boldme")) |>
    conditionalJS("input.lock", jsCalls$disable()),
  conditionalJS(
    tags$button(id = "vectorised", "Vectorised"),
    condition = c("input.value >= 3", "input.value >= 7"),
    jsCall = list(jsCalls$show(), jsCalls$css(color = "red"))
  ),
  conditionalJS(
    tags$button(id = "counter", "Counter"),
    condition = "input.value >= 5",
    jsCall = list(
      jsCalls$custom(true = count_call("count_once"), false = count_call("count_once")),
      jsCalls$custom(true = count_call("count_every"), false = count_call("count_every"))
    ),
    once = c(TRUE, FALSE)
  ),
  tags$div(id = "animated", "Animated") |>
    conditionalJS("input.value >= 3", jsCalls$animateVisibility(duration = 100)) |>
    conditionalJS("input.lock", jsCalls$attachClass("locked")),
  conditionalJS(tags$button(id = "single", "Single"), "input.value >= 5", jsCalls$attachClass("single")),
  module_ui("mod")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
