$ ->
  spinner = new Spinner().spin()

  $('nav ul.files li a', 'nav li.static a').pjax('#main').live 'click', (event) ->
    event.preventDefault()
    $('#main').append(spinner.el)
