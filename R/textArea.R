#' Text area component
#'
#' @description
#' Contrary to \link[shiny]{textAreaInput} the component is not a binding itself
#' (doesn't send input to the server).
#' Thanks to that, the component can store much more text value without slowing
#' down the application.
#'
#' If you want to access the component value on request please use \link{valueButton}.
#'
#' @param inputId Id of component.
#' @param value Initial text area value or value to be updated.
#' @param label Text area label.
#' @param width Width of input area.
#' @param height Height of input area.
#' @param resize Text are directions where input field can be resized.
#'   Possible options are "default", "both", "none", "vertical" and "horizontal".
#' @param readonly If TRUE, providing custom values will be turned off.
#'
#' @return Nested list of `shiny.tag` objects defining html structure of the component,
#'   or no value in case of usage of `updateTextArea` method.
#' @export
textArea <- function(inputId, value, label, width = "100%", height = "200px", resize = "default", readonly = FALSE) {
  read_only <- "readonly"
  if (!readonly) {
    read_only <- NULL
  }
  resize <- match.arg(resize, c("default", "both", "none", "vertical", "horizontal"))
  if (resize == "default") {
    resize <- NULL
  }
  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(type = "text/javascript", src = "shinyGizmo/textarea.js")
      )
    ),
    shiny::tags$label(`for` = inputId, label),
    shiny::tags$textarea(
      id = inputId,
      value,
      class = "form-control",
      readonly = read_only,
      style = htmltools::css(
        resize = resize,
        width = width,
        height = height
      )
    )
  )
}

#' @rdname textArea
#' @param session Shiny session object.
#' @export
updateTextArea <- function(session, inputId, value = NULL) {
  session$sendCustomMessage("update_textarea", list(id = inputId, value = value))
}
