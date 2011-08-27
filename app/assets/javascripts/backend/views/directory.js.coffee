(($) ->
  class window.DirectoryView extends Backbone.View
    className: 'dropbox_item directory'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#directory_template').html())
      @render()

    render: ->
      $(@el).html(@template(@model.toJSON()))
      this
)(jQuery)
