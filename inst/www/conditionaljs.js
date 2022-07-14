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
  var conditionals = $(document).find("[data-call-if]");
  for (var i = 0; i < conditionals.length; i++) {
    var el = $(conditionals[i]);
    var condFunc = el.data("data-call-if-func");
    if (!condFunc) {
      var condExpr = el.attr("data-call-if");
      condFunc = scopeExprToFunc(condExpr);
      el.data("data-call-if-func", condFunc);
    }
    var nsPrefix = el.attr("data-ns-prefix");
    var nsScope = narrowScope(scope, nsPrefix);
    var trigger = condFunc(nsScope);
    var prev_state = el.data("data-call-state");
    var switch_only_run = Boolean(el.attr("data-call-once"));
    var should_run = !switch_only_run || (switch_only_run && (trigger != prev_state))
    var js_call = '';
    if (should_run) {
      if (trigger) {
        js_call = el.attr("data-call-if-true");
      } else {
        js_call = el.attr("data-call-if-false");
      }
    }
    el.data("data-call-state", trigger);

    (function() {
      if (Boolean(js_call)) {
        eval(js_call);
      }
      $(this).data("data-call-initialized", true);
    }).call(el[0]);
  }
})
