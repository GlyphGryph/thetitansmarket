jQuery("document").ready(function(){
  if(jQuery("[data-apply-script='message-builder']").length){
    var next_component_id = 0;
    var can_make_new = true;
    jQuery(".message-details .add-gesture").click(function(){
      if(can_make_new && disableNew()){
        var template = jQuery(".reference-template.new-gesture");
        var new_element = jQuery(template.html());
        jQuery(".message-list").append(new_element);
        viewGestures(new_element);
      }
    });

    jQuery(".message-details .add-speech").click(function(){
      var template = jQuery(".new-speech");
      var new_element = jQuery(template.html());
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

    function viewGestures(container){
      template = jQuery(".reference-template.select-gesture");
      container.html(template.html());
      container.find(".gesture-option").click(selectGestureOption);
    }

    function selectGestureOption(){
      var selected = jQuery(this);
      var gesture_id = selected.data("gesture-id");
      var gesture_text = selected.find(".option-description").text();
      var container = selected.parents(".message-element")
      container.empty();
      // If there are no gesture-options in the target element, just confirm this selection
      var template = jQuery(".reference-template.gesture-targets[data-gesture-id='"+gesture_id+"']");
      if(template.find(".gesture-option").length < 1){
        confirmGesture(container, gesture_id, gesture_text);
      } else {
        viewGestureTargets(container, gesture_id);
      }
    };

    function viewGestureTargets(container, gesture_id){
      var template = jQuery(".reference-template.gesture-targets[data-gesture-id='"+gesture_id+"']");
      container.html(template.html());
      container.data("gesture-id", gesture_id);
      container.find(".gesture-option").click(selectGestureTarget);
    }

    function selectGestureTarget(){
      var selected = jQuery(this);
      var target = {
        'id': selected.data("target-id"),
        'type': selected.data("target-type"),
        'name': selected.data("target-name"),
      }
      var gesture_element = selected.parents(".message-element");
      var gesture_id = gesture_element.data("gesture-id");
      var gesture_text = gesture_element.find(".description").text();
      gesture_element.empty();
      confirmGesture(gesture_element, gesture_id, gesture_text, target);
    };

    function confirmGesture(container, gesture_id, gesture_text, target){
      var template = jQuery(".reference-template.commit-gesture");
      container.html(template.html());
      container.find(".id-field").attr("name", "message_components["+next_component_id+"][value]");
      container.find(".id-field").val(gesture_id);
      container.find(".type-field").attr("name", "message_components["+next_component_id+"][type]");
      container.find(".type-field").val("gesture");
      if(target){
        container.find(".target-id-field").attr("name", "message_components["+next_component_id+"][target][id]");
        container.find(".target-id-field").val(target.id);
        container.find(".target-type-field").attr("name", "message_components["+next_component_id+"][target][type]");
        container.find(".target-type-field").val(target.type);
        gesture_text += " Targeting: "+target.name
      }
      container.find(".description").text(gesture_text);
      next_component_id+=1;
      enableNew();
    }
  }
});
