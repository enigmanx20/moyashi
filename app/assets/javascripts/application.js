// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
// require turbolinks
// require_tree .
//= require jquery.tablesorter
//= require jquery.freetile
//= require uikit.min
//= require jquery-ui-1.10.4.custom



// for Label management screen
function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    //$(link).closest(".fields").hide();
    $(link).closest(".fields").animate(
        {height: "hide", opacity: "hide"},
        "normal",
        "swing"
    );
}

function add_fields(link, association, content) {
        var new_id = new Date().getTime();
        var regexp = new RegExp("new_" + association, "g");
        $(link).parent().before(content.replace(regexp, new_id));
        $(link).parent().prev(".fields").last().hide().animate(
            {height: "show", opacity: "show"},
            "normal",
            "swing"
        );
}


// jquery table sorter
$(document).ready(function(){
    $(".my-table-tablesorter").tablesorter();
});


// jquery freetile
$(document).ready(function(){
    $('#freetile-container').freetile({
        selector: '.my-project-box',
        animate: true,
        elementDelay: 30
    });
});


// jquery ui sortable
$(document).ready(function(){
    $(".sortable").sortable({
        cursor: 'move',
        opacity: 0.8,
        update: function(event, div) {
            $(".sortable").find("input[id*=label_order]").each(function(i){
                $(this).val(i);
            });
        }
    });
});