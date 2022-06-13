#' @importFrom htmltools htmlDependency
NULL

animateCSSdependency <- function(){
  htmlDependency(
    name       = "Animate.css",
    version    = "4.1.1",
    src        = "www/libs",
    stylesheet = "animate.compat.min.css",
    package    = "shinyGizmo",
    all_files  = FALSE
  )
}

animateJSdependency <- function(){
  htmlDependency(
    name      = "animateCSS",
    version   = "1.2.2",
    src       = "www/libs",
    script    = "jquery.animatecss.min.js",
    package   = "shinyGizmo",
    all_files = FALSE
  )
}

#' @title CSS effects
#' @description List of CSS effects that can be used with
#'   \code{\link{animateCSS}}.
#'
#' @return The names of the available CSS effects in a character vector.
#' @export
#'
#' @examples
#' cssEffects()
cssEffects <- function(){
  sort(c(
    "bounce",
    "flash",
    "pulse",
    "rubberBand",
    "shakeX",
    "shakeY",
    "headShake",
    "swing",
    "tada",
    "wobble",
    "jello",
    "heartBeat",
    "backInDown",
    "backInLeft",
    "backInRight",
    "backInUp",
    "backOutDown",
    "backOutLeft",
    "backOutRight",
    "backOutUp",
    "bounceIn",
    "bounceInDown",
    "bounceInLeft",
    "bounceInRight",
    "bounceInUp",
    "bounceOut",
    "bounceOutDown",
    "bounceOutLeft",
    "bounceOutRight",
    "bounceOutUp",
    "fadeIn",
    "fadeInDown",
    "fadeInDownBig",
    "fadeInLeft",
    "fadeInLeftBig",
    "fadeInRight",
    "fadeInRightBig",
    "fadeInUp",
    "fadeInUpBig",
    "fadeInTopLeft",
    "fadeInTopRight",
    "fadeInBottomLeft",
    "fadeInBottomRight",
    "fadeOut",
    "fadeOutDown",
    "fadeOutDownBig",
    "fadeOutLeft",
    "fadeOutLeftBig",
    "fadeOutRight",
    "fadeOutRightBig",
    "fadeOutUp",
    "fadeOutUpBig",
    "fadeOutTopLeft",
    "fadeOutTopRight",
    "fadeOutBottomRight",
    "fadeOutBottomLeft",
    "flip",
    "flipInX",
    "flipInY",
    "flipOutX",
    "flipOutY",
    "lightSpeedInRight",
    "lightSpeedInLeft",
    "lightSpeedOutRight",
    "lightSpeedOutLeft",
    "rotateIn",
    "rotateInDownLeft",
    "rotateInDownRight",
    "rotateInUpLeft",
    "rotateInUpRight",
    "rotateOut",
    "rotateOutDownLeft",
    "rotateOutDownRight",
    "rotateOutUpLeft",
    "rotateOutUpRight",
    "hinge",
    "jackInTheBox",
    "rollIn",
    "rollOut",
    "zoomIn",
    "zoomInDown",
    "zoomInLeft",
    "zoomInRight",
    "zoomInUp",
    "zoomOut",
    "zoomOutDown",
    "zoomOutLeft",
    "zoomOutRight",
    "zoomOutUp",
    "slideInDown",
    "slideInLeft",
    "slideInRight",
    "slideInUp",
    "slideOutDown",
    "slideOutLeft",
    "slideOutRight",
    "slideOutUp"
  ))
}


#' @title CSS animation
#' @description JavaScript code to be used in
#'   \code{\link{animatedConditionalPanel}}.
#'
#' @param effect name of a CSS effect; available effects are provided by
#'   \code{\link{cssEffects}}
#' @param delay delay in milliseconds before running the animation
#' @param duration duration of the animation in milliseconds
#' @param then a CSS animation itself produced by \code{animateCSS} to
#'   run when the previous animation has finished; \code{NULL} for no
#'   animation
#'
#' @return Some Javascript code in a character string. See
#'   \code{\link{animatedConditionalPanel}} for an example.
#' @export
animateCSS <- function(effect, delay = 0, duration = 500, then = NULL){
  effect <- match.arg(effect, cssEffects())
  js <- paste(
    "  animateCSS('%s', {",
    "    delay: %d,",
    "    duration: %d,",
    "    callback: function(){",
    "      %s",
    "    }",
    "  });",
    sep = "\n"
  )
  sprintf(
    js, effect, delay, duration,
    ifelse(is.null(then), "", paste0("$this.", then))
  )
}

animatedShow <- function(animation, fadeDuration){
  sprintf(paste(
    "var $this = $(this);",
    "$this.show(%d, function(){",
    "  $this.show().",
    animation,
    "});",
    sep = "\n"
  ), fadeDuration)
}

animatedHide <- function(animation, fadeDuration){
  paste(
    "var $this = $(this);",
    paste0("$this."),
    sub(
      "\\{\n      \n    \\}",
      sprintf("{$this.hide(%d);}", fadeDuration),
      animation
    ),
    sep = "\n"
  )
}

#' @title Animated conditional panel
#' @description Conditional panel with CSS animations on showing/hiding.
#'
#' @param ui,condition,ns arguments passed to \code{\link{conditionalJS}}
#' @param show,hide CSS effects created with \code{\link{animateCSS}}; there's
#'   no effect with the default values
#' @param fadeIn duration of fade in effect (on showing) in milliseconds
#' @param fadeOut duration of fade out effect (on hiding) in milliseconds
#'
#' @return A \code{shiny.tag.list} object, to put in a Shiny UI.
#' @export
#'
#' @importFrom htmltools tagList tags
#'
#' @examples
#' library(shiny)
#' library(shinyGizmo)
#'
#' ui <- fluidPage(
#'   sidebarPanel(
#'     actionButton("showplot", "Show/Hide")
#'   ),
#'   mainPanel(
#'     animatedConditionalPanel(
#'       plotOutput("plot"),
#'       condition = "input.showplot % 2 === 1",
#'       show = animateCSS(
#'         "bounceIn", duration = 2000, then = animateCSS("headShake")
#'       ),
#'       hide = animateCSS(
#'         "pulse", duration = 1000, then = animateCSS("tada")
#'       ),
#'       fadeIn = 0, # there's already a "in" effect (bounceIn)
#'       fadeOut = 1000
#'     )
#'   )
#' )
#'
#' server <- function(input, output){
#'   x <- rnorm(100)
#'   y <- rnorm(100)
#'   output[["plot"]] <- renderPlot({
#'     plot(x, y, pch = 19)
#'   })
#' }
#'
#' if(interactive()){
#'   shinyApp(ui, server)
#' }
animatedConditionalPanel <- function(
    ui, condition,
    show = animateCSS("fadeIn", duration = 0), # default: no show effect,
    hide = animateCSS("fadeOut", duration = 0), # default: no hide effect
    fadeIn = 0, fadeOut = 0,
    ns = shiny::NS(NULL)
){
  randomID <- paste0(
    sample(c(letters, LETTERS), 20L, replace = TRUE), collapse = ""
  )
  tagList(
    conditionalJS(
      ui = tags$div(
        id = randomID,
        ui,
        tags$style(HTML(sprintf("#%s>* {visibility: hidden;}", randomID)))
      ),
      condition = condition,
      jsCalls$custom(
        true = paste0(
          sprintf("$('#%s>*').css('visibility', 'visible'); ", randomID),
          animatedShow(
            show,
            fadeDuration = fadeIn
          )),
        false = animatedHide(
          hide,
          fadeDuration = fadeOut
        )
      )
    ),
    animateCSSdependency(),
    animateJSdependency()
  )
}
