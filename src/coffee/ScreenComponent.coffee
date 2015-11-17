draw     = require './draw.js'
React    = require 'react'

ScreenComponent = React.createClass
  displayName: 'ScreenComponent'
  render: ->
    { canvas, div, input } = React.DOM

    minutes = if @props.time >= 60 then Math.floor(@props.time / 60) else ''
    seconds = "#{@props.time % 60}"
    seconds2Digits = if seconds.length == 1 then "0#{seconds}" else seconds
    formattedTime = "#{minutes}:#{seconds2Digits}"

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
            "Say aloud in #{formattedTime}"
          else if @props.responseType is 'DRAW'
            "Draw character below in #{formattedTime}"
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

module.exports = ScreenComponent
