#' Create modal in UI application part
#'
#' Contrary to \link[shiny]{modalDialog} the function allows to define modal in
#' UI application structure.
#' The button can be opened with `modalButtonUI` placed anywhere in the application.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   shinyApp(
#'     ui = fluidPage(
#'       modalDialogUI("mdl", "Hello")
#'     ),
#'     server = function(input, output, session) {}
#'   )
#'
#'   library(shiny)
#'   shinyApp(
#'     ui = fluidPage(
#'       modalDialogUI("mdl", "Hello", button = NULL),
#'       hr(),
#'       modalButtonUI("mdl", "Open Modal From Here")
#'     ),
#'     server = function(input, output, session) {}
#'   )
#' }
#'
#' @param modalId Id of the modal.
#' @param ... Modal dialog content.
#' @param button Visible button placed in modal DOM structure, responsible for opening it.
#'     Set `NULL` to have no button included.
#' @param title An optional title for the modal dialog.
#' @param footer UI for modal dialog footer.
#' @param size of the modal dialog. Can be "s", "m" (default), "l" or "xl".
#' @param easyClose Set `TRUE` to enable closing modal with clicking outside it.
#' @param fade Should fade-in animation be turned on?
#' @param backdrop Set `FALSE` to turn on background covering area outside modal dialog.
#'
#' @return Nested list of `shiny.tag` objects defining html structure of modal dialog,
#'   or single `shiny.tag` object in case of using `modalButtonUI` method.
#' @export
modalDialogUI <- function(modalId, ..., button = modalButtonUI(modalId, "Open Modal"),
                          title = NULL, footer = shiny::modalButton("Dismiss"),
                          size = c("m", "s", "l", "xl"), easyClose = FALSE, fade = TRUE, backdrop = TRUE) {
  size <- match.arg(size)
  backdrop <- if (backdrop && !easyClose) "static" else "false"
  keyboard <- if (!easyClose) "false"

  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(type = "text/javascript", src = "shinyGizmo/modal.js")
      )
    ),
    button,
    shiny::div(
      id = modalId, class = "modal", class = if (fade) "fade",
      tabindex = "-1", `data-backdrop` = backdrop,
      `data-bs-backdrop` = backdrop, `data-keyboard` = keyboard,
      `data-bs-keyboard` = keyboard,
      `aria-labelledby` = paste0(modalId, "label"), `aria-hidden` = "true",
      shiny::div(
        class = "modal-dialog",
        class = switch(size, s = "modal-sm", m = NULL, l = "modal-lg", xl = "modal-xl"),
        shiny::div(
          class = "modal-content",
          if (!is.null(title)) {
            shiny::div(
              class = "modal-header",
              shiny::tags$h4(class = "modal-title", title, id = paste0(modalId, "label"))
            )
          },
          shiny::div(class = "modal-body", ...),
          if (!is.null(footer)) {
            shiny::div(class = "modal-footer", footer)
          }
        )
      )
    )
  )
}

#' @rdname modalDialogUI
#' @param label Modal button label.
#' @param icon Modal button icon.
#' @param width Button width.
#' @param ... Additional properties added to button.
#'
#' @export
modalButtonUI <- function(modalId, label, icon = NULL, width = NULL, ...) {
  shiny::tags$button(
    list(icon, label),
    style = htmltools::css(width = htmltools::validateCssUnit(width)),
    type = "button",
    class = "btn btn-default",
    `data-toggle` = "modal",
    `data-target` = paste0("#", modalId),
    ...
  )
}

#' Show and hide modal from the application server

#' @param modalId Id of the modal to show/hide.
#' @param session Shiny session object.
#' @name modal-operations
#'
#' @return No return value, used for side effect.
#' @export
hideModalUI <- function(modalId, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("hide_modal", list(id = modalId))
}

#' @rdname modal-operations
#' @export
showModalUI <- function(modalId, session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage("show_modal", list(id = modalId))
}
