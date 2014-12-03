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
    pr = new PickerResult(@)
    pr.show()
    @pickers[pr.id] = pr
    pr

  url: ->
    @url

  _message: (event) ->
    data = JSON.parse(event.data)
    @pickers[data.target][data.message](data)

class PickerResult
  constructor: (@api) ->
    @id = Date.now()

  show: ->
    @container = $('<div>')
      .css('position', 'fixed')
      .css('left', 0).css('right', 0).css('top', 0).css('bottom', 0).css('z-index', 1040)
    grayBackground =$('<div>')
      .css('background-color', 'black')
      .css('opacity', 0.8)
      .css('width', '100%')
      .css('height', '100%')
      .click( =>
        @close()
      )
    @container.append(grayBackground)
    $('body').append(@container)

    iframe = $("<iframe>").width(@container.width() * 0.8).height(@container.height() * 0.8)
      .attr('src', "#{@api.url}/api/picker")
      .css('position', 'absolute')
      .css('left', @container.width() * .1)
      .css('top', @container.height() * .1)
    @container.append(iframe)

    @pickerWin = iframe[0].contentWindow

    @waitingTimer = window.setInterval( =>
      @pickerWin.postMessage(JSON.stringify({source: @id, message:"waiting"}), @api.url)
    ,500)

  id: ->
    @id

  loaded: (event) ->
    window.clearInterval(@waitingTimer)

  selected: (event) ->
    @close()
    @then(event.path)

  close: ->
    @container.remove()

  then: (callback) ->
    @then = callback


window.HubJsApi = HubJsApi
