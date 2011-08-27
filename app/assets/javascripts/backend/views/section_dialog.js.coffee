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
      $target = $(event.target)
      url = $target.attr('action')
      section_name = $target.find('#section_name').val()
      data = { section_name : section_name, files : @collection.dropbox_files() }

      $.post url, data, (resp) ->
        alert("success")

)(jQuery)
