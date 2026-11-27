when_switch <- function(x, when) {
  if (!when) {
    x[c("true", "false")] <- x[c("false", "true")]
  }
  return(x)
}

#' JavaScript calls for conditionalJS
#'
#' The list of JavaScript calls that can be used as a `jsCall` argument of \link{conditionalJS}.
#' All the actions are reversible. E.g. when using `disable` call and conditionalJS condition is false
#' the opposite action to disable is called (removing disable attribute).
#'
#' The currently offered actions:
#' \describe{
#'   \item{attachClass}{Add provided class to the UI element.}
#'   \item{disable}{Add disable attribute to the UI element - usually results with disabling the input controller.}
#'   \item{show}{Show/hide an element with a help of `visibility:hidden` rule.
#'     Comparing to conditionalPanel (which uses display:none) results with rendering an output even if hidden.}
#'   \item{css}{Add css (inline) rule to the UI object. When condition is false, the rule is removed.}
#'   \item{animateVisibility}{Show/hide an element in an animated way.}
#'   \item{custom}{Define custom true and false callback.}
#' }
#'
#' @param class A css to be attached to (or detached from) the UI element.
#' @param important Should `!important` rule be attached to the added css?
#' @param true,false JS callback that should be executed when condition is true or false.
#'     Can be custom JS (wrapped into \link[htmlwidgets]{JS}) or one of the \link{custom-callbacks}.
#' @param when Should the (primary) action be executed when `condition` is
#'     TRUE (when = TRUE, default) or FALSE (when = FALSE).
#' @param ... Named style properties, where the name is the property name and the
#'     argument is the property value. See \link[htmltools]{css} for more details.
#' @name js_calls
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
show <- function(when = TRUE) {
  attachClass("sg_hidden", when = !when)
}

#' @rdname js_calls
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

#' Supported animation effects
#'
#' Can be used as `effectShow` and `effectHide` arguments of \link{animateVisibility},
#' or `effect` of \link{runAnimation}.
#' @export
.cssEffects <- c(
  "backInDown", "backInLeft", "backInRight", "backInUp", "backOutDown",
  "backOutLeft", "backOutRight", "backOutUp", "bounce", "bounceIn",
  "bounceInDown", "bounceInLeft", "bounceInRight", "bounceInUp",
  "bounceOut", "bounceOutDown", "bounceOutLeft", "bounceOutRight",
  "bounceOutUp", "fadeIn", "fadeInBottomLeft", "fadeInBottomRight",
  "fadeInDown", "fadeInDownBig", "fadeInLeft", "fadeInLeftBig",
  "fadeInRight", "fadeInRightBig", "fadeInTopLeft", "fadeInTopRight",
  "fadeInUp", "fadeInUpBig", "fadeOut", "fadeOutBottomLeft", "fadeOutBottomRight",
  "fadeOutDown", "fadeOutDownBig", "fadeOutLeft", "fadeOutLeftBig",
  "fadeOutRight", "fadeOutRightBig", "fadeOutTopLeft", "fadeOutTopRight",
  "fadeOutUp", "fadeOutUpBig", "flash", "flip", "flipInX", "flipInY",
  "flipOutX", "flipOutY", "headShake", "heartBeat", "hinge", "jackInTheBox",
  "jello", "lightSpeedInLeft", "lightSpeedInRight", "lightSpeedOutLeft",
  "lightSpeedOutRight", "pulse", "rollIn", "rollOut", "rotateIn",
  "rotateInDownLeft", "rotateInDownRight", "rotateInUpLeft", "rotateInUpRight",
  "rotateOut", "rotateOutDownLeft", "rotateOutDownRight", "rotateOutUpLeft",
  "rotateOutUpRight", "rubberBand", "shakeX", "shakeY", "slideInDown",
  "slideInLeft", "slideInRight", "slideInUp", "slideOutDown", "slideOutLeft",
  "slideOutRight", "slideOutUp", "swing", "tada", "wobble", "zoomIn",
  "zoomInDown", "zoomInLeft", "zoomInRight", "zoomInUp", "zoomOut",
  "zoomOutDown", "zoomOutLeft", "zoomOutRight", "zoomOutUp"
)

json_val <- function(value) {
  if (inherits(value, c("AsIs", "numeric", "integer"))) {
    return(value)
  }
  return(glue::glue("'{value}'"))
}

