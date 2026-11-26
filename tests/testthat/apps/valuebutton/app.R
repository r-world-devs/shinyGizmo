library(shiny)
library(shinyGizmo)

ui <- fluidPage(
  tags$script("window.typedObject = {type: 'custom', size: 1};"),
  tags$textarea(id = "txt", "Lorem Ipsum", style = "width: 300px"),
  sliderInput("sli", "Slider", value = 2, min = 1, max = 5, step = 1),
  sliderInput(
    "date_slider", "Date slider",
    min = as.Date("2023-01-01"), max = as.Date("2023-12-31"), value = as.Date("2023-06-01")
  ),
  valueButton("vb_slider", "Slider value", "#sli"),
  valueButton("vb_date", "Date slider value", "#date_slider"),
  valueButton("vb_date_raw", "Raw date slider value", "#date_slider", try_binding = FALSE),
  valueButton("vb_width", "Text area width", "#txt", "style.width"),
  valueButton("vb_object", "Window object", "window", "typedObject"),
  valueLink("vl_slider", "Slider value (link)", "#sli"),
  valueButton("vb_this", "Own data attribute", "this", "dataset.info", `data-info` = "custom"),
  valueButton("vb_this_value", "Own value", "this"),
  valueLink("vl_this", "Own text (link)", "this", "innerText"),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  ids <- c("vb_slider", "vb_date", "vb_date_raw", "vb_width", "vb_object", "vl_slider", "vb_this", "vb_this_value", "vl_this")
  output$out <- renderPrint(str(stats::setNames(purrr::map(ids, ~ input[[.x]]), ids)))

  exportTestValues(
    vb_slider = input$vb_slider,
    vb_date = format(input$vb_date),
    vb_date_class = class(input$vb_date),
    vb_date_raw = input$vb_date_raw,
    vb_date_raw_class = class(input$vb_date_raw),
    vb_width = input$vb_width,
    vb_object = input$vb_object,
    vl_slider = input$vl_slider,
    vb_this = input$vb_this,
    vb_this_value = input$vb_this_value,
    vl_this = input$vl_this
  )
}

shinyApp(ui, server)
