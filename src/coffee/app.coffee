{Promise}          = require 'bluebird'
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

FADE_DURATION = 1

{ protocol, hostname } = window.location
backendRoot = if hostname == 'localhost' or hostname.indexOf('10.') == 0
    "http://#{hostname}:9292"
  else if hostname.indexOf('ngrok.com') + 'ngrok.com'.length == hostname.length
    "http://10.0.0.62:9292"
  else "#{protocol}//#{hostname}"

reducer = (state, action) ->
  #console.log 'action', stringifyState(action)
  update = (commands) -> ReactAddonsUpdate state, commands
  switch action.type
    when '@@redux/INIT' then state
    when 'NEW_ROUTE'
      update
        loading_state: { $set: 'LOADING' }
        params: { $set: action.params }
        data: $set: null
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
      goToRoute: (params) ->
        paramsString = ''
        keys = (key for key of params)
        keys.sort()
        for key in keys
          paramsString += (if paramsString == '' then '?' else '&') +
            "#{encodeURIComponent(key)}=#{encodeURIComponent(params[key])}"
        window.history.pushState { params: params }, null, "/#{paramsString}"
        dispatchAndRender type: 'NEW_ROUTE', params: params

    ReactDOM.render app, document.getElementById('root')

  store = Redux.createStore reducer, { loading_state: 'LOADING' }

  lineNumToBufferPromise = []
  handleParams = (params) ->
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

  currentlyPlayingSource = null
  dispatchAndRender = (action) ->
    if action.type == 'SET_AUDIO_PLAY_STATE'
      # see http://stackoverflow.com/questions/12517000/no-sound-on-ios-6-web-audio-api#32840804
      if window.myAudioContext == undefined
        if 'AudioContext' of window
          window.myAudioContext = new AudioContext()
        else if 'webkitAudioContext' of window
          window.myAudioContext = new webkitAudioContext()
        else
          alert 'Your browser does not support yet Web Audio API'
        oscillator = window.myAudioContext.createOscillator()
        oscillator.frequency.value = 400
        oscillator.connect window.myAudioContext.destination
        oscillator.start 0
        oscillator.stop 0

      if currentlyPlayingSource and action.play_state != 'PLAYING'
        currentlyPlayingSource.stop()

      line = store.getState().data.lines[action.line_num]
      if action.play_state == 'LOADING'
        lineNumToBufferPromise[action.line_num] ?= new Promise (resolve, reject) ->
          path = backendRoot + '/excerpt.aac' +
            '?video_id=' + line.video_id +
            '&begin_millis=' + (line.begin_millis - FADE_DURATION * 1000) +
            '&end_millis=' + (line.end_millis + FADE_DURATION * 1000)
          xhr = new XMLHttpRequest()
          xhr.open 'GET', path, true
          xhr.responseType = 'arraybuffer'
          xhr.onload = -> resolve xhr.response
          xhr.send()

        lineNumToBufferPromise[action.line_num].then (xhr_response) ->
          dispatchAndRender
            type: 'SET_AUDIO_PLAY_STATE'
            play_state: 'PLAYING'
            line_num: action.line_num

          success = (buffer) ->
            context = window.myAudioContext
            currentlyPlayingSource = context.createBufferSource()
            gain = context.createGain()
            currentlyPlayingSource.buffer = buffer
            currentlyPlayingSource.connect gain
            gain.connect context.destination

            # fade in
            gain.gain.linearRampToValueAtTime 0.0,
              context.currentTime
            gain.gain.linearRampToValueAtTime 1.0,
              context.currentTime + FADE_DURATION

            # fade out
            excerptDuration = (line.end_millis - line.begin_millis) / 1000
            gain.gain.linearRampToValueAtTime 1.0,
              context.currentTime + FADE_DURATION + excerptDuration
            gain.gain.linearRampToValueAtTime 0.0,
              context.currentTime + FADE_DURATION + excerptDuration + FADE_DURATION

            currentlyPlayingSource.onended = ->
              currentlyPlayingSource = null
              dispatchAndRender
                type: 'SET_AUDIO_PLAY_STATE'
                play_state: 'STOPPED'
                line_num: action.line_num
            currentlyPlayingSource.start 0
          error = (e) ->
            throw new Error "Error decoding audio data: #{if e then e.err}"
          window.myAudioContext.decodeAudioData xhr_response, success, error

    if action.type == 'NEW_ROUTE'
      handleParams action.params

    store.dispatch action
    render dispatchAndRender

  window.onpopstate = (event) ->
    params = {}
    for pair in location.search.substr(1).split('&')
      [key, value] = pair.split('=')
      params[decodeURIComponent(key)] = decodeURIComponent(value)
    dispatchAndRender type: 'NEW_ROUTE', params: params
  window.onpopstate null # handle current GET params
