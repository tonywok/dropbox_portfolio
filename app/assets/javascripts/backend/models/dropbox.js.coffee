(($) ->
  class window.Dropbox extends Backbone.Collection
    model: DropboxItem
    url: "/admin/dropboxes"

    dropbox_files: ->
      files = @reject (dropbox_item) ->
        dropbox_item['directory?'] == false

  window.dropbox = new Dropbox()
)(jQuery)
