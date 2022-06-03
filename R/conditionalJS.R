when_switch <- function(x, when) {
  if (!when) {
    x[c("true", "false")] <- x[c("false", "true")]
  }
  return(x)
}

#' Javascript calls
#'
#' @name js_calls
#' @export
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
#' @export
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
#' @export
show <- function(when = TRUE) {
  attachClass("sg_hidden", when = !when)
}

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
#' @export
custom <- function(true = NULL, false = NULL) {
  list(
    true = true,
    false = false
  )
}

#' Oko
#'
#' See \link{js_calls} for options.
#' @export
jsCalls <- list(
  attachClass = attachClass,
  disable = disable,
  show = show,
  css = css,
  custom = custom
)

#' @export
conditionalJS <- function(ui, condition, jsCall, ns = shiny::NS(NULL)) {
  if (!inherits(ui, "shiny.tag")) {
    stop(glue::glue("{sQuote('ui')} argument should be a shiny.tag object."))
  }
  tagList(
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
