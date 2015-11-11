_        = require './baz.coffee'
React    = require 'react'
ReactDOM = require 'react-dom'

Component = React.createClass
  displayName: 'Component'
  render: ->
    { div } = React.DOM
    div {}, "Hello #{@props.name}!"

target = document.getElementById('example')
element = React.createElement Component, name: 'World'
ReactDOM.render element, target
