//@ sourceURL=conditionaljs.js
// https://github.com/rstudio/shiny/blob/a8c14dab9623c984a66fcd4824d8d448afb151e7/srcts/src/utils/index.ts#L146
function scopeExprToFunc(expr) {
  var exprEscaped = expr
    .replace(/[\\"']/g, "\\$&")
    .replace(/\u0000/g, "\\0")
    .replace(/\n/g, "\\n")
    .replace(/\r/g, "\\r")
    .replace(/[\b]/g, "\\b");
  var func;
  try {
    func = new Function("with (this) {\n        try {\n          return (".concat(expr, ");\n        } catch (e) {\n          console.error('Error evaluating expression: ").concat(exprEscaped, "');\n          throw e;\n        }\n      }"));
  } catch (e) {
    console.error("Error parsing expression: " + expr);
    throw e;
  }
  return function(scope) {
    return func.call(scope);
  };
}

function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true });
    } else {
      obj[key] = value;
    }
    return obj;
  }

// Extracted from shiny.js to keep past version consistency
function narrowScopeComponent(scopeComponent, nsPrefix) {
  return Object.keys(scopeComponent).filter(function (k) {
    return k.indexOf(nsPrefix) === 0;
  }).map(function (k) {
    return _defineProperty({}, k.substring(nsPrefix.length), scopeComponent[k]);
  }).reduce(function (obj, pair) {
    return $.extend(obj, pair);
  }, {});
}

function narrowScope(scope, nsPrefix) {
  return nsPrefix ? {
    input: narrowScopeComponent(scope.input, nsPrefix),
    output: narrowScopeComponent(scope.output, nsPrefix)
  } : scope;
}

var condition_funcs = {};
var get_condition_func = function(expr) {
  if (!condition_funcs[expr]) {
    condition_funcs[expr] = scopeExprToFunc(expr);
  }
  return condition_funcs[expr];
};

// Single rule is stored in separate attributes, multiple rules as JSON array.
// Attributes are read on each run so that they can be modified directly.
var get_rules = function(el) {
  var rules_json = el.attr("data-call-rules");
  if (rules_json) {
    return JSON.parse(rules_json);
  }
  return [{
    "condition": el.attr("data-call-if"),
    "true": el.attr("data-call-if-true"),
    "false": el.attr("data-call-if-false"),
    "once": Boolean(el.attr("data-call-once")),
    "ns": el.attr("data-ns-prefix")
  }];
};

var js_call_once_per_flush = false;
var condjs_run_idx = 1;
var flush_counter = 0;

var count_flush = function(message) {
  js_call_once_per_flush = true;
  flush_counter = flush_counter + 1;
}
Shiny.addCustomMessageHandler('count_flush', count_flush);

// Based on ShinyApp.$updateConditionals
$(document).on('shiny:conditional', function(event) {

  if (js_call_once_per_flush && (condjs_run_idx == flush_counter)) {
    return;
  }
  condjs_run_idx = flush_counter;
  var inputs = {};
  for (var name in Shiny.shinyapp.$inputValues) {
    if (Shiny.shinyapp.$inputValues.hasOwnProperty(name)) {
      var shortName = name.replace(/:.*/, "");
      inputs[shortName] = Shiny.shinyapp.$inputValues[name];
    }
  }
  var scope = {
    input: inputs,
    output: Shiny.shinyapp.$values
  };
  var conditionals = $(document).find("[data-call-if], [data-call-rules]");
  for (var i = 0; i < conditionals.length; i++) {
    var el = $(conditionals[i]);
    var rules = get_rules(el);
    var states = el.data("data-call-states") || [];
    var js_calls = [];
    for (var j = 0; j < rules.length; j++) {
      var rule = rules[j];
      var nsScope = narrowScope(scope, rule.ns);
      var trigger = get_condition_func(rule.condition)(nsScope);
      var should_run = !rule.once || (trigger != states[j]);
      if (should_run) {
        js_calls.push(trigger ? rule["true"] : rule["false"]);
      }
      states[j] = trigger;
    }
    el.data("data-call-states", states);

    (function() {
      for (var k = 0; k < js_calls.length; k++) {
        if (Boolean(js_calls[k])) {
          eval(js_calls[k]);
        }
      }
      $(this).data("data-call-initialized", true);
    }).call(el[0]);
  }
})
