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
#' @param inputId Id of component. This is stored as `data-id` attribute to omit automatic binding
#'   of the element (into textAreaInput).
#' @param value Initial text area value or value to be updated.
#' @param label Text area label.
#' @param width Width of input area.
#' @param height Height of input area.
#' @param resize Text are directions where input field can be resized.
#'   Possible options are "default", "both", "none", "vertical" and "horizontal".
#' @param readonly If TRUE, providing custom values will be turned off.
#' @param ... Extra arguments passed to \code{textarea} tag form \link[shiny]{tags}.
#'
#' @return Nested list of `shiny.tag` objects defining html structure of the component,
#'   or no value in case of usage of `updateTextArea` method.
#' @export
textArea <- function(inputId, value, label, width = "100%", height = "200px", resize = "default", readonly = FALSE, ...) {
  args <- rlang::dots_list(...)

  if ("id" %in% names(args)) {
    warning("Assigning id to textarea tag will cause converting it to input binding.")
  }

  read_only <- "readonly"
  if (!readonly) {
    read_only <- NULL
  }
  resize <- match.arg(resize, c("default", "both", "none", "vertical", "horizontal"))
  if (resize == "default") {
    resize <- NULL
  }

  htmltools::attachDependencies(
    shiny::tags$label(
      label,
      shiny::tags$textarea(
        ...,
        `data-id` = inputId,
        value,
        class = "form-control sg_textarea",
        readonly = read_only,
        style = htmltools::css(
          resize = resize,
          width = width,
          height = height,
          font.weight = 400
        )
      ),
      style = htmltools::css(width = width)
    ),
    htmltools::htmlDependency(
      name = "textarea",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "textarea.js"
    )
  )
}

#' @rdname textArea
#' @param session Shiny session object.
#' @export
updateTextArea <- function(session, inputId, value = NULL) {
  session$sendCustomMessage("update_textarea", list(id = session$ns(inputId), value = value))
}
