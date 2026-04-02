#' Define CSS rules for a container query condition
#'
#' Creates a condition object specifying CSS rules that apply when a container
#' query matches. Used within \code{\link{container}} to define responsive styles.
#'
#' @param ... Named CSS properties applied to the container's content element.
#'   Property names use CSS syntax (e.g., \code{`background-color` = "red"}).
#' @param query Container query condition string (e.g., \code{"width > 1200px"}).
#'   When \code{NULL} (default), styles are applied unconditionally.
#' @param .extra_css Named list of CSS rules for child selectors.
#'   Names are CSS selectors (e.g., \code{".first"}), values are CSS strings
#'   typically created with \code{\link[htmltools]{css}}.
#'
#' @return A condition object (list) for use in \code{\link{container}}.
#'
#' @examples
#' condition(
#'   `background-color` = "red",
#'   query = "width > 1200px",
#'   .extra_css = list(
#'     `.first` = htmltools::css(`min-width` = "300px", height = "400px")
#'   )
#' )
#'
#' # Unconditional base styles (query = NULL)
#' condition(
#'   !!!grid(template_areas = list(c("a", "b")))
#' )
#'
#' @export
condition <- function(..., query = NULL, .extra_css = NULL) {
  structure(
    list(
      query = query,
      css = rlang::dots_list(..., .named = TRUE),
      extra_css = .extra_css
    ),
    class = "container_condition"
  )
}

#' Generate a condition CSS block
#'
#' @param cond A \code{container_condition} object.
#' @param container_name Name of the container (used for CSS selectors).
#' @return Character string of CSS rules.
#' @noRd
condition_to_css <- function(cond, container_name) {
  blocks <- character(0)
  content_selector <- glue::glue(".sg-container-content[for=\"{container_name}\"]")

  if (length(cond$css) > 0) {
    content_css <- as.character(htmltools::css(!!!cond$css))
    blocks <- c(blocks, glue::glue("{content_selector} {{ {content_css} }}"))
  }

  if (length(cond$extra_css) > 0) {
    extra_blocks <- purrr::imap_chr(cond$extra_css, function(css_val, selector) {
      glue::glue("{content_selector} {selector} {{ {css_val} }}")
    })
    blocks <- c(blocks, extra_blocks)
  }

  content <- paste(blocks, collapse = "\n")

  if (!is.null(cond$query)) {
    glue::glue("@container {container_name} ({cond$query}) {{\n{content}\n}}")
  } else {
    content
  }
}

#' Create a CSS container query wrapper
#'
#' Wraps child elements in a container with CSS Container Query support.
#' Allows responsive styles based on the container's own dimensions rather
#' than the viewport.
#'
#' @param name Container name. Used as the CSS \code{container-name} and
#'   as a class on the wrapper element for CSS targeting.
#' @param ... Child UI elements.
#' @param conditions List of \code{\link{condition}} objects defining the
#'   CSS rules and container queries.
#' @param type Container type: \code{"inline-size"} (default), \code{"size"},
#'   or \code{"normal"}.
#' @param class Additional CSS classes for the container div.
#' @param .style Additional inline CSS styles (as a string or
#'   \code{\link[htmltools]{css}} output).
#'
#' @return A \code{\link[htmltools]{tag}} object.
#'
#' @examples
#' container(
#'   name = "demo",
#'   shiny::div(class = "a", "A") |> grid_item(area = "a"),
#'   shiny::div(class = "b", "B") |> grid_item(area = "b"),
#'   conditions = list(
#'     condition(!!!grid(template_areas = list(c("a", "b")))),
#'     condition(
#'       query = "width < 600px",
#'       !!!grid(template_areas = list(c("a"), c("b")))
#'     )
#'   )
#' )
#'
#' @export
container <- function(name, ..., conditions = list(), type = "inline-size",
                      class = NULL, .style = NULL) {
  children <- rlang::dots_list(...)

  css_rules <- purrr::map_chr(conditions, ~ condition_to_css(.x, container_name = name)) |>
    paste(collapse = "\n\n") |>
    shiny::HTML()

  container_classes <- paste(c(name, class), collapse = " ")

  htmltools::div(
    class = container_classes,
    style = htmltools::css(`container-type` = type, `container-name` = name),
    style = .style,
    htmltools::div(
      class = "sg-container-content",
      `for` = name,
      !!!children
    )
  ) |>
    htmltools::attachDependencies(
      htmltools::htmlDependency(
        name = paste0("container-", name),
        version = "0.1.0",
        src = "/tmp",
        head = shiny::HTML(as.character(htmltools::tags$style(css_rules)))
      )
    )
}

