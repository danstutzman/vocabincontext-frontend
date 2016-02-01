React              = require 'react'
VocabInContextComponent = require './VocabInContextComponent.coffee'

ENTER_KEY_CODE = 13

TopComponent = React.createClass
  displayName: 'TopComponent'
  render: ->
    { button, div, img, input } = React.DOM
    { state, dispatch, goToRoute } = @props

    switch state.loading_state
      when 'LOADING'
        div {}, 'Loading...'
        div
          style:
            textAlign: 'center'
            margin: '50px'
            fontFamily: 'sans-serif'
            fontSize: '30pt'
          'Loading'
          img
            style: display: 'inline'
            src: 'data:image/gif;base64,R0lGODlhKwALAPEAAP///wAAAIKCggAAACH+GkNyZWF0ZWQgd2l0aCBhamF4bG9hZC5pbmZvACH5BAAKAAAAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAKwALAAACMoSOCMuW2diD88UKG95W88uF4DaGWFmhZid93pq+pwxnLUnXh8ou+sSz+T64oCAyTBUAACH5BAAKAAEALAAAAAArAAsAAAI9xI4IyyAPYWOxmoTHrHzzmGHe94xkmJifyqFKQ0pwLLgHa82xrekkDrIBZRQab1jyfY7KTtPimixiUsevAAAh+QQACgACACwAAAAAKwALAAACPYSOCMswD2FjqZpqW9xv4g8KE7d54XmMpNSgqLoOpgvC60xjNonnyc7p+VKamKw1zDCMR8rp8pksYlKorgAAIfkEAAoAAwAsAAAAACsACwAAAkCEjgjLltnYmJS6Bxt+sfq5ZUyoNJ9HHlEqdCfFrqn7DrE2m7Wdj/2y45FkQ13t5itKdshFExC8YCLOEBX6AhQAADsAAAAAAAAAAAA='
      when 'ERROR'
        div {}, state.error
      when 'LOADED'
        div {},
          input
            id: 'query'
            ref: 'query'
            name: 'query'
            defaultValue: state.params.q
            placeholder: 'Filter by word'
            onKeyDown: (e) =>
              if e.keyCode == ENTER_KEY_CODE
                goToRoute q: @refs.query.value
          button
            className: 'search'
          React.createElement VocabInContextComponent,
            state: state,
            dispatch: dispatch

module.exports = TopComponent
