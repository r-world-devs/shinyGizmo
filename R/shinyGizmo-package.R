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
    })
  }, force = TRUE)
  shiny::registerInputHandler("shinyGizmo.commoninput", function(x, shinysession, name) {
    if (length(x) == 0) return(NULL)
    purrr::map(x, ~ {
      if (length(.) == 0) NA else unlist(.)
    })
  }, force = TRUE)
}

`%:::%` <- function (pkg, name) {
  pkg <- as.character(substitute(pkg))
  name <- as.character(substitute(name))
  get(name, envir = asNamespace(pkg), inherits = FALSE)
}
