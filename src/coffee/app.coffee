_        = require './baz.coffee'
React    = require 'react'
ReactDOM = require 'react-dom'

Component = React.createClass
  displayName: 'Component'
  render: ->
    { div } = React.DOM
    div
      style:
        display: if @props.time % 2 == 0 then 'none' else 'block'
      "Hello #{@props.time}!"

time = 0
render = ->
  target = document.getElementById('example')
  element = React.createElement Component, time: time
  ReactDOM.render element, target

incrementTime = ->
  if time < 7
    time += 1
    render()
    window.setTimeout incrementTime, 500

document.addEventListener 'DOMContentLoaded', (event) ->
  incrementTime()
