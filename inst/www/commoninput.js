//@ sourceURL=commoninput.js
var commonInputBinding = new Shiny.InputBinding();

var get_binding = function(el) {
  return $(el).data('shiny-input-binding');
};

$.extend(commonInputBinding, {
  find: function(scope) {
    return $(scope).find(".sg_common_storage");
  },
  getType: function(el) {
    return "shinyGizmo.commoninput";
  },
  getValue: function(el) {
    var common_id = el.id;
    var inputs = $('[data-common_id="' + common_id + '"]')
      .find('.shiny-bound-input');

    var input_vals = {};
    inputs.map(function() {
      var input_element = this;
      var input_binding = get_binding(input_element);
      var input_name = input_binding.getId(input_element);
      input_vals[input_name] = input_binding.getValue(input_element);
    });

    $(el).data("value", input_vals);
    return(input_vals);
  },
  subscribe: function(el, callback) {
    debugger;
    var common_id = el.id;
    var inputs = $('[data-common_id="' + common_id + '"]')
      .find('.shiny-bound-input');

    inputs.each(function(index, element) {
      var $element = $(element);
      get_binding($element).subscribe($element, callback);
      var $common_wrapper = $element.closest('.sg_common_input');
      if ($common_wrapper.data('block')) {
        $element.on('shiny:inputchanged', function(event) {
          event.preventDefault();
        });
      }
    });
  },
  unsubscribe: function(el) {
    $(el).off(".commonInputBinding");
  }
});

Shiny.inputBindings.register(commonInputBinding, "shiny.commonInputBinding");
Shiny.inputBindings.setPriority("shiny.commonInputBinding", -1);
