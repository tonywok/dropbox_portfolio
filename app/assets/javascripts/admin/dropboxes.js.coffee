
# $('form#add_dropbox').submit (e) ->
#   e.preventDefault()
#   $('#dropbox_meta').html('')

#   url       = $(this).attr('action')
#   form_data = $(this).serialize()

#   $.post(url, form_data, (resp) ->
#     template = _.template($('#dropbox_meta_template').html())
#     _.each(resp, (meta_item) ->
#       $('#dropbox_meta').append(template(meta_item))
#     )
#   , 'json')
#
(($) ->

  class window.DropboxItem extends Backbone.Model

  class window.DirectoryView extends Backbone.View
    className: 'dropbox_item directory'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#directory_template').html())
      @render()

    render: ->
      $(@el).html(@template(@model.toJSON()))
      this

  class window.FileView extends Backbone.View
    className: "dropbox_item file"

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#file_template').html())
      @render()

    render: ->
      $(@el).html(@template(@model.toJSON()))
      this

  class window.Dropbox extends Backbone.Collection
    model: DropboxItem
    url: "/admin/dropboxes"

  class window.DropboxView extends Backbone.View
    id: 'dropbox'

    initialize: ->
      _.bindAll(this, 'render')
      @collection.bind('reset', @render)

    render: ->
      $el = $(@el).clone().empty()
      $el.append("<button data-url='admin/dropboxes/sync' class='sync'>Sync</button>")

      @collection.each (item) =>
        dropbox_item = new DropboxItem(item)

        if dropbox_item.get('directory?')
          view = new DirectoryView(model: dropbox_item, collection: @collection)
        else
          view = new FileView(model: dropbox_item, collection: @collection)

        $el.append(view.el)
      $('#dropbox_container').html($el)
      this

    events:
      "click button.sync" : "sync"

    sync: (event) ->
      event.preventDefault()
      $.post

  class window.DropboxSync extends Backbone.Router
    routes:
      "cd/*dir" : "cd"

    initialize: ->
      @dropbox_view = new DropboxView(collection: new Dropbox())

    cd: (dir) ->
      @dropbox_view.collection.fetch(data: { dir: dir })

  $(document).ready ->
    window.App = new DropboxSync()
    Backbone.history.start(root: '/admin/dropboxes')

)(jQuery)
