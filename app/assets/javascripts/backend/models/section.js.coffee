(($) ->
  class window.Section extends Backbone.Model
    url: "/admin/dropboxes/sync"

    initialize: (attrs) ->
      @name = attrs.name
      @description = attrs.description
      @dropbox_files = attrs.dropbox_files

    toJSON: ->
      "section" : @attributes

)(jQuery)
