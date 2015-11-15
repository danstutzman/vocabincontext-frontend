_        = require './baz.coffee'
React    = require 'react'
ReactDOM = require 'react-dom'

Component = React.createClass
  displayName: 'Component'
  render: ->
    { a, div } = React.DOM

    think_times = []
    for i in [1..9]
      maybe_past = (if 9 - i >= @props.time then '' else 'past')
      think_times.push div { className: "think-time #{maybe_past}", key: i }

    div { className: 'screen' },
      div { className: 'left icon sprity sprity-thought' }
      div { className: 'left thought-english' },
        div
          '(you)'
      div { style: { clear: 'both' } }

      div
        className: 'left icon sprity sprity-speech'
      if @props.time < 9
        think_times
      else
        div
          className: 'left speech-pinyin'
          'nĭ'
      div { style: { clear: 'both' } }

      a
        href: '#'
        div
          className: 'sprity sprity-right-arrow'
          style:
            position: 'absolute'
            bottom: '200px'
            left: '150px'
            backgroundColor: if @props.time < 9 then 'green' else 'red'

time = 0
render = ->
  target = document.getElementById('example')
  element = React.createElement Component, time: time
  ReactDOM.render element, target

incrementTime = ->
  if time < 9
    time += 1
    render()
    window.setTimeout incrementTime, 500

document.addEventListener 'DOMContentLoaded', (event) ->
  incrementTime()
