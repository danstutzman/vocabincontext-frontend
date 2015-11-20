React              = require 'react'
ReactDOM           = require 'react-dom'
Redux              = require 'redux'
_                  = require 'underscore'
dialog             = require './dialog.js'
DialogComponent    = require './DialogComponent.coffee'
FlashcardComponent = require './FlashcardComponent.coffee'
MenuComponent      = require './MenuComponent.coffee'
TopComponent       = require './TopComponent.coffee'

reducer = (state, action) ->
  switch action.type
    when '@@redux/INIT' then state
    when 'NEW_ROUTE'
      route = action.new_route
      updates = switch route[0]
        when ''          then { current_screen: 'MenuComponent' }
        when 'dialog'
          current_screen: 'DialogComponent'
          dialog:
            paused: true
        when 'flashcard'
          current_screen: 'FlashcardComponent'
          response_type: 'SAY'
          counter: 10
        else
          throw new Error("Unknown route '#{action.new_route.join('/')}'")
      _.defaults updates, state
    when 'DIALOG/SET_PAUSED'
      _.defaults { dialog: { paused: action.new_paused } }, state
    when 'FLIP_CARD'
      _.defaults { counter: 0 }, state
    when 'FIVE_SECONDS_PASSED'
      if state.counter >= 0
        new_counter = if state.counter > 5 then state.counter - 5 else 0
        _.defaults { counter: new_counter }, state
      else
        state
    when 'SELECT_UTTERANCE'
      _.defaults { selected_utterance_num: action.utterance_num }, state
    else throw new Error("Unknown action type #{action.type}")

stringifyState = (object) ->
  out = ''
  keys = Object.keys(object).sort()
  for key in keys
    value = object[key]
    if out != ''
      out += ' '
    if typeof(value) is 'object'
      out += "#{key}{#{stringifyState(value)}}"
    else
      out += "#{key}:#{value}"
  out

document.addEventListener 'DOMContentLoaded', (event) ->
  store = Redux.createStore reducer, { current_screen: 'MenuComponent' }

  render = ->
    dispatch = (e, action) ->
      store.dispatch action
      render()
      e.preventDefault()
    console.log stringifyState(store.getState())
    app = React.createElement TopComponent,
      state: store.getState()
      dispatch: dispatch
    ReactDOM.render app, document.getElementById('root')

  oldDispatch = store.dispatch
  store.dispatch = (action) ->
    if action.type == 'DIALOG/SET_PAUSED'
      if !action.new_paused
        mySource = window.myAudioContext.createBufferSource()
        mySource.buffer = window.myBuffer
        mySource.connect window.myAudioContext.destination
        mySource.onended = ->
          oldDispatch { type: 'DIALOG/SET_PAUSED', new_paused: true }
          render()
        span = dialog[store.getState().selected_utterance_num].m4a_milliseconds
        mySource.start 0, span[0] / 1000 - 0.1, (span[1] - span[0]) / 1000 + 0.1
    oldDispatch action

  handleNewHash = ->
    route = window.location.hash.replace(/^#\/?|\/$/g, '').split('/')
    store.dispatch { type: 'NEW_ROUTE', new_route: route }
    render()
  handleNewHash()
  window.addEventListener 'hashchange', handleNewHash, false

  decrementTime = ->
    if store.getState().counter > 0
      store.dispatch { type: 'FIVE_SECONDS_PASSED' }
      render()
      window.setTimeout decrementTime, 5000
  window.setTimeout decrementTime, 5000

  if 'AudioContext' of window
    window.myAudioContext = new AudioContext()
  else if 'webkitAudioContext' of window
    window.myAudioContext = new webkitAudioContext()
  else
    alert 'Your browser does not support yet Web Audio API'

  request = new XMLHttpRequest()
  request.open 'GET', 'mp3/dialog1.m4a', true
  request.responseType = 'arraybuffer'
  request.onload = ->
    success = (buffer) ->
      window.myBuffer = buffer
    error = (e) ->
      throw new Error "Error decoding audio data: #{if e then e.err}"
    window.myAudioContext.decodeAudioData request.response, success, error
  request.send()
