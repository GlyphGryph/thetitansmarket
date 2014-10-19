jQuery("document").ready(function(){
  var next_component_id = 0;
  var can_make_new = true;
  jQuery(".message-details .add-gesture").click(function(){
    if(can_make_new && disableNew()){
      var template_content = jQuery(".reference-template.new-gesture").html();
      var new_element = jQuery(template_content);
      template_content = jQuery(".reference-template.select-gesture").html();
      new_element.find(".gesture-builder").html(template_content);
      jQuery(".message-list").append(new_element);
      new_element.find(".gesture-option").click(selectGestureOption);
    }
  });

  jQuery(".message-details .add-speech").click(function(){
    var template_content = jQuery(".new-speech").html();
    var new_element = jQuery(template_content);
    jQuery(".message-list").append(new_element);
    new_element.find(".type-field").attr("name", "message_components["+next_component_id+"][type]");
    new_element.find(".text-field").attr("name", "message_components["+next_component_id+"][value]");
    next_component_id+=1;
  });

  function disableNew(){
    jQuery(".message-details-controls").hide();
    if(can_make_new){
      can_make_new = false;
      return true;
    }else{
      return false;
    }
  };

  function enableNew(){
    jQuery(".message-details-controls").show();
    can_make_new = true;
    return true;
  };

  function selectGestureOption(){
    var selected = jQuery(this);
    var selected_id = selected.data("id");
    var selected_text = selected.find(".option-description").text();
    var template_content = jQuery(".reference-template.commit-gesture").html();
    var gesture_element = selected.parents(".message-element")
    gesture_element.html(template_content);
    gesture_element.find(".id-field").val(selected_id);
    gesture_element.find(".id-field").attr("name", "message_components["+next_component_id+"][id]");
    gesture_element.find(".type-field").attr("name", "message_components["+next_component_id+"][value]");
    gesture_element.find(".description").text(selected_text);
    next_component_id+=1;
    enableNew();
  };
});

/*
<input value="wave" class="gesture-field" id="message_components_gestures_" name="message_components[gestures][]" type="hidden">
<textarea id="message_components_speeches_" name="message_components[speeches][]"></textarea>
*/
