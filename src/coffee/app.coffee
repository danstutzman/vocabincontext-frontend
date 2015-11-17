_        = require './baz.coffee'
draw     = require './draw.js'
React    = require 'react'
ReactDOM = require 'react-dom'

Component = React.createClass
  displayName: 'Component'
  render: ->
    { canvas, div, input } = React.DOM

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
            throw new Error('Unknown responseType')

      div
        className: 'bottom-half'
        if @props.responseType is 'SAY'
          'fake waveform here'
        else if @props.responseType is 'DRAW'
          canvas
            className: 'drawing-pad'
            width: 320
            height: 200
            onMouseDown:  (e) -> draw.findxy 'down', e
            onMouseMove:  (e) -> draw.findxy 'move', e
            onMouseUp:    (e) -> draw.findxy 'up', e
            onMouseOut:   (e) -> draw.findxy 'out', e
            onTouchStart: (e) -> draw.findxy2 'down', e
            onTouchMove:  (e) -> draw.findxy2 'move', e
        else if @props.responseType is 'TYPE'
          'keyboard here'
        else
          throw new Error('Unknown responseType')

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
