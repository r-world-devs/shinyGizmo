//@ sourceURL=modal.js
show_modal = function(message) {
  $('#' + message.id).modal('show');
};

Shiny.addCustomMessageHandler('show_modal', show_modal);

hide_modal = function(message) {
  $('#' + message.id).modal('hide');
};

Shiny.addCustomMessageHandler('hide_modal', hide_modal);
