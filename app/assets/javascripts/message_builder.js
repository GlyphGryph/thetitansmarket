var foo = null;
jQuery("document").ready(function(){
  var can_make_new = true;
  jQuery(".message-form .add-gesture").click(function(){
    if(can_make_new && disableNew()){
      var template_content = jQuery(".reference-template.new-gesture").html();
      var new_element = jQuery(template_content);
      template_content = jQuery(".reference-template.select-gesture").html();
      new_element.find(".gesture-builder").html(template_content);
      jQuery(".message-list").append(new_element);
      foo = new_element;
      new_element.find(".gesture-option").click(selectGestureOption);
    }
  });

  jQuery(".message-form .add-speech").click(function(){
    var template_content = jQuery(".new-speech").html();
    var new_element = jQuery("<div class='message-element speech-element'>"+template_content+"</div>");
    jQuery(".message-list").append(new_element);
  });

  function disableNew(){
    jQuery(".message-form-controls").hide();
    if(can_make_new){
      can_make_new = false;
      return true;
    }else{
      return false;
    }
  };

  function enableNew(){
    jQuery(".message-form-controls").show();
    can_make_new = true;
    return true;
  };

  function selectGestureOption(){
    var selected = jQuery(this);
    foo = selected;
    var gesture_element = selected.parents(".message-element");
    gesture_element.text(selected.find(".option-description").text());
    enableNew();
  };
});

