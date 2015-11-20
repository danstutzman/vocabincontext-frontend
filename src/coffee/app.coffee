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
            depressed_button: null
          selected_utterance_num: null
        when 'flashcard'
          current_screen: 'FlashcardComponent'
          response_type: 'SAY'
          counter: 10
        else
          throw new Error("Unknown route '#{action.new_route.join('/')}'")
      _.defaults updates, state
    when 'DIALOG/SET_DEPRESSED_BUTTON'
      _.defaults { dialog: { depressed_button: action.new_depressed_button } }, state
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
  if object is null
    'null'
  else if typeof(object) is 'object'
    keys = Object.keys(object).sort()
    out = "{"
    for key in keys
      value = object[key]
      if out != '{'
        out += ' '
      out += "#{key}:#{stringifyState(value)}"
    out += "}"
    out
  else
    "#{object}"

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
  playingSource = null
  store.dispatch = (action) ->
    state = store.getState()
    if action.type == 'DIALOG/SET_DEPRESSED_BUTTON'
      if playingSource != null
        playingSource.onended = null
        playingSource.stop()
      if action.new_depressed_button in ['PLAY_ONE', 'PLAY_ALL']
        playingSource = window.myAudioContext.createBufferSource()
        playingSource.buffer = window.myBuffer
        playingSource.connect window.myAudioContext.destination
        playingSource.onended = ->
          oldDispatch
            type: 'DIALOG/SET_DEPRESSED_BUTTON'
            new_depressed_button: null
          if action.new_depressed_button == 'PLAY_ALL'
            if state.selected_utterance_num < dialog.length - 1
              oldDispatch
                type: 'SELECT_UTTERANCE'
                utterance_num: state.selected_utterance_num + 1
              store.dispatch
                type: 'DIALOG/SET_DEPRESSED_BUTTON'
                new_depressed_button: 'PLAY_ALL'
            else
              oldDispatch
                type: 'SELECT_UTTERANCE'
                utterance_num: null
              oldDispatch
                type: 'DIALOG/SET_DEPRESSED_BUTTON'
                new_depressed_button: null
          else if action.new_depressed_button == 'PLAY_ONE'
            oldDispatch
              type: 'DIALOG/SET_DEPRESSED_BUTTON'
              new_depressed_button: null
          render()
        if state.selected_utterance_num is null
          oldDispatch
            type: 'SELECT_UTTERANCE'
            utterance_num: 0
            oldDispatch
              type: 'DIALOG/SET_DEPRESSED_BUTTON'
              new_depressed_button: null
          render()
        span = dialog[state.selected_utterance_num || 0].m4a_milliseconds
        playingSource.start 0,
          Math.max(0, span[0] / 1000 - 0.1),
          (span[1] - span[0]) / 1000 + 0.1
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
