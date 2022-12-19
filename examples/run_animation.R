library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  tags$head(
    tags$script(
      "var update_attr = function(message) {$('#' + message.id).attr(message.attribute, message.value)};",
      "Shiny.addCustomMessageHandler('update_attr', update_attr);"
    ),
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("effect", "Animation type", choices = .cssEffects)
    ),
    mainPanel(
      conditionalJS(
        ui = plotOutput("cars"),
        condition = "input.effect != ''",
        jsCall = jsCalls$custom(true = runAnimation(animation("bounce"))),
        once = FALSE
      )
    )
  )
)

server <- function(input, output, session) {
  output$cars <- renderPlot({
    plot(mtcars$mpg, mtcars$qsec)
  })
  observeEvent(input$effect, {
    session$sendCustomMessage(
      "update_attr",
      list(id = "cars", attribute = "data-call-if-true", value = runAnimation(animation(input$effect)))
    )
  })
}

shinyApp(ui, server)
