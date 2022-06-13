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

// Based on ShinyApp.$updateConditionals
$(document).on('shiny:conditional', function(event) {

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
    var nsScope = Shiny.shinyapp._narrowScope(scope, nsPrefix);
    var trigger = condFunc(nsScope);
    var js_call;
    // todo assure to be not accumulate (keep state?)
    if (trigger) {
      js_call = el.attr("data-call-if-true");
    } else {
      js_call = el.attr("data-call-if-false");
    }
    (function() {
      if (Boolean(js_call)) {
        eval(js_call);
      }
    }).call(el[0]);
  }
})
