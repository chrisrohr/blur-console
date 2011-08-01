$(document).ready ->
  #method to persist the preference to the DB
  save_pref = () ->    
    user_id = $('#show_user_wrapper').attr('data-user-id')
    $.ajax "/users/#{user_id}/preferences/column",
      type: 'PUT',
      data: $('#my-cols').sortable('serialize'),
      success: (data) ->
        
  save_filters = () ->
    #logic for saving to the DB
    
  #make this sortable
  $('#my-cols').sortable
    connectWith: "#actual-trash",
    #when the order is changed
    stop: ->
      save_pref()
      
  $('#my-cols').draggable()
  
  $('#actual-trash').droppable
    drop: (event, ui)->
      $(ui.draggable).remove()
      $('.sort#my-cols').sortable('refresh')
      $('.fam#' + $(ui.draggable).attr('id')).toggleClass 'my-select'
      save_pref()
    
  #click listener for the lists of column names
  $('.fam').live 'click', -> 
    $(this).toggleClass('my-select')
    clicked = $('#' + $(this).attr('id') + '.sel-fam')
    #if the element isnt in the list already
    if clicked.length == 0
      $('#no-saved').hide()
      app = $(this).clone().removeClass('fam my-select').addClass('sel-fam')
      $('#my-cols').append app.hide()
      app.fadeIn 'slow', -> save_pref()
    #if the element is already in the list
    else
      clicked.fadeOut 'slow', -> 
        clicked.remove()
        if $('#my-cols').children().length == 1
          $('#no-saved').fadeIn('fast')
        save_pref()
        
  #state change for the filter selectors
  $('.query_filter select').live 'change', ->
    $('form').submit()
    
    
    
