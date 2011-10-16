$(document).ready ->
  # Zookeeper context switch
  $('#zookeeper_id').live 'change', ->
    #reload page with new zookeeper
    $(this).closest('form').submit()

  # Remove blue oval around clicked jstree elements
  $('.jstree-clicked').live 'click', ->
    $('.jstree-clicked').removeAttr('class', 'jstree-clicked')

  # Listener to hide dialog on click
  $('.ui-widget-overlay').live "click", -> $(".ui-dialog-content").dialog "close"
  
  #faster tooltip for the search table
  $('[title]:not(.action-icon)').tooltip
    show:
      delay: 250
  
  #slower tooltip for the saved buttons  
  $('.action-icon').tooltip
    show:
      delay: 1000
          
  $('html').live 'ajax:success', ->
    # remove old tooltips
    $('.ui-tooltip').remove()
    
    #faster tooltip for the search table
    $('[title]:not(.action-icon)').tooltip
      show:
        delay: 250
        
    #slower tooltip for the saved buttons    
    $('.action-icon').tooltip
      show:
        delay: 1000
        
  #fade out flash messages for logging in and out
  $("#flash").delay(5000).fadeOut("slow")
  
  # Initialize Help
  $('#page-help').click ()->
    url = window.location.pathname
    tab
    if url == '/'
      tab = "dashboard"
    else if url.substring(1) == 'zookeeper'
      tab = "environment"
    else if url.substring(1) == 'users'
      tab = "admin"
    else 
      pre_tab = url.substring 1
      if pre_tab.indexOf('/') != -1
        tab = pre_tab.substring 0, pre_tab.indexOf '/'
      else
        tab = pre_tab
        
    help_win = window.open Routes.help_path(tab),"Help Menu","menubar=0,resizable=0,width=500,height=800"
      
  $('.help-section').live 'click', ->
    $(this).children('.help-content').toggle('fast')
    
  # Fix menus with no zookeeper context
  if typeof Zookeeper != 'undefined' && Zookeeper.instances
    $('#env_link, #tables_link, #queries_link, #search_link').click (evt)->
      if Zookeeper.instances.length == 0
        alert 'There are no Zookeeper Instances registered yet.  This page will not work until then.'
        return false
      else if Zookeeper.instances.length == 1
        self = this
        $.ajax Routes.make_current_zookeeper_path(), 
          type: 'put',
          data:
            id: Zookeeper.instances[0].id
          success: () ->
            window.location = self.href
        return false
      else
        self = this
        select_box = "<div style='text-align:center'><select id='zookeeper_selector'>"
        $.each Zookeeper.instances, () ->
          select_box += "<option value='#{this.id}'>#{this.name}</option>"
        select_box += "</select></div>"
        $(select_box).dialog
          autoOpen: true
          height: 150
          width: 350
          modal: true
          title: 'Select a Zookeeper Instance to use:'
          buttons: {
        	  "Go": ()->
        	    $.ajax Routes.make_current_zookeeper_path(), 
                type: 'put',
                data:
                  id: $('#zookeeper_selector').val()
                success: () ->
                  window.location = self.href
              $(this).dialog("close")
            "Cancel": () ->
              $(this).dialog("close")
          }
        return false