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
    if (selector != "window" & selector != "document") {
      $target =  $(selector)[0];
    }
    if (selector == "window") {
      $target = window;
    }
    if (selector == "document") {
      $target = document;
    }
    var value = byString($target, attribute);
    return value;
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