json_settings <- function(...) {
  args <- list(...)
  json_args <- purrr::imap(args, ~ glue::glue("\"{.y}\": {json_val(.x)}"))
  glue::glue("{<paste(json_args, collapse = ', ')>}", .open = "<", .close = ">")
}

#' @param effectShow,effectHide Animation effects used for showing and hiding element.
#'     Check \link{.cssEffects} object for possible options.
#' @param delay Delay of animation start (in milliseconds).
#' @param duration Duration of animation (in milliseconds).
#' @param ignoreInit Should the animation be skipped when application is in initial state?
#' @rdname js_calls
animateVisibility <- function(effectShow = "fadeIn", effectHide = "fadeOut", delay = 0, duration = 500,
                              ignoreInit = TRUE, when = TRUE) {
  effectShow <- match.arg(effectShow, .cssEffects)
  effectHide <- match.arg(effectHide, .cssEffects)
  settings_show <- json_settings(
    delay = delay,
    duration = duration
  )
  settings_hide <- json_settings(
    delay = delay,
    duration = duration,
    callback = I("function() {$(this).addClass('sg_hidden');}")
  )
  ignore_init <- if (ignoreInit) "true" else "false"
  rules <- when_switch(
    list(
      true = htmlwidgets::JS(glue::glue(
        "var $element = $(this);",
        "if ({ignore_init} && !$element.data('data-call-initialized')) {{",
        "$element.removeClass('sg_hidden');",
        "}} else {{",
        "setTimeout(function() {{$element.removeClass('sg_hidden');}}, {delay});",
        "$element.animateCSS('{effectShow}', {settings_show});",
        "}};"
      )),
      false = htmlwidgets::JS(glue::glue(
        "var $element = $(this);",
        "if ({ignore_init} && !$element.data('data-call-initialized')) {{$element.addClass('sg_hidden');}};",
        "$(this).animateCSS('{effectHide}', {settings_hide});"
      ))
    ),
    when = when
  )
  class(rules$true) <- c(class(rules$true), "animate_call")
  class(rules$false) <- c(class(rules$false), "animate_call")
  return(rules)
}

#' Define an animation
#'
#' Creates an `animation` object for usage in \link{runAnimation}.
#'
#' @param effect Animation effect used name to be applied.
#'     Check \link{.cssEffects} object for possible options.
#' @param delay Delay of animation start (in milliseconds).
#' @param duration Duration of animation (in milliseconds).
#'
#' @return A named list with class `animation`.
#' @export
animation <- function(effect, delay = 0, duration = 1000) {
  out <- list(
    "effect"   = match.arg(effect, .cssEffects),
    "delay"    = delay,
    "duration" = duration
  )
  class(out) <- "animation"
  out
}

animationRule <- function(anim, callbackBody) {
  settings <- json_settings(
    delay    = anim$delay,
    duration = anim$duration,
    callback = I(glue::glue("function() {<callbackBody>}", .open = "<", .close = ">"))
  )
  htmlwidgets::JS(glue::glue(
    "$(this).animateCSS('{anim$effect}', {settings});"
  ))
}

chainTwoAnimations <- function(anim, rule){
  animationRule(anim, callbackBody = rule)
}

chainAnimations <- function(...){
  anims <- list(...)
  nanims <- length(anims)
  lastanim <- anims[[nanims]]
  init <- animationRule(lastanim, callbackBody = "")
  if(nanims == 1L){
    return(init)
  }
  Reduce(chainTwoAnimations, anims[-nanims], init, right = TRUE)
}

#' Helpful methods for custom callback setup
#'
#' Can be used as a `true` or `false` argument for custom method of \link{js_calls}.
#'
#' @name custom-callbacks
#' @param ... Animation object(s) created with \link{animation}; if multiple
#'   animation objects are given then the animations will be chained.
#' @param ignoreInit Should the animation be skipped when application is in initial state?
#'
#' @examples
#' library(shiny)
#' library(shinyGizmo)
#' ui <- fluidPage(
#'     actionButton("value", "Click me", class = "btn-primary"),
#'     br(), br(),
#'     conditionalJS(
#'         tags$h1("Hello", style = "display: none;"),
#'         "input.value % 2 === 1",
#'         jsCalls$custom(
#'             true = runAnimation(animation("jello"), animation("swing")),
#'             false = runAnimation(animation("slideOutRight"))
#'         )
#'     )
#' )
#' server <- function(input, output, session) {}
#' if(interactive()) {
#'   shinyApp(ui, server)
#' }
#'
#' @export
runAnimation <- function(..., ignoreInit = TRUE) {
  check <- all(vapply(list(...), function(x) {
    inherits(x, "animation")
  }, logical(1L)))
  if(!check) {
    stop(
      "Arguments given in `...` must be some objects created with ",
      "the `animation` function."
    )
  }
  ignore_init <- if (ignoreInit) "true" else "false"
  chain <- chainAnimations(...)
  rule <- htmlwidgets::JS(glue::glue(
    "var $element = $(this);",
    "if (!{ignore_init} || $element.data('data-call-initialized')) {{",
    "{chain};",
    "}}"
  ))
  class(rule) <- c(class(rule), "animate_call")
  return(rule)
}

