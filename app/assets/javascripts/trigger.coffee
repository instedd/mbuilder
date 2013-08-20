@initTrigger = (triggerData) ->
  class Trigger
    constructor: (triggerData) ->
      @applicationId = triggerData.application_id
      @triggerId = triggerData.id
      @name = ko.observable(triggerData.name)
      @logic = new Logic(triggerData.logic ? {})

      @canSave = ko.computed =>
        $.trim(@name()).length > 0 && $.trim(@logic.incomingMessage()).length > 0

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
    constructor: (logicData) ->
      @incomingMessage = ko.observable(logicData.incoming_message)

    toJSON: =>
      incoming_message: @incomingMessage()

  window.model = new Trigger(triggerData)
  ko.applyBindings window.model

