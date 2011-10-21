(($) ->
  class window.DirView extends Backbone.View
    className: 'dropbox_item directory'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#directory_template').html())
      @render()

    render: ->
      dir = $(@el).html(@template(@model.toJSON()))
      dir.appendTo("#dropbox_dirs")

)(jQuery)
