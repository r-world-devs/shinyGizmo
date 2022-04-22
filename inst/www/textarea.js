//@ sourceURL=textarea.js
const update_textarea = function(message) {
  $element = $('#' + message.id);
  $element.val(message.value);
};
Shiny.addCustomMessageHandler('update_textarea', update_textarea);
