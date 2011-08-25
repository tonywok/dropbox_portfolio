
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

    render: ->
      $(@el).html(@template(@model.toJSON()))
      this

  class window.Dropbox extends Backbone.Collection
    model: DropboxItem
    url: "/admin/dropboxes"

    dropbox_files: ->
      files = @reject (dropbox_item) ->
        dropbox_item['directory?'] == false
      JSON.stringify(files)

  window.dropbox = new Dropbox()

  class window.DropboxView extends Backbone.View
    id: 'dropbox'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#dropbox_template').html())
      @collection.bind('reset', @render)

    render: ->
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
      "click button.sync" : "sync"

    sync: (event) ->
      event.preventDefault()
      url = $('button.sync').data('url')

      data = { section : "test", files : @collection.dropbox_files() }

      $.post url, data, (resp) ->
        alert("success")

  class window.DropboxSync extends Backbone.Router
    routes:
      ""        : "home"
      "cd/*dir" : "cd"

    initialize: ->
      @dropbox_view = new DropboxView(collection: window.dropbox)

    home: ->
      $("#dropbox_container").empty()
      $("#dropbox_container").append(@dropbox_view.el)

    cd: (dir) ->
      @dropbox_view.collection.fetch(data: { dir: dir })
      $("#dropbox_container").empty()
      $("#dropbox_container").append(@dropbox_view.el)

  $(document).ready ->
    window.App = new DropboxSync()
    Backbone.history.start(root: '/admin/dropboxes')

)(jQuery)
