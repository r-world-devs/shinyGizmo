//@ sourceURL=accordion.js
var collapse_all = function(message) {
    var target_id = '#' + message.id;
    $(target_id).find('div.sg_accordion_item').addClass('collapsed').find('.sg_accordion_activator').prop('disabled', false);
 };
Shiny.addCustomMessageHandler('collapse_items', collapse_all);

var collapse_rest = function(element, previous) {
  var $accordion_item = $(element).closest('.sg_accordion_item');
  if (previous) {
    $accordion_item = $accordion_item.prev();
  }
  $accordion_item.closest('.sg_accordion').find('div.sg_accordion_item')
    .addClass('collapsed').find('.sg_accordion_activator').prop('disabled', false);
  $accordion_item.removeClass('collapsed').find('.sg_accordion_activator').prop('disabled', true);
};

var enroll_accordion = function(message) {
  collapse_rest($('#' + message.id).find('div.sg_accordion_item').eq(message.index), false);
};
Shiny.addCustomMessageHandler('enroll_accordion', enroll_accordion);
