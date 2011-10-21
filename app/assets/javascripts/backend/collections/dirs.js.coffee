(($) ->
  class window.DirsCollection extends Backbone.Collection
    model: Dir
    url: "/admin/dropboxes"

    dropbox_dirs: ->
      @select (dropbox_item) ->
        dropbox_item['directory?'] == true

)(jQuery)
