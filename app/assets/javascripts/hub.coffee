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

    pickerWin = $("<iframe>").width(800).height(400)
      .attr('src', "#{@url}/api/picker")
      .css('position', 'absolute')
      .css('left', 50)
      .css('right', 50)
      .css('top', 50)
      .css('bottom', 50)
      .css('z-index', 100)

    $('body').append(pickerWin)
    pr = new PickerResult(@, pickerWin, pickerWin[0].contentWindow)
    @pickers[pr.id] = pr
    pr

  url: ->
    @url

  _message: (event) ->
    data = JSON.parse(event.data)
    @pickers[data.target][data.message](data)

class PickerResult
  constructor: (@api, @container, @pickerWin) ->
    @id = Date.now()
    @waitingTimer = window.setInterval( =>
      @pickerWin.postMessage(JSON.stringify({source: @id, message:"waiting"}), @api.url)
    ,500)

  id: ->
    @id

  loaded: (event) ->
    window.clearInterval(@waitingTimer)

  selected: (event) ->
    @container.remove()
    @then(event.path)

  then: (callback) ->
    @then = callback


window.HubJsApi = HubJsApi
