React           = require 'react'
ReactDOM        = require 'react-dom'
Redux           = require 'redux'
ScreenComponent = require './ScreenComponent.coffee'
DialogComponent = require './DialogComponent.coffee'
MenuComponent   = require './MenuComponent.coffee'
TopComponent    = require './TopComponent.coffee'
_               = require 'underscore'

reducer = (state, action) ->
  switch action.type
    when '@@redux/INIT' then state
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
    when 'MENU_CHOICE'
      updates = switch action.new_current_screen
        when 'DialogComponent'
          { current_screen: 'DialogComponent' }
        when 'ScreenComponent'
          current_screen: 'ScreenComponent'
          response_type: 'SAY'
          counter: 10
        else
          throw new Error("Unknown new_current_screen #{action.new_screen_current}")
      _.defaults updates, state
    else throw new Error("Unknown action type #{action.type}")

document.addEventListener 'DOMContentLoaded', (event) ->
  store = Redux.createStore reducer, { current_screen: 'MenuComponent' }
  render = ->
    dispatch = (e, action) ->
      store.dispatch action
      render()
      e.preventDefault()
    console.log store.getState()
    app = React.createElement TopComponent,
      state: store.getState()
      dispatch: dispatch
    ReactDOM.render app, document.getElementById('root')
  render()
  decrementTime = ->
    if store.getState().counter > 0
      store.dispatch { type: 'FIVE_SECONDS_PASSED' }
      render()
      window.setTimeout decrementTime, 5000
  window.setTimeout decrementTime, 5000
