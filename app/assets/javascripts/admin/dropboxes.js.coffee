$(document).ready ->

  $('form#add_dropbox').submit (e) ->
    e.preventDefault()
    $('#dropbox_meta').html('')

    url       = $(this).attr('action')
    form_data = $(this).serialize()

    $.post(url, form_data, (resp) ->
      template = _.template($('#dropbox_meta_template').html())
      console.log(resp)
      _.each(resp, (meta_item) ->
        $('#dropbox_meta').append(template(meta_item))
      )
    , 'json')

