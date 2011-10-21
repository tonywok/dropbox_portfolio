(($) ->
  class window.FileView extends Backbone.View
    className: "dropbox_item file"

    initialize: (data) ->
      _.bindAll(this, 'render')
      @template = _.template($('#file_template').html())
      @render()

    render: ->
      file = $(@el).html(@template(@model.toJSON()))
      file.appendTo("#dropbox_files")

)(jQuery)
