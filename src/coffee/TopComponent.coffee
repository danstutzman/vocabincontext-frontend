React           = require 'react'
MenuComponent   = require './MenuComponent.coffee'
DialogComponent = require './DialogComponent.coffee'
ScreenComponent = require './ScreenComponent.coffee'

TopComponent = React.createClass
  displayName: 'TopComponent'
  render: ->
    switch @props.state.current_screen
      when 'DialogComponent'
        React.createElement DialogComponent,
          dispatch: @props.dispatch
      when 'MenuComponent'
        React.createElement MenuComponent,
          dispatch: @props.dispatch
      when 'ScreenComponent'
        React.createElement ScreenComponent,
          responseType: @props.state.response_type
          time: @props.state.counter
          dispatch: @props.dispatch
      else
        throw new Error("Unknown current_screen '#{@props.state.current_screen}'")

module.exports = TopComponent
