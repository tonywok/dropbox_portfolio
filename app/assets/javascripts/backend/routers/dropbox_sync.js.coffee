(($) ->
  class window.DropboxSync extends Backbone.Router
    routes:
      ""        : "home"
      "cd/*dir" : "cd"

    home: ->
      @dropbox_view = new DropboxView(collection: window.dropbox)
      $("#dropbox_container").empty()
      $("#dropbox_container").append(@dropbox_view.el)

    cd: (dir) ->
      @dropbox_view = new DropboxView(collection: window.dropbox)
      @dropbox_view.collection.fetch(data: { dir: dir })
      $("#dropbox_container").empty()
      $("#dropbox_container").append(@dropbox_view.el)

  $(document).ready ->
    window.App = new DropboxSync()
    Backbone.history.start(root: '/admin/dropboxes')

)(jQuery)
