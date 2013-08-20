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
      @actions = ko.observableArray([])

      @canSave = ko.computed =>
         $.trim(@message()).length > 0

    phoneNumberDragStart: (model, event) =>
      event.originalEvent.dataTransfer.setData("pill", "phone_number")
      true

    dragOverFieldName: (model, event) =>
      event.originalEvent.preventDefault()
      true

    dropOverFieldName: (model, event) =>
      pillName = event.originalEvent.dataTransfer.getData("pill")
      @actions.push new SelectOrCreate(new PillBinding(pillName), model)

    dragOverFieldValue: (model, event) =>
      event.originalEvent.preventDefault()
      true

    dropOverFieldValue: (model, event) =>
      pillName = event.originalEvent.dataTransfer.getData("pill")
      @actions.push new StoreValue(new PillBinding(pillName), model)

    toJSON: =>
      message: @message()

  class Table
    constructor: (data) ->
      @guid = data.guid ? window.guid()
      @name = ko.observable(data.name)
      @fields = ko.observableArray([])
      @hasFocus = ko.observable(data.focus)

    newField: =>
      @fields.push new Field(@, name: "Field #{@fields().length + 1}", focus: true)

  class Field
    constructor: (table, data) ->
      @table = table
      @guid = data.guid ? window.guid()
      @name = ko.observable(data.name)
      @value = ko.observable(data.value)
      @hasFocus = ko.observable(data.focus)

  class PillBinding
    constructor: (name) ->
      @name = ko.observable(name)

  class SelectOrCreate
    constructor: (binding, field) ->
      @kind = 'select_or_create'
      @binding = ko.observable(binding)
      @field = ko.observable(field)

      @tableName = ko.computed => @field().table.name()
      @fieldName = ko.computed => @field().name()
      @bindingName = ko.computed => @binding().name()

  class StoreValue
    constructor: (binding, field) ->
      @kind = 'store_value'
      @binding = ko.observable(binding)
      @field = ko.observable(field)

      @tableName = ko.computed => @field().table.name()
      @fieldName = ko.computed => @field().name()
      @bindingName = ko.computed => @binding().name()

  window.model = new Trigger(triggerData)
  ko.applyBindings window.model
