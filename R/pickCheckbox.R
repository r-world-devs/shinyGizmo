hidden_class <- function(hide) {
  ifelse(hide, "sg_hidden", "")
}

extract_choices_names <- function(choices) {
  purrr::map(
    choices,
    unname
  )
}

extract_choice_values <- function(choices) {
  purrr::map(
    choices,
    unname
  )
}

complete_list <- function(value, n, default, merger = append, coverter = as.list) {
  base <- rep(default, n)

  if (!is.null(names(value))) {
    n_source <- length(value)
    return(
      merger(
        value,
        stats::setNames(coverter(base), as.character((n_source + 1):(n_source + n)))
      )
    )
  } else {
    return(
      merger(
        value,
        coverter(base)
      )
    )
  }
}

extend_list <- function(value, n, default) {
  if (is.null(n)) {
    return(value)
  }
  if (is.null(value)) {
    value <- default
  }

  n_val <- length(value)
  n_rest <- n - n_val

  if (n_rest == 0) {
    return(value)
  }

  if (n_val > n) {
    stop("Increase max_groups option.")
  }

  if (is.list(value)) {
    return(
      complete_list(value, n_rest, default, append, as.list)
    )
  }

  if (is.vector(value)) {
    return(
      complete_list(value, n_rest, default, c, function(x) x)
    )
  }
}

match_selected <- function(selected, choices) {
  if (is.null(selected)) {
    return(purrr::modify(choices, function(x) NULL))
  }
  utils::modifyList(choices, purrr::keep(selected, ~identical(., NA) | !is.null(.)))
}

form_checkboxes_input <- function(inputId, choices, choicesNames, choicesLabels, selected = NULL, max_groups = NULL) {
  if (missing(max_groups)) {
    max_groups <- length(choices)
  }
  n_id <- length(choices)
  if (!is.null(max_groups)) {
    n_id <- max_groups
  }
  # todo build data frame and transpose with purrr for significant speedup
  list(
    inputId = paste0(inputId, "_chbx_", 1:n_id),
    label = extend_list(choicesLabels, max_groups, ""),
    choiceNames = extend_list(extract_choices_names(choicesNames), max_groups, list(NULL)),
    choiceValues = extend_list(extract_choice_values(choices), max_groups, list(NULL)),
    selected = extend_list(match_selected(selected, choices), max_groups, list(NULL)),
    name = extend_list(names(choices), max_groups, ""),
    hidden = extend_list(hidden_class(!names(choices) %in% names(selected)), max_groups, TRUE)
  )
}

renderCheckboxes <- function(inputId, choices, choicesNames, choicesLabels, selected, max_groups) {
  purrr::pmap(
    form_checkboxes_input(inputId, choices, choicesNames, choicesLabels, selected, max_groups),
    function(name, hidden, ...) {
      shiny::checkboxGroupInput(..., inline = TRUE) %>%
        shiny::tagAppendAttributes(`data-name` = name, class = hidden, `data-ignore` = TRUE)
    }
  )
}

attachPickerAttr <- function(picker, name, value) {
  picker$children[[2]]$attribs[[name]] <- value

  return(picker)
}


form_checkboxes_update <- function(choices, choicesNames, choicesLabels, selected) {
  params <- list(
    label = if (!missing(choicesLabels)) choicesLabels,
    choiceNames = if (!missing(choicesNames)) extract_choices_names(choicesNames),
    choiceValues = if (!missing(choices)) extract_choice_values(choices),
    selected = if (!missing(selected)) {
      if (is.null(selected)) {
        NULL
      } else {
        if (!missing(choices) && !is.null(choices)) {
          utils::modifyList(choices, selected)
        } else {
          selected
        }
      }
    },
    name = if (!missing(choices)) names(choices) else if (!missing(selected)) names(selected)
  ) %>%
    purrr::keep(~ !is.null(.))

  params$inline <- rep(TRUE, length(params[[1]]))

  return(params)
}

prep_input <- function(label = NULL, choices = NULL, selected = NULL, inline = FALSE,
                       choiceNames = NULL, choiceValues = NULL, ...) {
  args <- `%:::%`("shiny", "normalizeChoicesArgs")(choices, choiceNames, choiceValues, mustExist = FALSE)
  if (!is.null(selected)) {
    selected <- as.character(selected)
  }
  options <- if (!is.null(args$choiceValues)) {
    format(
      shiny::tagList(
        `%:::%`("shiny", "generateOptions")("__tmp_id__", selected, inline, "checkbox", args$choiceNames, args$choiceValues)
      )
    )
  }
  message <- `%:::%`("shiny", "dropNulls")(list(label = label, options = options, value = selected, ...))
  return(message)
}

