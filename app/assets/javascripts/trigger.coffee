@initTrigger = (triggerData) ->
  class Trigger
    constructor: (data) ->
      @applicationId = data.application_id
      @triggerId = data.id
      @name = ko.observable(data.name)
      @logic = new Logic(data.logic ? {})
      @tables = ko.observableArray([])

      @canSave = ko.computed =>
        $.trim(@name()).length > 0 && @logic.canSave()

    newTable: =>
      @tables.push new Table(name: "Table #{@tables().length + 1}", focus: true)

    save: =>
      return unless @canSave()

      if @triggerId
        url = "/applications/#{@applicationId}/triggers/#{@triggerId}"
        method = "PUT"
      else
        url = "/applications/#{@applicationId}/triggers"
        method = "POST"

      $.ajax url: url, type: method, data: JSON.stringify(@toJSON()), success: =>
        window.location = "/applications/#{@applicationId}/triggers"

    toJSON: =>
      trigger:
        name: @name()
      logic:
        @logic.toJSON()

  class Logic
    constructor: (data) ->
      @message = ko.observable(data.message)
      @canSave = ko.computed =>
         $.trim(@message()).length > 0

    toJSON: =>
      message: @message()

  class Table
    constructor: (data) ->
      @name = ko.observable(data.name)
      @fields = ko.observableArray([])
      @hasFocus = ko.observable(data.focus)

    newField: =>
      @fields.push new Field(name: "Field #{@fields().length + 1}", focus: true)

  class Field
    constructor: (data) ->
      @name = ko.observable(data.name)
      @value = ko.observable(data.value)
      @hasFocus = ko.observable(data.focus)

  window.model = new Trigger(triggerData)
  ko.applyBindings window.model

