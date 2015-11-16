_        = require './baz.coffee'
React    = require 'react'
ReactDOM = require 'react-dom'

Component = React.createClass
  displayName: 'Component'
  render: ->
    { div, input } = React.DOM

    div
      className: 'screen'
      div
        className: 'past-card'
      div
        className: 'future-card'
      div
        className: 'present-card'
        div
          className: 'bent-corner'
        div
          className: 'time-warning'
          if @props.responseType is 'SAY'
            'Say aloud in :05'
          else if @props.responseType is 'DRAW'
            'Draw character below in :05'
          else if @props.responseType is 'TYPE'
            input
              placeholder: 'Type reply here'
          else
            throw new Error('responseType must be SAY, DRAW, or TYPE')
      div
        className: 'bottom-half'

time = 0
render = ->
  target = document.getElementById('example')
  element = React.createElement Component, time: time, responseType: 'SAY'
  ReactDOM.render element, target

incrementTime = ->
  if time < 9
    time += 1
    render()
    window.setTimeout incrementTime, 500

document.addEventListener 'DOMContentLoaded', (event) ->
  incrementTime()
