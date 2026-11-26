# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

shinyGizmo is a CRAN R package providing custom UI components and input widgets for Shiny. Each component is an R constructor in `R/` paired with JavaScript (and sometimes CSS) in `inst/www/`.

## Commands

The project uses `renv` (activated by `.Rprofile`; `shinyGizmo` itself is in renv's ignored packages).

Prefer the low-level packages over `devtools` wrappers:

```r
pkgload::load_all()                         # load package for interactive work
roxygen2::roxygenize()                      # regenerate man/*.Rd and NAMESPACE from roxygen (never edit those by hand)
rcmdcheck::rcmdcheck(args = "--as-cran")    # R CMD check as used for CRAN releases (see cran-comments.md)
rmarkdown::render("README.Rmd")             # README.md is generated from README.Rmd — edit the .Rmd; it calls library(shinyGizmo), so install the current version first
pkgdown::build_site()                       # site in docs/ (published to r-world-devs.github.io/shinyGizmo)
shiny::runApp("examples/valuebutton.R")     # manual demo apps, one per component
```

```bash
Rscript run_tests.R [filter ...]            # UI tests (shinytest2) with screenshot tests enabled, e.g. `Rscript run_tests.R ui-valuebutton`
```

UI tests live in `tests/testthat/test-ui-*.R` and drive apps from `tests/testthat/apps/<component>/app.R` via `shinytest2::AppDriver` (needs Chrome). The apps call `library(shinyGizmo)` in a separate process, so run `R CMD INSTALL .` before testing JS/R changes. Server-side values are checked through `exportTestValues()` (`app$get_value(export = ...)`), e.g. to assert classes produced by input handlers. Screenshot tests run only with `SCREENSHOT_TESTS=1` (set by `run_tests.R`); `tests/testthat/setup.R` stops testthat from deleting their snapshots otherwise. UI tests are skipped on CRAN and CI.

There is no CI. Components without tests are verified manually with the apps in `examples/` (or the `@examples` blocks in roxygen docs, which are wrapped in `if (interactive())`).

## Architecture

### R ↔ JS pairing

Every component attaches its own JS via `htmltools::htmlDependency(package = "shinyGizmo", src = "www", ...)` with `version = utils::packageVersion("shinyGizmo")`, so the browser re-fetches assets on version bump. Exceptions:
- `uiModal.R` loads `modal.js` through a `shiny::singleton` `<script src="shinyGizmo/modal.js">`, relying on the `shinyGizmo` resource path registered in `.onLoad`.
- `container()` builds its CSS at render time and injects it via an `htmlDependency(head = <style>)` named `container-<name>` (no static file).
- `conditionalJS()` adds a second dependency (`inst/www/libs/` animate.css + jQuery plugin) only when a `jsCall` inherits `animate_call`.

Configuration is passed from R to JS through `data-*` attributes on the generated tags (e.g. `data-call-if`, `data-common_id`, `data-selector`, `data-try_binding`), which the JS reads with jQuery `.data()`.

Server-side update functions (`updateTextArea`, `showModalUI`/`hideModalUI`, accordion collapse/enroll) use `session$sendCustomMessage(<name>, ...)` with a matching `Shiny.addCustomMessageHandler` in the corresponding JS file. Namespaced IDs must go through `session$ns()` on the R side.

### Custom input bindings and input handlers

`pickCheckboxInput`, `commonInput(s)` and `valueButton`/`valueLink` are Shiny input bindings (`Shiny.inputBindings.register`). Their `getType()` returns `shinyGizmo.<name>`, and the matching R deserializers are registered with `shiny::registerInputHandler(..., force = TRUE)` in `.onLoad` in `R/shinyGizmo-package.R`.

`commonInput` and `valueButton` (with `try_binding = TRUE`) wrap values from *other* Shiny inputs. The JS sends the wrapped input's value plus its binding type, and the R handler re-dispatches it via the internal `shiny:::applyInputHandler` (accessed through the package's `%:::%` helper) using a `"<id>:<type>"` name so the original input's handler still applies.

`commonInput` mechanics (`inst/www/commoninput.js`): grouped controllers are tagged `.sg_common_input` with `data-common_id`; a hidden singleton `div.sg_common_storage` with the common id is the actual bound input. It subscribes to each child's binding on `shiny:bound`, and with `block = TRUE` calls `preventDefault` on the child's `shiny:inputchanged` so only the merged value reaches the server.

## Conventions

- Tidyverse-style R; `purrr` and the magrittr pipe `%>%` (imported in `shinyGizmo-package.R`) are used throughout; error messages use `glue`.
- Add user-facing changes to `NEWS.md` under the current version heading, and bump `Version` in `DESCRIPTION`.
- Keep `.Rbuildignore` updated for non-package files (e.g. `examples/`, `docs/`, `.claude/`).
