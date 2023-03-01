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
    purrr::imap(x, ~ {
      name <- .y
      if (!identical(.x$type, FALSE)) {
        name <- paste0(name, ":", .x$type)
      }
      return(`%:::%`("shiny", "applyInputHandler")(name, .x$value, shinysession))
    })
  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.valuebutton", function(x, shinysession, name) {
    if (is.list(x) && (identical(x$type, FALSE) || identical(x$type, NULL))) {
      return(`%:::%`("shiny", "applyInputHandler")("value", x$value, shinysession))
    }
    if (is.list(x) && !is.null(x$type)) {
      return(`%:::%`("shiny", "applyInputHandler")(paste0(x$name, ":", x$type), x$value, shinysession))
    }
    return(x)
  }, force = TRUE)
}

`%:::%` <- function (pkg, name) {
  pkg <- as.character(substitute(pkg))
  name <- as.character(substitute(name))
  get(name, envir = asNamespace(pkg), inherits = FALSE)
}
