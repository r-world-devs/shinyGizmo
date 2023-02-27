# shinyGizmo 0.4.2

* Fix handling non-existing selector case for valueButton.

# shinyGizmo 0.4.1

* `textArea` now stores its id as `data-id` attribute. This prevents automatic binding of the element by shiny library.
Even when the id is specified directly, the input value is blocked by `preventDefault` method.
* Add `ignoreIds` argument to `comminInput(s)`. The argument allows to precise which bindings should 
be ignored while merging input controllers.
* Fix handling inherited input values with valid Shiny Input Handlers. This applies to `commonInput(s)` 
and `valueButton`.

# shinyGizmo 0.4

* Convert `pickCheckboxInput` value to logical if possible.
* Fix extracting `pickCheckboxInput` selection when different than `NULL` or `NA`.
* Add `try_binding` argument to `valueButton`. When `TRUE` and `selector` points to Shiny Binding and `attribute == "value"`
it tries to convert sourced input value using registered `inputHandler`.
* Fix `pickCheckboxInput` update method for `shinyWidgets >= 0.7.0`.
* Add `vsCheckboxInput` and `updateVsCheckboxInput`. Alternative to `pickCheckboxInput` that 
uses `shinyWidgets::virtualSelectInput` instead of `shinyWidgets::pickerInput` to render dropdown. 

# shinyGizmo 0.3

* Add `jsCallOncePerFlush` function. When used prevents running `conditionalJS` callback during a single flush cycle ([3668](https://github.com/rstudio/shiny/issues/3668)).
* Add `commonInput` and `commonInputs` functions that allow to gather input from multiple controllers into one.
* Add `mergeCalls` function that allows to use more than one `jsCalls` for `conditionalJS`.
* Add `animateVisibility` JS call to show and hide elements with animation.
* Add `runAnimation` helper callback to run element animations.
* Add `once` argument to `conditionalJS` that makes jsCall run only when condition value changed.

# shinyGizmo 0.2

* Add `conditionalJS` component - extension of `shiny::conditionalPanel` that allows to run custom JS when condition is met.
* Add `valueLink` component.
* Make `showModal` and `hideModal` work with modules.

# shinyGizmo 0.1

* Add `valueButton`, `pickCheckboxInput`, `accordion`, `textArea` and `modalDialogUI` components.