#' Generate names and labels
#'
#' Two functions extracting group names and options labels from defined choices.
#'
#' @examples
#' choices_unnamed <- list(
#'   fruits = c("orange", "apple", "lemon"),
#'   vegetables = c("potato", "carrot", "broccoli")
#' )
#' pickCheckboxNames(choices_unnamed)
#' pickCheckboxLabels(choices_unnamed)
#'
#' choices_named <- list(
#'   fruits = c("Orange" = "orange", "Apple" = "apple", "Lemon" = "lemon"),
#'   vegetables = c("Potato" = "potato", "Carrot" = "carrot", "Broccoli" = "broccoli")
#' )
#' pickCheckboxNames(choices_named)
#' pickCheckboxLabels(choices_named)
#'
#' @name pickCheckboxNamesAndLabels
#'
#' @return Named list object defining labels for component checkbox options, or
#' named vector storing labels for each checkbox.
#' @param choices link{pickCheckboxInput} choices list.
#' @export
pickCheckboxNames <- function(choices) {
  choices %>%
    purrr::map(
      ~ if (is.null(names(.))) {as.character(.)} else {names(.)}
    )
}

#' @rdname pickCheckboxNamesAndLabels
#' @export
pickCheckboxLabels <- function(choices) {
  stats::setNames(names(choices), names(choices))
}

# todo when values(a = NULL) - make it mean a is not selected
# how to handle case when value(a = ??) a selected but with no choice?
# maybe value(a = character(0)) ??
# or just add variables to filter and then all fine <- I think the best option

