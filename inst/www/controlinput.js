//@ sourceURL=controlinput.js
(function() {
  var CONTROL_TYPE = "shinyGizmo.controlinput";
  // Elements updated with `update*` method since the last user interaction
  var updated_by_program = new Set();

  var get_wrapper = function(el) {
    if (!el || !el.nodeType) {
      return $();
    }
    return $(el).closest('.sg_control_input');
  };

  var get_trigger = function(el) {
    if (!$(el).hasClass('shiny-bound-input')) {
      return "init";
    }
    return updated_by_program.has(el) ? "program" : "user";
  };

  // Wrap binding methods so that elements placed in controlInput are sent with custom type.
  // Elements outside controlInput are handled by the original methods.
  var patch_binding = function(binding) {
    if (!binding || binding._sg_control_patched) {
      return;
    }
    binding._sg_control_patched = true;
    var getType = binding.getType;
    var getValue = binding.getValue;

    binding.getType = function(el) {
      if (get_wrapper(el).length) {
        return CONTROL_TYPE;
      }
      return getType.apply(this, arguments);
    };

    binding.getValue = function(el) {
      var value = getValue.apply(this, arguments);
      var $wrapper = get_wrapper(el);
      if (!$wrapper.length) {
        return value;
      }
      var input_type = getType.call(this, el);
      var input_name = this.getId(el);
      var input_key = input_type ? input_name + ":" + input_type : input_name;
      var input_val = {};
      input_val[input_key] = value;

      // Trigger is computed at change time (before rate policy is applied)
      var trigger = get_trigger(el);
      var attributes = $.extend({}, $wrapper.data('control_attributes') || {});
      if ($wrapper.data('control_trigger')) {
        attributes.trigger = trigger;
      }
      return {"value": input_val, "attributes": attributes, "trigger": trigger};
    };
  };

  Shiny.inputBindings.getBindings().forEach(function(item) {
    patch_binding(item.binding);
  });
  var register = Shiny.inputBindings.register;
  Shiny.inputBindings.register = function(binding) {
    patch_binding(binding);
    return register.apply(this, arguments);
  };

  $(document).on('shiny:updateinput', function(event) {
    if (get_wrapper(event.target).length) {
      updated_by_program.add(event.target);
    }
  });

  // Any change following user interaction is treated as made by the user
  ['keydown', 'pointerdown', 'mousedown', 'touchstart'].forEach(function(event_name) {
    document.addEventListener(event_name, function(event) {
      if (event.isTrusted) {
        updated_by_program.clear();
      }
    }, true);
  });

  $(document).on('shiny:inputchanged', function(event) {
    if (event.inputType !== CONTROL_TYPE) {
      return;
    }
    var block = get_wrapper(event.el).data('control_block');
    if (!block || !event.value) {
      return;
    }
    if (String(block).split(',').includes(event.value.trigger)) {
      event.preventDefault();
    }
  });
})();