#' @rdname js_calls
custom <- function(true = NULL, false = NULL) {
  list(
    true = true,
    false = false
  )
}

inherit_class <- function(list_obj, class, modifier = function(x) x) {
  nested_classes <- purrr::map(list_obj, ~class(.x)) %>% unlist()
  list_obj <- modifier(list_obj)
  if (class %in% nested_classes) {
    class(list_obj) <- c(class(list_obj), class)
  }
  return(list_obj)
}

#' List of JavaScript calls for `conditionalJS`
#'
#' @description
#' Each `jsCalls` function can be used as a `jsCall` argument of \link{conditionalJS}.
#' See \link{js_calls} for possible options.
#'
#' You can apply multiple calls with using `mergeCalls`.
#'
#' @examples
#' conditionalJS(
#'   shiny::tags$button("Hello"),
#'   "input.value > 0",
#'   jsCalls$show()
#' )
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     tags$head(
#'       tags$script(
#'         "var update_attr = function(message) {",
#'         "$('#' + message.id).attr(message.attribute, message.value);",
#'         "}",
#'         "Shiny.addCustomMessageHandler('update_attr', update_attr);"
#'       )
#'     ),
#'     sidebarLayout(
#'       sidebarPanel(
#'         selectInput("effect", "Animation type", choices = .cssEffects)
#'       ),
#'       mainPanel(
#'         conditionalJS(
#'           ui = plotOutput("cars"),
#'           condition = "input.effect != ''",
#'           jsCall = jsCalls$custom(true = runAnimation(effect = "bounce")),
#'           once = FALSE
#'         )
#'       )
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$cars <- renderPlot({
#'       plot(mtcars$mpg, mtcars$qsec)
#'     })
#'     observeEvent(input$effect, {
#'       session$sendCustomMessage(
#'         "update_attr",
#'         list(id = "cars", attribute = "data-call-if-true", value = runAnimation(input$effect))
#'       )
#'     })
#'   }
#'
#'
#'   shinyApp(ui, server)
#' }
#'
#' @export
jsCalls <- list(
  attachClass = attachClass,
  disable = disable,
  show = show,
  css = css,
  animateVisibility = animateVisibility,
  custom = custom
)

null_to_empty <- function(val) {
  if (is.null(val)) {
    return("")
  }
  return(val)
}

#' @rdname jsCalls
#' @param ... jsCalls to be merged.
#' @export
mergeCalls <- function(...) {
  args <- rlang::dots_list(...)

  to_single_js <- function(x) {
    htmlwidgets::JS(paste(unlist(x), collapse = ";"))
  }
  merged_calls <- list(
    true = purrr::map(args, "true") %>% inherit_class("animate_call", to_single_js),
    false = purrr::map(args, "false") %>% inherit_class("animate_call", to_single_js)
  )
}

#' @rdname conditionalJS
#' @param session Shiny session object.
#' @export
jsCallOncePerFlush <- function(session) {
  shiny::onFlushed(function() {
    session$sendCustomMessage("count_flush", list())
  }, once = FALSE)
}

#' Run JS when condition is met
#'
#'
#' @description
#' `conditionalJS` is an extended version of \link[shiny]{conditionalPanel}.
#' The function allows to run selected or custom JS action when the provided
#' condition is true or false.
#'
#' To see the possible JS actions check \link{jsCalls}.
#'
#' Optionally call `jsCallOncePerFlush` in server to assure the call is run once
#' per application flush cycle (see. https://github.com/rstudio/shiny/issues/3668).
#' This prevents i.e. running animation multiple times when
#' `runAnimation(once = FALSE)` is used.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     tags$style(".boldme {font-weight: bold;}"),
#'     sliderInput("value", "Value", min = 1, max = 10, value = 1),
#'     textOutput("slid_val"),
#'     conditionalJS(
#'       tags$button("Show me when slider value at least 3"),
#'       "input.value >= 3",
#'       jsCalls$show()
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("Show me when value less than 3"),
#'       "input.value >= 3",
#'       jsCalls$show(when = FALSE)
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled when value at least 4"),
#'       "input.value >= 4",
#'       jsCalls$disable()
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled when value less than 4"),
#'       "input.value >= 4",
#'       jsCalls$disable(when = FALSE)
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I have class 'boldme' when value at least 5"),
#'       "input.value >= 5",
#'       jsCalls$attachClass("boldme")
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I change color when value at least 6"),
#'       "input.value >= 6",
#'       jsCalls$custom(
#'         true = "$(this).css('background-color', 'red');",
#'         false = "$(this).css('background-color', 'green');"
#'       )
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I change border when value at least 7"),
#'       "input.value >= 7",
#'       jsCalls$css(
#'         border = "dashed"
#'       )
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm disabled permanently when value at least 8"),
#'       "input.value >= 8",
#'       jsCalls$disable()["true"] # remove false condition
#'     ),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I bounce when value at least 9"),
#'       "input.value >= 9",
#'       jsCalls$custom(true = runAnimation()),
#'       once = FALSE
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$slid_val <- renderText({
#'       input$value
#'     })
#'     jsCallOncePerFlush(session)
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' if (interactive()) {
#'   library(shiny)
#'   library(shinyGizmo)
#'
#'   # Multiple rules attached to a single element
#'   ui <- fluidPage(
#'     tags$style(".boldme {font-weight: bold;}"),
#'     sliderInput("value", "Value", min = 1, max = 10, value = 1),
#'     checkboxInput("lock", "Lock button"),
#'     tags$button("I'm bold when value at least 5, disabled when locked") |>
#'       conditionalJS("input.value >= 5", jsCalls$attachClass("boldme")) |>
#'       conditionalJS("input.lock", jsCalls$disable()),
#'     hr(),
#'     conditionalJS(
#'       tags$button("I'm visible when value at least 3, red when at least 7"),
#'       condition = c("input.value >= 3", "input.value >= 7"),
#'       jsCall = list(jsCalls$show(), jsCalls$css(color = "red"))
#'     )
#'   )
#'
#'   server <- function(input, output, session) {}
#'
#'   shinyApp(ui, server)
#' }
#'
#' if (interactive()) {
#'   library(shiny)
#'   library(shinyGizmo)
#'
#'   ui <- fluidPage(
#'     textInput("name", "Name"),
#'     conditionalJS(
#'       actionButton("value", "Type name to enable the button"),
#'       "input.name != ''",
#'       jsCalls$disable(when = FALSE)
#'     )
#'   )
#'
#'   server <- function(input, output, session) {}
#'
#'   shinyApp(ui, server)
#' }
#'
#' @param ui A `shiny.tag` element to which the JS callback should be attached.
#'    It can be an element already wrapped with `conditionalJS` - the new rules are added
#'    to the existing ones.
#' @param condition A JavaScript expression that will be evaluated repeatedly.
#'    When the evaluated `condition` is true, `jsCall`'s true (`jsCall$true`) callback is run,
#'    when false -  `jsCall$false` is executed in application browser.
#'    Pass a character vector to define multiple rules at once (each paired with
#'    the corresponding `jsCall` element).
#' @param jsCall A list of two `htmltools::JS` elements named 'true' and 'false'
#'    storing JS expressions.
#'    The 'true' object is evaluated when `condition` is true, 'false' otherwise.
#'    In order to skip true/false callback assign it to NULL (or skip).
#'    Use `this` object in the expressions to refer to the `ui` object.
#'    See \link{jsCalls} for possible actions.
#'    When multiple conditions are provided, pass a list of such calls.
#' @param once Should the JS action be called only when condition state changes?
#'    Can be a vector when multiple conditions are provided.
#' @param ns The \link[shiny]{NS} object of the current module, if any.
#'
#' @details
#' Multiple rules can be attached to a single element either by passing vectors to
#' `condition`, `jsCall` (and optionally `once`) or by applying `conditionalJS` multiple
#' times (e.g. with pipe). The rules are evaluated in definition order, so when
#' multiple rules modify the same property, the last one wins.
#'
#' @export
conditionalJS <- function(ui, condition, jsCall, once = TRUE, ns = shiny::NS(NULL)) {
  if (!inherits(ui, "shiny.tag")) {
    stop(glue::glue("{sQuote('ui')} argument should be a shiny.tag object."))
  }
  if (is_js_call(jsCall)) {
    jsCall <- list(jsCall)
  }
  n_rules <- max(length(condition), length(jsCall), length(once))
  lengths <- c(condition = length(condition), jsCall = length(jsCall), once = length(once))
  if (any(!lengths %in% c(1, n_rules))) {
    stop(glue::glue(
      "{sQuote('condition')}, {sQuote('jsCall')} and {sQuote('once')} should be of length 1 or the same length."
    ))
  }

  new_rules <- purrr::pmap(
    list(
      condition = rep_len(as.list(condition), n_rules),
      jsCall = rep_len(jsCall, n_rules),
      once = rep_len(as.list(once), n_rules)
    ),
    function(condition, jsCall, once) {
      list(
        condition = condition,
        true = jsCall[["true"]],
        false = jsCall[["false"]],
        once = once,
        ns = ns("")
      )
    }
  )
  rules <- c(get_call_rules(ui), new_rules)

  html_deps <- list(
    htmltools::htmlDependency(
      name = "conditionaljs",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "conditionaljs.js",
      stylesheet = "conditionaljs.css"
    )
  )
  is_animated <- purrr::some(jsCall, ~ inherits(.x$true, "animate_call") || inherits(.x$false, "animate_call"))
  if (is_animated) {
    html_deps[[2]] <- htmltools::htmlDependency(
      name = "animatecss",
      version = utils::packageVersion("shinyGizmo"),
      package = "shinyGizmo",
      src = "www",
      script = "libs/jquery.animatecss.min.js",
      stylesheet = "libs/animate.compat.min.css"
    )
  }

  htmltools::attachDependencies(
    set_call_rules(ui, rules),
    html_deps,
    append = TRUE
  )
}

is_js_call <- function(x) {
  is.null(x) || length(x) == 0 || (!is.null(names(x)) && all(names(x) %in% c("true", "false")))
}

call_attributes <- c(
  "data-call-if", "data-call-if-true", "data-call-if-false", "data-call-once", "data-ns-prefix", "data-call-rules"
)

# Rules already attached to the element with previous `conditionalJS` calls
get_call_rules <- function(ui) {
  rules_json <- htmltools::tagGetAttribute(ui, "data-call-rules")
  if (!is.null(rules_json)) {
    rules <- jsonlite::fromJSON(rules_json, simplifyVector = FALSE)
    return(purrr::map(rules, function(rule) {
      rule[c("true", "false")] <- purrr::map(rule[c("true", "false")], ~ if (!is.null(.x)) htmlwidgets::JS(.x))
      rule
    }))
  }
  condition <- htmltools::tagGetAttribute(ui, "data-call-if")
  if (is.null(condition)) {
    return(list())
  }
  true <- htmltools::tagGetAttribute(ui, "data-call-if-true")
  false <- htmltools::tagGetAttribute(ui, "data-call-if-false")
  ns_prefix <- htmltools::tagGetAttribute(ui, "data-ns-prefix")
  list(list(
    condition = condition,
    true = if (!is.null(true)) htmlwidgets::JS(true),
    false = if (!is.null(false)) htmlwidgets::JS(false),
    once = !is.null(htmltools::tagGetAttribute(ui, "data-call-once")),
    ns = if (is.null(ns_prefix)) "" else ns_prefix
  ))
}

# Single rule is stored in separate attributes (allowing to modify them directly),
# multiple rules as JSON array.
set_call_rules <- function(ui, rules) {
  ui$attribs <- ui$attribs[!names(ui$attribs) %in% call_attributes]
  if (length(rules) == 1) {
    rule <- rules[[1]]
    return(htmltools::tagAppendAttributes(
      ui,
      `data-call-if` = rule$condition,
      `data-call-if-true` = rule$true,
      `data-call-if-false` = rule$false,
      `data-call-once` = if (isTRUE(rule$once)) "true" else NULL,
      `data-ns-prefix` = rule$ns
    ))
  }
  rules_json <- rules %>%
    purrr::map(function(rule) {
      rule[c("true", "false")] <- purrr::map(rule[c("true", "false")], ~ if (!is.null(.x)) as.character(.x))
      purrr::compact(rule)
    }) %>%
    jsonlite::toJSON(auto_unbox = TRUE)
  htmltools::tagAppendAttributes(ui, `data-call-rules` = as.character(rules_json))
}
