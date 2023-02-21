//@ sourceURL=pickcheckbox.js
var pickCheckboxBinding = new Shiny.InputBinding();

var get_binding = function(el) {
  return $(el).data('shiny-input-binding');
};

$.extend(pickCheckboxBinding, {
  find: function(scope) {
    return $(scope).find(".pick-checkbox");
  },
  getType: function(el) {
    return "shinyGizmo.pickcheckbox";
  },
  getValue: function(el) {
    if (Boolean($(el).data("freeze"))) {
      return($(el).data("value"));
    }

    var picker = $(el).find('#' + $(el).attr('id') + '_picker');
    var checkboxes = $(el).find('.shiny-input-checkboxgroup');
    var picker_el = picker;
    if (picker.hasClass('virtual-select')) {
      picker_el = picker[0];
    }

    var picker_val = get_binding(picker).getValue(picker_el);
    var checkbox_vals = {};
    checkboxes.map(function() {
      var input_name = $(this).data('name');
      if (picker_val.includes(input_name)) {
        $(this).removeClass('sg_hidden');
        checkbox_vals[input_name] = get_binding($(this)).getValue(this);
      } else {
        $(this).addClass('sg_hidden');
      }
    });

    $(el).data("value", checkbox_vals);
    return(checkbox_vals);
  },
  subscribe: function(el, callback) {
    var picker = $(el).find('#' + $(el).attr('id') + '_picker');
    var checkboxes = $(el).find('.shiny-input-checkboxgroup');

    get_binding(picker).subscribe(picker, callback);
    checkboxes.each(function(index, element) {
      get_binding($(element)).subscribe($(element), callback);
    });
    $(el).on('change.pickCheckboxBinding', function(event) {
      callback();
    });
    picker.on('shiny:inputchanged', function(event) {
      event.preventDefault();
    });
    checkboxes.each(function(index, element) {
      $(element).on('shiny:inputchanged', function(event) {
        event.preventDefault();
      });
    });
  },
  receiveMessage: function(el, data) {
    if (data.hasOwnProperty("freeze")) {
      $(el).data("freeze", true);
      return;
    }
    if (data.hasOwnProperty("checkboxes")) {
      var checkboxes = $(el).find('.shiny-input-checkboxgroup');
      var update_choices = data.checkboxes[0].hasOwnProperty('options');
      var update_selected = data.checkboxes[0].hasOwnProperty('value') || data.checkboxes[0].hasOwnProperty('label');
      if (update_choices) {
        checkboxes.data("name", "");
        $.each(data.checkboxes, function(index, value) {
          var $element = $(checkboxes[index]);
          value.options = value.options.replaceAll('__tmp_id__', $element[0].id);
          $element.data("name", value.name);
          get_binding($element).receiveMessage($element[0], value);
        });
        return; // updating choices takes care of selection as well
      }
      if (update_selected) {
        $.each(data.checkboxes, function(index, value) {
          var $element = checkboxes.filter('[data-name="' + value.name + '"]');
          get_binding($element).receiveMessage($element[0], value);
        });
        return;
      }
    }

    if (data.hasOwnProperty("trigger")) {
      $(el).data("freeze", false);
      $(el).trigger('change');
    }
  },
  unsubscribe: function(el) {
    $(el).off(".pickCheckboxBinding");
  }
});

Shiny.inputBindings.register(pickCheckboxBinding, "shiny.pickCheckboxBinding");
Shiny.inputBindings.setPriority("shiny.pickCheckboxBinding", -1);
