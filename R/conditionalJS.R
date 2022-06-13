when_switch <- function(x, when) {
  if (!when) {
    x[c("true", "false")] <- x[c("false", "true")]
  }
  return(x)
}

#' JavaScript calls for conditionalJS
#'
#' The list of JavaScript calls that can be used as a `jsCall` argument of \link{conditionalJS}.
#' All the actions are reversible. E.g. when using `disable` call and conditionalJS condition is false
#' the opposite action to disable is called (removing disable attribute).
#'
#' The currently offered actions:
#' \itemize{
#'   \item{attachClass}{ Add provided class to the UI element.}
#'   \item{disable}{ Add disable attribute to the UI element - usually results with disabling the input controller.}
#'   \item{show}{ Show/hide an element with a help of `visibility:hidden` rule.
#'     Comparing to conditionalPanel (which uses display:none) results with rendering an output even if hidden.}
#'   \item{css}{ Add css (inline) rule to the UI object. When condition is false, the rule is removed.}
#'   \item{custom}{ Define custom true and false callback.}
#' }
#'
#' @param class A css to be attached to (or detached from) the UI element.
#' @param important Should `!important` rule be attached to the added css?
#' @param true,false JS callback that should be executed when condition is true or false.
#' @param when Should the (primary) action be executed when `condition` is
#'     TRUE (when = TRUE, default) or FALSE (when = FALSE).
#' @param ... Named style properties, where the name is the property name and the
#'     argument is the property value. See \link[htmltools]{css} for more details.
#' @name js_calls
attachClass <- function(class, when = TRUE) {
  when_switch(
    list(
      true = htmlwidgets::JS(glue::glue("$(this).addClass('{class}');")),
      false = htmlwidgets::JS(glue::glue("$(this).removeClass('{class}');"))
    ),
    when = when
  )
}

#' @rdname js_calls
disable <- function(when = TRUE) {
  when_switch(
    list(
      true = htmlwidgets::JS("$(this).prop('disabled', true);"),
      false = htmlwidgets::JS("$(this).prop('disabled', false);")
    ),
    when = when
  )
}

#' @rdname js_calls
show <- function(when = TRUE) {
  attachClass("sg_hidden", when = !when)
}

#' @rdname js_calls
css <- function(..., important = FALSE, when = TRUE) {
  css_rules <- htmltools::css(...)
  if (important) {
    css_rules <- gsub(";", " !important;", css_rules, fixed = TRUE)
  }
  when_switch(
    list(
      true = htmlwidgets::JS(glue::glue(
        "var current_style = $(this).attr('style')||'';",
        "if (!Boolean(current_style.includes('{css_rules}'))) {{",
        "$(this).attr('style', current_style + '{css_rules}');",
        "}}"
      )),
      false = htmlwidgets::JS(glue::glue(
        "$(this).attr('style', $(this).attr('style')?.replace('{css_rules}', ''));"
      ))
    ),
    when = when
  )
}

#' @rdname js_calls
custom <- function(true = NULL, false = NULL) {
  list(
    true = true,
    false = false
  )
}

#' List of JavaScript calls for `conditionalJS`
#'
#' Each `jsCalls` function can be used as a `jsCall` argument of \link{conditionalJS}.
#' See \link{js_calls} for possible options.
#'
#' @examples
#' conditionalJS(
#'   shiny::tags$button("Hello"),
#'   "input.value > 0",
#'   jsCalls$show()
#' )
#'
#' @export
jsCalls <- list(
  attachClass = attachClass,
  disable = disable,
  show = show,
  css = css,
  custom = custom
)

#' Run JS when condition is met
#'
#' `conditionalJS` is an extended version of \link[shiny]{conditionalPanel}.
#' The function allows to run selected or custom JS action when the provided
#' condition is true or false.
#'
#' To see the possible JS actions check \link{jsCalls}.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     sliderInput("value", "Value", min = 1, max = 9, value = 1),
#'     textOutput("slid_val"),
#'     conditionalJS(
#'       tags$button("Show me when slider value at least 3"),
#'       "input.value >= 3",
#'       jsCalls$show()
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("Show me when value less than 3"),
#'       "input.value >= 3",
#'       jsCalls$show(when = FALSE)
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled when value at least 4"),
#'       "input.value >= 4",
#'       jsCalls$disable()
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled when value less than 4"),
#'       "input.value >= 4",
#'       jsCalls$disable(when = FALSE)
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I have class 'boldme' when value at least 5"),
#'       "input.value >= 5",
#'       jsCalls$attachClass("boldme")
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I change color when value at least 6"),
#'       "input.value >= 6",
#'       jsCalls$custom(
#'         true = "$(this).css('background-color', 'red');",
#'         false = "$(this).css('background-color', 'green');"
#'       )
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I change border when value at least 7"),
#'       "input.value >= 7",
#'       jsCalls$css(
#'         border = "dashed"
#'       )
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled permanently when value at least 8"),
#'       "input.value >= 8",
#'       jsCalls$disable()["true"] # remove false condition
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$slid_val <- renderText({
#'       input$value
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' if (interactive()) {
#'   library(shiny)
#'   library(shinyGizmo)
#'
#'   ui <- fluidPage(
#'     textInput("name", "Name"),
#'     conditionalJS(
#'       actionButton("value", "Type name to enable the button"),
#'       "input.name != ''",
#'       jsCalls$disable(when = FALSE)
#'     )
#'   )
#'
#'   server <- function(input, output, session) {}
#'
#'   shinyApp(ui, server)
#' }
#'
#' @param ui A `shiny.tag` element to which the JS callback should be attached.
#' @param condition A JavaScript expression that will be evaluated repeatedly.
#'    When the evaluated `condition` is true, `jsCall`'s true (`jsCall$true`) callback is run,
#'    when false -  `jsCall$false` is executed in application browser.
#' @param jsCall A list of two `htmltools::JS` outputs named 'true' and 'false' storing JS expressions.
#'    The 'true' object is evaluated when `condition` is true, 'false' otherwise.
#'    In order to skip true/false callback assign it to NULL (or skip).
#'    Use `this` object in the expressions to refer to the `ui` object.
#'    See \link{jsCalls} for possible actions.
#' @param ns The \link[shiny]{NS} object of the current module, if any.
#'
#' @export
conditionalJS <- function(ui, condition, jsCall, ns = shiny::NS(NULL)) {
  if (!inherits(ui, "shiny.tag")) {
    stop(glue::glue("{sQuote('ui')} argument should be a shiny.tag object."))
  }
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$script(type = "text/javascript", src = "shinyGizmo/conditionaljs.js"),
      shiny::tags$link(rel = "stylesheet", type = "text/css", href = "shinyGizmo/conditionaljs.css")
    ),
    htmltools::tagAppendAttributes(
      ui,
      `data-call-if` = condition,
      `data-call-if-true` = jsCall[["true"]],
      `data-call-if-false` = jsCall[["false"]],
      `data-ns-prefix` = ns("")
    )
  )
}
