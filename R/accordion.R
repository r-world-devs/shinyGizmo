#' Create simple accordion
#'
#' Created component provides basic accordion functionality - enroll/collapse behavior
#' with only necessary styling (enrolled state icon).
#' In order to provide custom styling for accordion items configure its header and content accordingly
#' while constructing the item (see \link{accordionItem}).
#'
#' @examples
#' # Basic construction with simple header and content
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     actionButton("new", "New"),
#'     accordion(
#'       "acc",
#'       accordionItem("first", "Hello", "There", active = TRUE),
#'       accordionItem("second", "General", "Kenobi")
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     observeEvent(input$new, {
#'       addAccordionItem("acc", accordionItem(sample(letters, 1), "New", "Accordion", active = TRUE))
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @param id Id of the accordion component.
#' @param ... Accordion items created with \link{accordionItem}.
#' @param class Extra class added to accordion container.
#'
#' @return A `shiny.tag` object defining html structure of accordion container.
#' @export
accordion <- function(id, ..., class = "") {

  htmltools::attachDependencies(
    shiny::div(id = id, class = paste("sg_accordion", class), ...),
    htmltools::htmlDependency(
      name = "accordion",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "accordion.js",
      stylesheet = "accordion.css"
    )
  )
}

#' Create accordion item
#'
#' `accordionItem` allows to create new accordion item that can be passed directly to `accordion`
#' constructor or added on the fly with `addAccordionItem`.
#'
#' @examples
#' if (interactive()) {
#'    library(shiny)
#'    ui <- fluidPage(
#'      actionButton("new", "New"),
#'      accordion(
#'        "acc",
#'        accordionItem("first", "Hello", "There", active = TRUE),
#'        accordionItem("second", "General", "Kenobi")
#'      )
#'    )
#'    server <- function(input, output, session) {}
#'    shinyApp(ui, server)
#'
#'   # Accordion with custom styling of header and content (and dynamically added items).
#'   library(shiny)
#'
#'   styled_item <- function(id, header_text, content_text, active = FALSE) {
#'     accordionItem(
#'       id, header_text, content_text, active = active,
#'       header_class = "acc-header", content_class = "acc-content"
#'     )
#'   }
#'   ui <- fluidPage(
#'     tags$head(tags$style(
#'       ".acc-header, .acc-content {border: 1px solid; border-radius: 5px;}"
#'     )),
#'     actionButton("new", "New"),
#'     accordion(
#'       "acc",
#'       styled_item("first", "Hello", "There", TRUE),
#'       styled_item("second", "General Kenobi", "There")
#'     )
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$new, {
#'       addAccordionItem(
#'         "acc",
#'         styled_item(
#'           sample(letters, 1), "I've Been Trained In Your Jedi Arts",
#'           "By Count Dooku", TRUE
#'         )
#'       )
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @param id Unique id of accordion item.
#' @param header Accordion item header.
#' @param content Accordion item content.
#' @param class Class passed to accordion container.
#' @param enroll_callback It `TRUE`, click action on header will enroll the accordion
#'    item (and collapse the other existing ones).
#'    See \link{accordionEnrollOnClick} to see how configure custom on-click enroll element.
#' @param active Should item be enrolled?
#' @param header_class Additional class passed to header container.
#' @param content_class Additional class passed to content container.
#' @param ... Extra elements passed to accordion container (before the first accordion item).
#'
#' @return Nested list of `shiny.tag` objects, defining accordion item - its header and content,
#'   or no return value in case of using `addAccordionItem` method.
#' @export
accordionItem <- function(id, header, content, class = NULL, enroll_callback = TRUE, active = FALSE,
                          header_class = NULL, content_class = NULL, ...) {

  if (!enroll_callback) {
    accordionEnrollOnClick <- function() NULL
    activatorClass <- NULL
  }
  acc <- shiny::div(
    id = id, class = paste("sg_accordion_item", class),
    ...,
    shiny::div(
      class = paste("header", activatorClass, header_class),
      shiny::div(class = "btn-xs enroll-icon", shiny::icon("chevron-right", class = "rotate"), style = "display: inline-block;"),
      header, onclick = accordionEnrollOnClick()
    ),
    shiny::div(class = paste("content", content_class), content)
  )
  if (!active) {
    acc <- acc %>%
      shiny::tagAppendAttributes(class = "collapsed")
  }
  acc
}

#' @param accordionId Id of accordion component where item should be added.
#' @param accordionItem Accordion item to be added.
#' @param session Shiny Session object.
#'
#' @rdname accordionItem
#'
#' @export
addAccordionItem <- function(accordionId, accordionItem, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("collapse_items", list(id = accordionId))
  shiny::insertUI(
    selector = glue::glue("#{accordionId}"),
    where = "beforeEnd",
    accordionItem,
    immediate = TRUE
  )
}

#' Define Enroll/Collapse trigger
#'
#' @description
#'
#' The function is useful if you want to override standard behavior for activating accordion item.
#' By default accordion item is activated when its header is clicked.
#'
#' In order to point the trigger to a different object (included in item's header or content)
#' attach `onclick = accordionEnrollOnClick()` attribute to the element.
#' Remember to set `enroll_callback = FALSE` to turn off standard activation behavior (click action on header).
#'
#' If you want the item to be disabled (like button) when the item is enrolled please also add
#' `class = activatorClass` to it.
#'
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   activator <- function(disabled = FALSE) {
#'     tags$button(
#'       "Enroll", class = activatorClass, onclick = accordionEnrollOnClick(),
#'       disabled = if (isTRUE(disabled)) NA else NULL
#'     )
#'   }
#'   ui <- fluidPage(
#'     tags$head(tags$style(
#'       ".acc-header, .acc-content {border: 1px solid; border-radius: 5px;}"
#'     )),
#'     accordion(
#'       "acc",
#'       accordionItem(
#'         "first", div("Hello", activator(TRUE)), "There",
#'         enroll_callback = FALSE, active = TRUE
#'       ),
#'       accordionItem(
#'         "second", div("General", activator(FALSE)), "Kenobi",
#'         enroll_callback = FALSE
#'       )
#'     )
#'   )
#'   server <- function(input, output, session) {}
#'
#'   shinyApp(ui, server)
#' }
#'
#' @param prev Should the current (FALSE) or previous (TRUE) item be enrolled?
#'   `prev = TRUE` can be useful if the last accordion item is removed and we want
#'   to enroll the preceding item.
#'
#' @return `html` class string that can be used for defining i.e. `onclick`
#'   attribute callback.
#' @export
accordionEnrollOnClick <- function(prev = FALSE) {
  prev <- if (prev) "true" else "false"
  shiny::HTML(glue::glue("collapse_rest(this, {prev});"))
}

#' @rdname accordionEnrollOnClick
#'
#' @return Character string - class name used for identifying accordion activator object.
#' @export
activatorClass <- "sg_accordion_activator"
