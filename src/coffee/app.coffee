React              = require 'react'
ReactDOM           = require 'react-dom'
ReactAddonsUpdate  = require 'react-addons-update'
Redux              = require 'redux'
_                  = require 'underscore'
dialog             = require './dialog.js'
DialogComponent    = require './DialogComponent.coffee'
FlashcardComponent = require './FlashcardComponent.coffee'
MenuComponent      = require './MenuComponent.coffee'
TopComponent       = require './TopComponent.coffee'
VocabInContextComponent = require './VocabInContextComponent.coffee'

backendRoot = switch window.location.hostname
  when 'localhost' then 'http://localhost:9292'
  else "#{window.location.protocol}//#{window.location.hostname}"

reducer = (state, action) ->
  #console.log 'action', stringifyState(action)
  update = (commands) -> ReactAddonsUpdate state, commands
  switch action.type
    when '@@redux/INIT' then state
    when 'NEW_ROUTE'
      update loading_state: { $set: 'LOADING' }, data: $set: null
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
    when 'DIALOG/SELECT_UTTERANCE'
      _.defaults { selected_utterance_num: action.utterance_num }, state
    when 'GOT_ERROR'
      update loading_state: { $set: 'ERROR' }, data: $set: action.error
    when 'GOT_DATA'
      update loading_state: { $set: 'LOADED' }, data: $set: action.data
    when 'SET_AUDIO_PLAY_STATE'
      update data: lines: "#{action.line_num}": play_state: $set: action.play_state
    when 'SET_EXPANDED'
      updateLines = {}
      for line, lineNum in state.data.lines
        updateLines[lineNum] = expanded: $set: lineNum == action.line_num
      update data: lines: updateLines
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
  render = (dispatchAndRender) ->
    app = React.createElement TopComponent,
      state: store.getState()
      dispatch: dispatchAndRender
    ReactDOM.render app, document.getElementById('root')

  store = Redux.createStore reducer, { loading_state: 'LOADING' }

  handleParams = (paramsString) ->
    params = {}
    for item in paramsString.substr(1).split('&')
      if item != ''
        s = item.split("=")
        params[s[0]] = s[1] && decodeURIComponent(s[1])

    req = { method: 'GET', url: "#{backendRoot}/api?q=#{params.q || ''}" }
    xhr = new XMLHttpRequest()
    xhr.open req.method, req.url, true
    xhr.onload = ->
      switch xhr.status
        when 200
          dispatchAndRender type: 'GOT_DATA', data: JSON.parse(xhr.responseText)
        else
          dispatchAndRender
            type: 'GOT_ERROR'
            error: "Error #{xhr.status} #{xhr.statusText} from #{
              req.method} #{req.url}"
    xhr.onerror = ->
      dispatchAndRender
        type: 'GOT_ERROR'
        error: "Error #{xhr.status} #{xhr.statusText} from #{
          req.method} #{req.url}"
    xhr.send()

  currentlyPlayingAudio = null
  dispatchAndRender = (action) ->
    if action.type == 'SET_AUDIO_PLAY_STATE'
      if currentlyPlayingAudio
        currentlyPlayingAudio.pause()

      line = store.getState().data.lines[action.line_num]
      if action.play_state == 'LOADING'
        currentlyPlayingAudio = new Audio(backendRoot + '/excerpt.aac' +
          '?video_id=' + line.video_id +
          '&begin_millis=' + line.begin_millis +
          '&end_millis=' + line.end_millis)
        currentlyPlayingAudio.addEventListener 'playing', ->
          dispatchAndRender
            type: 'SET_AUDIO_PLAY_STATE'
            play_state: 'PLAYING'
            line_num: action.line_num
        currentlyPlayingAudio.addEventListener 'ended', ->
          dispatchAndRender
            type: 'SET_AUDIO_PLAY_STATE'
            play_state: 'STOPPED'
            line_num: action.line_num
        currentlyPlayingAudio.play()

    if action.type == 'NEW_ROUTE'
      window.history.pushState { params: action.params }, null, "/#{action.params}"
      handleParams action.params

    store.dispatch action
    render dispatchAndRender

  window.onpopstate = (event) ->
    dispatchAndRender type: 'NEW_ROUTE', params: document.location.search
  window.onpopstate null # handle current GET params

  playingSource = null
  update_audio_from_state = ->
    # stop any currently playing audio
    if playingSource != null
      playingSource.onended = null
      playingSource.stop()
      playingSource = null

    state = store.getState()

    # if we should be playing something, start it playing
    if state.dialog.depressed_button in ['PLAY_ONE', 'PLAY_ALL']
      # select the first utterance if not is selected
      if state.selected_utterance_num is null
        store.dispatch
          type: 'DIALOG/SELECT_UTTERANCE'
          utterance_num: 0
        render()

      # start the audio playing
      playingSource = window.myAudioContext.createBufferSource()
      playingSource.buffer = window.myBuffer
      playingSource.connect window.myAudioContext.destination
      playingSource.onended = ->
        if state.dialog.depressed_button is 'PLAY_ALL'
          if state.selected_utterance_num < dialog.length - 1
            store.dispatch
              type: 'DIALOG/SELECT_UTTERANCE'
              utterance_num: state.selected_utterance_num + 1
            update_audio_from_state()
          else
            store.dispatch
              type: 'DIALOG/SELECT_UTTERANCE'
              utterance_num: null
            store.dispatch
              type: 'DIALOG/SET_DEPRESSED_BUTTON'
              new_depressed_button: null
        else if state.dialog.depressed_button is 'PLAY_ONE'
          store.dispatch
            type: 'DIALOG/SET_DEPRESSED_BUTTON'
            new_depressed_button: null
        render()
      span = dialog[state.selected_utterance_num || 0].m4a_milliseconds
      playingSource.start 0,
        Math.max(0, span[0] / 1000 - 0.1),
        (span[1] - span[0]) / 1000 + 0.1

  #decrementTime = ->
  #  if store.getState().counter > 0
  #    store.dispatch { type: 'FIVE_SECONDS_PASSED' }
  #    render()
  #    window.setTimeout decrementTime, 5000
  #window.setTimeout decrementTime, 5000

  if 'AudioContext' of window
    window.myAudioContext = new AudioContext()
  else if 'webkitAudioContext' of window
    window.myAudioContext = new webkitAudioContext()
  else
    alert 'Your browser does not support yet Web Audio API'

  #request = new XMLHttpRequest()
  #request.open 'GET', 'mp3/dialog1.m4a', true
  #request.responseType = 'arraybuffer'
  #request.onload = ->
  #  success = (buffer) ->
  #    window.myBuffer = buffer
  #  error = (e) ->
  #    throw new Error "Error decoding audio data: #{if e then e.err}"
  #  window.myAudioContext.decodeAudioData request.response, success, error
  #request.send()
