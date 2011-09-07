$ ->

  spinner = new Spinner().spin()

  $('ul#nav li.with_subcontent a').pjax('#main').live 'click', (event) ->
    event.preventDefault()
    $('#main').append(spinner.el)
