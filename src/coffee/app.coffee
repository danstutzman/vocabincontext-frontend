React           = require 'react'
ReactDOM        = require 'react-dom'
ScreenComponent = require './ScreenComponent.coffee'

time = 10
render = ->
  target = document.getElementById('example')
  element = React.createElement ScreenComponent, time: time, responseType: 'SAY'
  ReactDOM.render element, target

decrementTime = ->
  if time > 0
    time -= 5
    render()
    window.setTimeout decrementTime, 5000

document.addEventListener 'DOMContentLoaded', (event) ->
  render()
  window.setTimeout decrementTime, 5000
