# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ -> 
  $('ul#nav li.with_subcontent > a').bind 'click', (event) ->
    event.preventDefault()
    $parent_li = $(this).parent('ul#nav li.with_subcontent')
    $parent_li.toggleClass('selected', !$parent_li.hasClass('selected'))
    $parent_li.toggleClass('separated', !$parent_li.hasClass('separated'))
    $(this).next('ul.sub').slideToggle 'fast'

  $('ul.sub li a').hover(
    ->
      $(this).css('color', '#78B988')
      $(this).css('margin-left', '4px')
      $(this).next('.corner').show()
    ->
      $(this).css('color', '#000')
      $(this).css('margin-left', '0')
      $(this).next('.corner').hide()
  )






