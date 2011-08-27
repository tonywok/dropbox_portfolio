(($) ->
  class window.DropboxView extends Backbone.View
    id: 'dropbox'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#dropbox_template').html())
      @collection.bind('reset', @render)

    render: ->
      console.log("rendering dropboxview")
      $(@el).html(@template({}))
      $dropbox_items = this.$('#dropbox_items')

      @collection.each (dropbox_item) =>
        if dropbox_item.get('directory?')
          view = new DirectoryView(model: dropbox_item, collection: @collection)
        else
          view = new FileView(model: dropbox_item, collection: @collection)

        $dropbox_items.append(view.render().el)
      this

    events:
      "click button.sync" : "show_dialog"

    show_dialog: (event) ->
      event.preventDefault()
      section_dialog = new SectionDialogView(collection: @collection)
      section_dialog.render()

)(jQuery)
