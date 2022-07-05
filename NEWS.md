# shinyGizmo 0.2.3

* Add `commonInput` and `commonInputs` functions that allow to gather input from multiple controllers into one.
* Add `mergeCalls` function that allows to use more than one `jsCalls` for `conditionalJS`.

# shinyGizmo 0.2.2

* Add `animateVisibility` JS call to show and hide elements with animation.
* Add `runAnimation` helper callback to run element animations.

# shinyGizmo 0.2.1

* Add `once` argument to `conditionalJS` that makes jsCall run only when condition value changed.

# shinyGizmo 0.2

* Add `conditionalJS` component - extension of `shiny::conditionalPanel` that allows to run custom JS when condition is met.
* Add `valueLink` component.
* Make `showModal` and `hideModal` work with modules.

# shinyGizmo 0.1

* Add `valueButton`, `pickCheckboxInput`, `accordion`, `textArea` and `modalDialogUI` components.