#' Select set of active checkbox groups and their values
#'
#' @description
#' The component is connection of dropdown (\link[shinyWidgets]{pickerInput})
#' (or \link[shinyWidgets]{virtualSelectInput}) and
#' set of checkbox groups (\link[shiny]{checkboxGroupInput}).
#'
#' When specific value is selected in dropdown, the related checkbox group becomes active
#' and becomes visible to the user.
#'
#' @examples
#' # Possible choices and selected configurations
#'
#' # Choices as list of unnamed options
#' # Names are the same as values in the component (if not precised elsewhere)
#' choices_unnamed <- list(
#'   fruits = c("orange", "apple", "lemon"),
#'   vegetables = c("potato", "carrot", "broccoli")
#' )
#' # selected only fruits plus orange one within
#' selected_unnamed <- list(
#'   fruits = c("orange")
#' )
#' # Names for each group precised separately
#' choices_names = list(
#'   fruits = c("Orange", "Apple", "Lemon"),
#'   vegetables = c("Potato", "Carrot", "Broccoli")
#' )
#'
#' # Choices as list of named options
#' # Names are treated as checkbox options labels
#' choices_named <- list(
#'   fruits = c("Orange" = "orange", "Apple" = "apple", "Lemon" = "lemon"),
#'   vegetables = c("Potato" = "potato", "Carrot" = "carrot", "Broccoli" = "broccoli")
#' )
#' # selected: fruits plus orange and vegetables carrot
#' selected_named <- list(
#'   fruits = c("orange"),
#'   vegetables= c("carrot")
#' )
#'
#' # Same but vegetables selected but empty
#' # Set group as NA to no options checked (same effect in server input)
#' selected_named_empty <- list(
#'   fruits = c("orange"),
#'   vegetables = NA
#' )
#'
#' # Specifying picker and group labels ("key" = "name" rule)
#' choices_labels <- list("fruits" = "Fruits", "vegetables" = "Vegetables")
#'
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     sidebarLayout(sidebarPanel(
#'       pickCheckboxInput(
#'         "pci1", "1. No names at all",
#'         choices = choices_unnamed, selected = selected_unnamed
#'       ), hr(),
#'       pickCheckboxInput(
#'         "pci2", "2. Names provided as `choicesNames`",
#'         choices = choices_unnamed, selected = selected_unnamed, choicesNames = choices_names
#'       ), hr(),
#'       pickCheckboxInput(
#'         "pci3", "3. Names provided directly in choices",
#'         choices = choices_named, selected = selected_named
#'       ), hr(),
#'       pickCheckboxInput(
#'         "pci4", "4. Group as NA value to select group (without any choices)",
#'         choices = choices_named, selected = selected_named_empty
#'       ), hr(),
#'       pickCheckboxInput(
#'         "pci5", "5. Group names provided as `choicesLabels`",
#'         choices = choices_named, selected = selected_named_empty, choicesLabels = choices_labels
#'       )
#'     ),
#'     mainPanel(
#'       verbatimTextOutput("out1"),
#'       verbatimTextOutput("out2"),
#'       verbatimTextOutput("out3"),
#'       verbatimTextOutput("out4"),
#'       verbatimTextOutput("out5")
#'     ))
#'   )
#'   server <- function(input, output, session) {
#'     output$out1 <- renderPrint({print("Result 1."); input$pci1})
#'     output$out2 <- renderPrint({print("Result 2."); input$pci2})
#'     output$out3 <- renderPrint({print("Result 3."); input$pci3})
#'     output$out4 <- renderPrint({print("Result 4."); input$pci4})
#'     output$out5 <- renderPrint({print("Result 5."); input$pci5})
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @param inputId Id of `pickCheckboxInput` component.
#' @param label The component label.
#' @param choices Named list of values. Each element defines a separate checkbox group.
#'     The element name defines checkbox group id, whereas its value set of values that
#'     should be available in the related checkbox group.
#' @param choicesNames Named list of values (with the same names as `choices`).
#'     Each element value defines what labels should be displayed for each checkbox group.
#'     See \link{pickCheckboxNamesAndLabels}.
#' @param choicesLabels Named vector storing labels for each checkbox group.
#'     The parameter is also used to display values in component dropdown.
#'     See \link{pickCheckboxNamesAndLabels}.
#' @param selected The initial value or value to be updated. Subset of `choices`.
#' @param max_groups Number of maximum number of checkboxes allowed in the component.
#'     Used to limit amount of new checkbox groups added with `updatePickCheckboxInput`.
#' @param ... Extra parameters passed to \link[shinyWidgets]{pickerInput} or \link[shinyWidgets]{virtualSelectInput}
#'     in case of usage \code{pickCheckboxInput} or \code{vsCheckboxInput} respectively.
#'
#' @return Nested list of `shiny.tag` objects, defining html structure of the input,
#' or no value in case of usage of `updatePickCheckboxInput` method.
#' @export
pickCheckboxInput <- function(inputId, label, choices, choicesNames = pickCheckboxNames(choices),
                                      choicesLabels = pickCheckboxLabels(choices), selected = NULL,
                                      max_groups = length(choices), ...) {
  pickCheckboxInputTemplate(
    inputId, label, choices, choicesNames,
    choicesLabels, selected, max_groups,
    ..., method = shinyWidgets::pickerInput
  )
}

#' @rdname pickCheckboxInput
#' @export
vsCheckboxInput <- function(inputId, label, choices, choicesNames = pickCheckboxNames(choices),
                              choicesLabels = pickCheckboxLabels(choices), selected = NULL,
                              max_groups = length(choices), ...) {
  pickCheckboxInputTemplate(
    inputId, label, choices, choicesNames,
    choicesLabels, selected, max_groups,
    ..., method = shinyWidgets::virtualSelectInput
  )
}

pickCheckboxInputTemplate <- function(inputId, label, choices, choicesNames,
                              choicesLabels, selected = NULL,
                              max_groups, ..., method) {

  selected <- shiny::restoreInput(inputId, default = selected)

  htmltools::attachDependencies(
    shiny::div(
      id = inputId, class = "pick-checkbox",
      method(
        paste0(inputId, "_picker"), label,
        choices = stats::setNames(names(choices), choicesLabels),
        selected = names(selected),
        multiple = TRUE, ...
      ) %>% attachPickerAttr("data-ignore", TRUE),
      shiny::div(
        class = "options-container",
        renderCheckboxes(inputId, choices, choicesNames, choicesLabels, selected, max_groups)
      )
    ),
    htmltools::htmlDependency(
      name = "pickcheckbox",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "pickcheckbox.js",
      stylesheet = "pickcheckbox.css"
    )
  )
}


#' @param session Shiny session object.
#' @rdname pickCheckboxInput
#' @export
updatePickCheckboxInput <- function(session, inputId, choices, choicesNames, choicesLabels, selected) {
  updatePickCheckboxInputTemplate(
    session, inputId, choices, choicesNames,
    choicesLabels, selected, method = shinyWidgets::updatePickerInput
  )
}

#' @rdname pickCheckboxInput
#' @export
updateVsCheckboxInput <- function(session, inputId, choices, choicesNames, choicesLabels, selected) {
  updatePickCheckboxInputTemplate(
    session, inputId, choices, choicesNames,
    choicesLabels, selected, method = shinyWidgets::updateVirtualSelect
  )
}

updatePickCheckboxInputTemplate <- function(session, inputId, choices, choicesNames,
                                            choicesLabels, selected, method) {
  ns <- session$ns

  # todo handle cases when no parameters passed

  if (missing(choices) && !missing(choicesNames)) {
    stop("Updating choicesNames is possible only when updating choices.")
  }

  if (!missing(choices) && missing(choicesNames)) {
    choicesNames <- pickCheckboxNames(choices)
  }

  session$sendInputMessage(inputId, list(block = TRUE))

  checkbox_params <- form_checkboxes_update(choices, choicesNames, choicesLabels, selected) %>%
    purrr::transpose() %>%
    unname() %>%
    purrr::map(~ do.call(prep_input, .))

  session$sendInputMessage(inputId, list(checkboxes = checkbox_params))
  method(
    session = session, inputId = paste0(inputId, "_picker"),
    choices = if (!missing(choicesLabels)) {
      stats::setNames(names(choicesLabels), choicesLabels)
    } else {
      pickCheckboxLabels(choices)
    },
    selected = if (!missing(selected)) names(selected)
  )

  session$sendInputMessage(inputId, list(trigger = TRUE))
}
