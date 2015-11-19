React              = require 'react'
ReactDOM           = require 'react-dom'
Redux              = require 'redux'
_                  = require 'underscore'
DialogComponent    = require './DialogComponent.coffee'
FlashcardComponent = require './FlashcardComponent.coffee'
MenuComponent      = require './MenuComponent.coffee'
TopComponent       = require './TopComponent.coffee'

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
    when 'NEW_ROUTE'
      route = action.new_route
      updates = switch route[0]
        when ''          then { current_screen: 'MenuComponent' }
        when 'dialog'    then { current_screen: 'DialogComponent' }
        when 'flashcard'
          current_screen: 'FlashcardComponent'
          response_type: 'SAY'
          counter: 10
        else
          throw new Error("Unknown route '#{action.new_route.join('/')}'")
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

