(($) ->
  class window.DropboxSync extends Backbone.Router
    routes:
      "cd/*dir" : "cd"

    cd: (dir) ->
      $.getJSON '/admin/dropboxes', { dir: dir }, (data) =>
        if _.isEmpty(data.dirs)  then @DirsCollection.reset()  else @DirsCollection.reset(data.dirs)
        if _.isEmpty(data.files) then @FilesCollection.reset() else @FilesCollection.reset(data.files)

  window.init = ->
    window.App          = new DropboxSync()
    App.DirsCollection  = new DirsCollection()
    App.FilesCollection = new FilesCollection()
    App.DirsView        = new DirsCollectionView(collection: App.DirsCollection, el: $('#dropbox_dirs'))
    App.FilesView       = new FilesCollectionView(collection: App.FilesCollection, el: $('dropbox_files'))
    Backbone.history.start(root: '/admin/dropboxes')

)(jQuery)
