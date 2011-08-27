(($) ->
  class window.FileView extends Backbone.View
    className: "dropbox_item file"

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#file_template').html())

    render: ->
      $(@el).html(@template(@model.toJSON()))
      this
)(jQuery)
