on_switch <- function(x, on) {
  if (!on) {
    x[c("true", "false")] <- x[c("false", "true")]
  }
  return(x)
}

attachClass <- function(class, on = TRUE) {
  on_switch(
    list(
      true = htmlwidgets::JS(glue::glue("el.addClass('{class}')")),
      false = htmlwidgets::JS(glue::glue("el.removeClass('{class}')"))
    ),
    on = on
  )
}

disable <- function(on = TRUE) {
  on_switch(
    list(
      true = htmlwidgets::JS("el.prop('disabled', true)"),
      false = htmlwidgets::JS("el.prop('disabled', false)")
    ),
    on = on
  )
}

show <- function(on = TRUE) {
  attachClass("sg_hidden", on = !on)
}

custom <- function(true, false) {
  list(
    true = true,
    false = false
  )
}

#' @export
jsCalls <- list(
  attachClass = attachClass,
  disable = disable,
  show = show,
  custom = custom
)

#' @export
ifCall <- function(ui, condition, jsCall, ns = shiny::NS(NULL)) {
  if (!inherits(ui, "shiny.tag")) {
    stop(glue::glue("{sQuote('ui')} argument should be a shiny.tag object."))
  }
  tagList(
    shiny::tags$head(
      shiny::tags$script(type = "text/javascript", src = "shinyGizmo/jscall.js"),
      shiny::tags$link(rel = "stylesheet", type = "text/css", href = "shinyGizmo/jscall.css")
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
