(($) ->
  class window.FileView extends Backbone.View
    className: "dropbox_item file"

    initialize: (data) ->
      _.bindAll(this, 'render')
      @template = _.template($('#file_template').html())
      @render()

    render: ->
      file = $(@el).html(@template(@model.toJSON()))
      $(file).find('img').attr('src', "https://api.dropbox.com/0/links#{@model.get('path')}").css({width: '100px', height: '100px'})
      file.appendTo("#dropbox_files")

)(jQuery)
