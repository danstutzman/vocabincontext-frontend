React              = require 'react'
DialogComponent    = require './DialogComponent.coffee'
MenuComponent      = require './MenuComponent.coffee'
FlashcardComponent = require './FlashcardComponent.coffee'

TopComponent = React.createClass
  displayName: 'TopComponent'
  render: ->
    switch @props.state.current_screen
      when 'DialogComponent'
        React.createElement DialogComponent,
          dispatch: @props.dispatch
      when 'FlashcardComponent'
        React.createElement FlashcardComponent,
          responseType: @props.state.response_type
          time: @props.state.counter
          dispatch: @props.dispatch
      when 'MenuComponent'
        React.createElement MenuComponent,
          dispatch: @props.dispatch
      else
        throw new Error("Unknown current_screen '#{@props.state.current_screen}'")

module.exports = TopComponent