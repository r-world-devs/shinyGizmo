#' Useful Components For Shiny Applications
#'
#' @name shinyGizmo-package
#' @importFrom magrittr %>%

NULL

.onLoad <- function(...) {
  shiny::addResourcePath('shinyGizmo', system.file("www", package = "shinyGizmo"))
  shiny::registerInputHandler("shinyGizmo.pickcheckbox", function(x, shinysession, name) {
    if (length(x) == 0) return(NULL)
    purrr::map(x, ~ {
      if (length(.) == 0) NA else unlist(.)
    }) %>%
      purrr::map_if(~all(.x %in% c("TRUE", "FALSE", "NA")), as.logical)

  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.commoninput", function(x, shinysession, name) {
    if (length(x) == 0) return(NULL)
    `%:::%`("shiny", "applyInputHandlers")(x, shinysession)
  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.controlinput", function(x, shinysession, name) {
    value <- `%:::%`("shiny", "applyInputHandler")(names(x$value)[1], x$value[[1]], shinysession)
    if (is.null(value) || length(x$attributes) == 0) {
      return(value)
    }
    purrr::reduce2(
      names(x$attributes), x$attributes,
      function(value, attr_name, attr_value) {
        if (is.list(attr_value) && all(lengths(attr_value) == 1)) {
          attr_value <- unlist(attr_value)
        }
        attr(value, attr_name) <- attr_value
        value
      },
      .init = value
    )
  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.valuebutton", function(x, shinysession, name) {
    x
  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.valuebutton.binding", function(x, shinysession, name) {
    if (length(x) == 0) return(NULL)
    `%:::%`("shiny", "applyInputHandler")(names(x)[1], x[[1]], shinysession)
  }, force = TRUE)
}

`%:::%` <- function (pkg, name) {
  pkg <- as.character(substitute(pkg))
  name <- as.character(substitute(name))
  get(name, envir = asNamespace(pkg), inherits = FALSE)
}
