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
#' \itemize{
#'   \item{attachClass}{ Add provided class to the UI element.}
#'   \item{disable}{ Add disable attribute to the UI element - usually results with disabling the input controller.}
#'   \item{show}{ Show/hide an element with a help of `visibility:hidden` rule.
#'     Comparing to conditionalPanel (which uses display:none) results with rendering an output even if hidden.}
#'   \item{css}{ Add css (inline) rule to the UI object. When condition is false, the rule is removed.}
#'   \item{animateVisibility}{ Show/hide an element in an animated way.}
#'   \item{custom}{ Define custom true and false callback.}
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
  glue::glue("{{{paste(json_args, collapse = ', ')}}}")
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

animationRule <- function(anim, callbackBody){
  settings <- json_settings(
    delay    = anim$delay,
    duration = anim$duration,
    callback = I(glue::glue("function() {{{callbackBody}}}"))
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
#' @param condition A JavaScript expression that will be evaluated repeatedly.
#'    When the evaluated `condition` is true, `jsCall`'s true (`jsCall$true`) callback is run,
#'    when false -  `jsCall$false` is executed in application browser.
#' @param jsCall A list of two `htmltools::JS` elements named 'true' and 'false'
#'    storing JS expressions.
#'    The 'true' object is evaluated when `condition` is true, 'false' otherwise.
#'    In order to skip true/false callback assign it to NULL (or skip).
#'    Use `this` object in the expressions to refer to the `ui` object.
#'    See \link{jsCalls} for possible actions.
#' @param once Should the JS action be called only when condition state changes?
#' @param ns The \link[shiny]{NS} object of the current module, if any.
#'
#' @export
conditionalJS <- function(ui, condition, jsCall, once = TRUE, ns = shiny::NS(NULL)) {
  if (!inherits(ui, "shiny.tag")) {
    stop(glue::glue("{sQuote('ui')} argument should be a shiny.tag object."))
  }
  shiny::tagList(
    shiny::singleton(
      shiny::tags$head(
        shiny::tags$script(type = "text/javascript", src = "shinyGizmo/conditionaljs.js"),
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "shinyGizmo/conditionaljs.css")
      )
    ),
    if (inherits(jsCall$true, "animate_call") || inherits(jsCall$false, "animate_call")) {
      shiny::singleton(
        shiny::tags$head(
          shiny::tags$script(type = "text/javascript", src = "shinyGizmo/libs/jquery.animatecss.min.js"),
          shiny::tags$link(rel = "stylesheet", type = "text/css", href = "shinyGizmo/libs/animate.compat.min.css")
        )
      )
    }    ,
    htmltools::tagAppendAttributes(
      ui,
      `data-call-if` = condition,
      `data-call-if-true` = jsCall[["true"]],
      `data-call-if-false` = jsCall[["false"]],
      `data-call-once` = if (once) "true" else NULL,
      `data-ns-prefix` = ns("")
    )
  )
}
