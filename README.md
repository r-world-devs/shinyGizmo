
# shinyGizmo

[![version](https://img.shields.io/static/v1.svg?label=github.com&message=v.0.1&color=ff69b4)](https://img.shields.io/static/v1.svg?label=github.com&message=v.0.1&color=ff69b4)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-success.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

## Overview

shinyGizmo is an R package providing useful components for Shiny
applications.

<center>

## <span style="color:blue"> shinyGizmo 0.1 is now available!</span>

</center>

## Installation

From CRAN:

    install.packages("shinyGizmo")

Lastest development version from Github:

    remotes::install_github(
      "r-world-devs/shinyGizmo"
    )

## Available components

### pickCheckboxInput - make selection in many groups at once

![](./man/figures/pickcheckbox.gif)

### accordion - light and simple version of accordion

![](./man/figures/accordion.gif) ![](./man/figures/accordion_enroll.gif)

### modalDialogUI - create modals directly in UI

![](./man/figures/modalui.gif)

### valueButton - get any attribute from Shiny application DOM objects

![](./man/figures/valuebutton.gif)

### textArea - Non-binding version of `shiny::textAreaInput`.

![](./man/figures/textarea.gif)

Improves application performance when large amount text is passed to
text area. Works great with `valueButton`.

## Lifecycle

shinyGizmo 0.1 is stable but we’re still developing the package. If you
find bugs or have any suggestions for future releases post an issue on
GitHub page at <https://github.com/r-world-devs/shinyGizmo/issues>.

## Getting help

There are two main ways to get help with `shinyGizmo`

1.  Reach the package author via email: <krystian8207@gmail.com>.
2.  Post an issue on our GitHub page at
    [https://github.com/r-world-devs/shinyGizmo](https://github.com/r-world-devs/shinyGizmo/issues).
