React           = require 'react'
ReactDOM        = require 'react-dom'
Redux           = require 'redux'
ScreenComponent = require './ScreenComponent.coffee'
DialogComponent = require './DialogComponent.coffee'

reducer = (state, action) ->
  switch action.type
    when '@@redux/INIT' then state
    when 'FLIP_CARD'
      { counter: 0 }
    when 'FIVE_SECONDS_PASSED'
      if state.counter >= 0
        { counter: if state.counter > 5 then state.counter - 5 else 0 }
      else
        state
    else throw new Error("Unknown action type #{action.type}")

document.addEventListener 'DOMContentLoaded', (event) ->
  store = Redux.createStore reducer, { counter: 10 }
  render = ->
    dispatch = (e, action) ->
      store.dispatch action
      render()
      e.preventDefault()
#    app = React.createElement ScreenComponent,
#      time: store.getState().counter
#      responseType: 'SAY'
#      dispatch: dispatch
    app = React.createElement DialogComponent, {}
    ReactDOM.render app, document.getElementById('root')
  render()
  decrementTime = ->
    if store.getState().counter > 0
      store.dispatch { type: 'FIVE_SECONDS_PASSED' }
      render()
      window.setTimeout decrementTime, 5000
  window.setTimeout decrementTime, 5000
