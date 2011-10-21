(($) ->
  class window.DirsCollectionView extends Backbone.View
    id: 'dropbox_dirs'

    initialize: ->
      _.bindAll(this, 'render')
      @collection.bind('reset', @render)

    render: ->
      $(@el).find(".dropbox_item").remove()
      @collection.each (dropbox_dir) ->
        new DirView(model: dropbox_dir)

    # events:
    #   "click button.sync" : "show_dialog"

    # show_dialog: (event) ->
    #   event.preventDefault()
    #   section_dialog = new SectionDialogView(collection: @collection)
    #   section_dialog.render()

)(jQuery)
