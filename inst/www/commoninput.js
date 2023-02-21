//@ sourceURL=commoninput.js
var commonInputBinding = new Shiny.InputBinding();

var get_binding = function(el) {
  return $(el).data('shiny-input-binding');
};

var register_element = function(el) {
  var $element = $(el);
  var $common_wrapper = $element.closest('.sg_common_input');
  if (!Boolean($common_wrapper)) {
    return;
  }
  var $common_storage = $('#' + $common_wrapper.data('common_id'));
  if (!$common_storage.data('bound')) {
    return;
  }
  var $catch_ids = $common_wrapper.data('catch_ids');
  var element_binding = get_binding($element);
  var element_id = element_binding.getId(el);
  if (Boolean($catch_ids) && !$catch_ids.split(',').includes(element_id)) {
    return;
  }
  if (Boolean($element.data('ignore'))) {
    return;
  }
  var registered = $common_storage.data('registered') || [];
  if (!registered.includes(element_id)) {
    element_binding.subscribe($element, $common_storage.data('callback'));
    if ($common_wrapper.data('block')) {
      $element.on('shiny:inputchanged', function(event) {
        event.preventDefault();
      });
    }
    registered.push(element_id);
  }
};

$(document).on('shiny:bound', function(event) {
  register_element(event.target);
});

$.extend(commonInputBinding, {
  find: function(scope) {
    return $(scope).find(".sg_common_storage");
  },
  getType: function(el) {
    return "shinyGizmo.commoninput";
  },
  getValue: function(el) {
    var common_id = el.id;
    var id_selector = '[data-common_id="' + common_id + '"]';
    var inputs = $(id_selector + '.shiny-bound-input, ' + id_selector + ' .shiny-bound-input');
    var registered_inputs = $(el).data('registered') || [];

    if (registered_inputs.length === 0) {
      return;
    }
    var input_vals = {};
    inputs.map(function() {
      var input_element = this;
      var input_binding = get_binding(input_element);
      var input_name = input_binding.getId(input_element);
      if (registered_inputs.includes(input_name)) {
        input_vals[input_name] = {"value": input_binding.getValue(input_element), "type": input_binding.getType()};
      }
    });

    $(el).data("value", input_vals);
    return(input_vals);
  },
  subscribe: function(el, callback) {
    var common_id = el.id;
    $(el).data('callback', callback);
    $(el).data('registered', []);
    $(el).data('bound', true);
    var id_selector = '[data-common_id="' + common_id + '"]';
    var inputs = $(id_selector + '.shiny-bound-input, ' + id_selector + ' .shiny-bound-input');

    inputs.each(function(index, element) {
      register_element(element);
    });
    callback(true);
  },
  unsubscribe: function(el) {
    $(el).off(".commonInputBinding");
  },
  getRatePolicy: function() {
    return {
      policy: 'debounce',
      delay: 500
    };
  }
});

Shiny.inputBindings.register(commonInputBinding, "shiny.commonInputBinding");
Shiny.inputBindings.setPriority("shiny.commonInputBinding", -1);
