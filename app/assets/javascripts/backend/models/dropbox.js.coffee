(($) ->
  class window.Dropbox extends Backbone.Collection
    model: DropboxItem
    url: "/admin/dropboxes"

    dropbox_files: ->
      files = @reject (dropbox_item) ->
        dropbox_item['directory?'] == false
      JSON.stringify(files)

  window.dropbox = new Dropbox()
)(jQuery)
