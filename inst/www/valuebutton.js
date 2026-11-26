//@ sourceURL=valuebutton.js
var valueButtonBinding = new Shiny.InputBinding();

// Based on https://stackoverflow.com/a/6491621
byString = function(o, s) {
    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    var a = s.split('.');
    for (var i = 0, n = a.length; i < n; ++i) {
        var k = a[i];
        if (k in o) {
            o = o[k];
        } else {
            return;
        }
    }
    return o;
};

$.extend(valueButtonBinding, {
  find: function(scope) {
    return $(scope).find(".value-button");
  },
  getValue: function(el) {
    var $target;
    var attribute = $(el).data("value-attribute");
    var selector = $(el).data("selector");
    if (selector == "window") {
      $target = window;
    } else if (selector == "document") {
      $target = document;
    } else if (selector == "this") {
      $target = el;
    } else {
      $target = $(selector)[0];
    }
    if (!$target) {
      return;
    }
    var try_binding = $(el).data("try_binding") == "TRUE";
    // Skip binding when sourcing from the button itself to avoid recursive getValue call
    var is_bound = $target !== el && $($target).hasClass('shiny-bound-input');
    if (try_binding && is_bound && attribute == "value") {
      var binding = $($target).data('shiny-input-binding');
      var input_type = binding.getType($target);
      var input_name = binding.getId($target);
      var input_key = input_type ? input_name + ":" + input_type : input_name;
      var input_val = {};
      input_val[input_key] = binding.getValue($target);
      return input_val;
    }

    var value = byString($target, attribute);
    if (try_binding) {
      return {"value": value};
    }
    return value;
  },
  getType: function(el) {
    if ($(el).data("try_binding") == "TRUE") {
      return "shinyGizmo.valuebutton.binding";
    }
    return "shinyGizmo.valuebutton";
  },
  subscribe: function(el, callback) {
    $(el).on('click.valueButtonBinding', function(event){
      callback();
    });
  },
  unsubscribe: function(el) {
    $(el).off(".value-button");
  }
});

Shiny.inputBindings.register(valueButtonBinding, 'shiny.valueButtonBinding');
Shiny.inputBindings.setPriority("shiny.valueButtonBinding", -1);
