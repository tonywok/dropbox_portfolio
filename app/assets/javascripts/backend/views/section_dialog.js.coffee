(($) ->
  class window.SectionDialogView extends Backbone.View
    className: 'dialog'
    id: 'section_dialog'

    initialize: ->
      _.bindAll(this, 'render')
      @template = _.template($('#section_dialog_template').html())

    render: ->
      $(@el).html(@template({}))
      $(@el).dialog(title: 'section dialog')

      section_name = @.$('input#section_name')
      section_name.autocomplete(source: section_name.data('auto_complete'))
      this

    events:
      "submit form" : "sync"

    sync: (event) ->
      event.preventDefault()
      attrs =
        name: $('#section_name').val()
        description: $('#section_description').val()
        dropbox_files: @collection.dropbox_files()

      new Section(attrs).save()

)(jQuery)