#' Generate CSS grid properties
#'
#' Returns a named list of CSS grid properties suitable for splicing into
#' \code{\link{condition}} via the \code{!!!} operator.
#'
#' @param template_areas List of character vectors defining grid template areas.
#'   Each vector represents a row: \code{list(c("a", "b"), c("c", "d"))}
#'   produces \code{"a b" "c d"}.
#' @param template_rows CSS value for \code{grid-template-rows}.
#' @param template_columns CSS value for \code{grid-template-columns}.
#' @param gap CSS value for \code{gap}.
#' @param align_items CSS value for \code{align-items}.
#' @param justify_items CSS value for \code{justify-items}.
#' @param align_content CSS value for \code{align-content}.
#' @param justify_content CSS value for \code{justify-content}.
#' @param auto_columns CSS value for column sizing. When \code{auto_fill = TRUE},
#'   used in \code{repeat(auto-fill, ...)} for \code{grid-template-columns}.
#'   Otherwise maps to \code{grid-auto-columns}.
#' @param auto_rows CSS value for row sizing. When \code{auto_fill = TRUE},
#'   used in \code{repeat(auto-fill, ...)} for \code{grid-template-rows}.
#'   Otherwise maps to \code{grid-auto-rows}.
#' @param auto_fill Logical. When \code{TRUE}, wraps \code{auto_columns}/\code{auto_rows}
#'   in \code{repeat(auto-fill, ...)}.
#' @param ... Additional named CSS properties to include.
#'
#' @return A named list of CSS properties.
#'
#' @examples
#' # Two-column layout
#' grid(template_areas = list(c("sidebar", "main")))
#'
#' # Responsive auto-fill columns
#' grid(auto_fill = TRUE, auto_columns = "minmax(200px, 1fr)")
#'
#' @export
grid <- function(template_areas = NULL, template_rows = NULL, template_columns = NULL,
                 gap = NULL, align_items = NULL, justify_items = NULL,
                 align_content = NULL, justify_content = NULL,
                 auto_columns = NULL, auto_rows = NULL,
                 auto_fill = FALSE, ...) {
  css <- list(display = "grid")

  if (!is.null(template_areas)) {
    rows <- purrr::map_chr(template_areas, ~ paste0('"', paste(.x, collapse = " "), '"'))
    css[["grid-template-areas"]] <- paste(rows, collapse = " ")
  }

  if (!is.null(template_columns)) {
    css[["grid-template-columns"]] <- template_columns
  } else if (auto_fill && !is.null(auto_columns)) {
    css[["grid-template-columns"]] <- paste0("repeat(auto-fill, ", auto_columns, ")")
  }

  if (!is.null(template_rows)) {
    css[["grid-template-rows"]] <- template_rows
  } else if (auto_fill && !is.null(auto_rows)) {
    css[["grid-template-rows"]] <- paste0("repeat(auto-fill, ", auto_rows, ")")
  }

  if (!is.null(gap)) css[["gap"]] <- gap
  if (!is.null(align_items)) css[["align-items"]] <- align_items
  if (!is.null(justify_items)) css[["justify-items"]] <- justify_items
  if (!is.null(align_content)) css[["align-content"]] <- align_content
  if (!is.null(justify_content)) css[["justify-content"]] <- justify_content

  if (!auto_fill && !is.null(auto_columns)) css[["grid-auto-columns"]] <- auto_columns
  if (!auto_fill && !is.null(auto_rows)) css[["grid-auto-rows"]] <- auto_rows

  extra <- rlang::dots_list(..., .named = TRUE)
  c(css, extra)
}

#' Set CSS grid item placement on a UI element
#'
#' Adds grid item CSS properties to a tag element. Pipe-friendly for use
#' with the base pipe \code{|>} or magrittr \code{\%>\%}.
#'
#' @param ui A \code{\link[htmltools]{tag}} object to modify.
#' @param area CSS \code{grid-area} value (e.g., a named area from
#'   \code{grid-template-areas}).
#' @param row_start CSS \code{grid-row-start} value.
#' @param row_end CSS \code{grid-row-end} value.
#' @param column_start CSS \code{grid-column-start} value.
#' @param column_end CSS \code{grid-column-end} value.
#' @param align_self CSS \code{align-self} value.
#' @param justify_self CSS \code{justify-self} value.
#'
#' @return The modified \code{\link[htmltools]{tag}} with grid styles appended.
#'
#' @examples
#' shiny::div("Sidebar content") |> grid_item(area = "sidebar")
#'
#' shiny::div("Spanning item") |> grid_item(column_start = 1, column_end = 3)
#'
#' @export
grid_item <- function(ui, area = NULL, row_start = NULL, row_end = NULL,
                      column_start = NULL, column_end = NULL,
                      align_self = NULL, justify_self = NULL) {
  styles <- list()

  if (!is.null(area)) styles[["grid-area"]] <- area

  if (!is.null(row_start) || !is.null(row_end)) {
    parts <- c(row_start %||% "", row_end %||% "")
    parts <- parts[nzchar(parts)]
    styles[["grid-row"]] <- paste(parts, collapse = " / ")
  }

  if (!is.null(column_start) || !is.null(column_end)) {
    parts <- c(column_start %||% "", column_end %||% "")
    parts <- parts[nzchar(parts)]
    styles[["grid-column"]] <- paste(parts, collapse = " / ")
  }

  if (!is.null(align_self)) styles[["align-self"]] <- align_self
  if (!is.null(justify_self)) styles[["justify-self"]] <- justify_self

  if (length(styles) > 0) {
    ui <- htmltools::tagAppendAttributes(ui, style = htmltools::css(!!!styles))
  }

  ui
}
