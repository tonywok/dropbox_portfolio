(($) ->
  class window.FilesCollection extends Backbone.Collection
    model: File
    url: "/admin/dropboxes"

    dropbox_files: ->
      @reject (dropbox_item) ->
        dropbox_item['directory?'] == false

)(jQuery)
