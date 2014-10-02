jQuery("document").ready(function(){
  var already_overdetailed = false;
  jQuery(".detailed").on("mouseenter", function(){
    if(!already_overdetailed){
      already_overdetailed=true;
      var element = jQuery(this)
      var value = element.data("description");
      var description = jQuery('<div class="overdetail">'+value+'</div>');
      jQuery("body").append(description);
      jQuery(document).on("mousemove", function(e){
        description.css({
         left:  e.pageX+5,
         top:   e.pageY+2,
        });    
      });
      element.on("mouseleave", function(){
        element.off("mousemove");
        element.off("mouseleave");
        description.remove();
        already_overdetailed = false;
      });
    }
  });
});
