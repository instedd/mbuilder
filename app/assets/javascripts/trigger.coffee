@initTrigger = (triggerData) ->
  class Trigger
    constructor: (triggerData) ->
      @applicationId = triggerData.application_id
      @triggerId = triggerData.id
      @name = ko.observable(triggerData.name)
      @logic = new Logic(triggerData.logic ? {})

      @canSave = ko.computed =>
        $.trim(@name()).length > 0 && @logic.canSave()

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
      @message = ko.observable(logicData.message)
      @canSave = ko.computed =>
         $.trim(@message()).length > 0

    toJSON: =>
      message: @message()

  window.model = new Trigger(triggerData)
  ko.applyBindings window.model

