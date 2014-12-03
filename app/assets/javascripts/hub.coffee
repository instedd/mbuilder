class HubJsApi
  constructor: (@url) ->
    @pickers = {}

    if window.addEventListener
      window.addEventListener "message", (e) =>
        @_message(e)
      , false
    else
      window.attachEvent "onmessage", (e) =>
        @_message(e)


  openPicker: (type) ->
    pickerWin = window.open("#{@url}/api/picker")
    pr = new PickerResult(@, pickerWin)
    @pickers[pr.id] = pr
    pr

  url: ->
    @url

  _message: (event) ->
    data = JSON.parse(event.data)
    @pickers[data.target][data.message](data)

class PickerResult
  constructor: (@api, @pickerWin) ->
    @id = Date.now()
    @waitingTimer = window.setInterval( =>
      @pickerWin.postMessage(JSON.stringify({source: @id, message:"waiting"}), @api.url)
    ,500)

  id: ->
    @id

  loaded: (event) ->
    window.clearInterval(@waitingTimer)

  selected: (event) ->
    @pickerWin.close()
    @then(event.path)

  then: (callback) ->
    @then = callback


window.HubJsApi = HubJsApi
