// Leonardo
// Use this file to add your javascript

$(document).ready(function() {
    //Add this class to an input form to auto submit on change
    $('.autosubmit').live('change', function() {
      setTimeout("$('#"+this.id+"').parents('form:first').submit();", 300);
      return false;
    });
    $('.selectable').live('change', function() {
      if ($(this).is(':checked')) {
        $(this).parents('tr').addClass('selected');
      } else {
        $(this).parents('tr').removeClass('selected');
      }
    });
    $('.selector').live('change', function() {
      $(".selectable").attr('checked', $(this).is(':checked')).each(function(){
        if ($(this).is(':checked')) {
            $(this).parents('tr').addClass('selected');
        } else {
            $(this).parents('tr').removeClass('selected');
        }
      });
    });
});