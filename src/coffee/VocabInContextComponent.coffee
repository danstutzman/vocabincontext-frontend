_      = require 'underscore'
React  = require 'react'

NON_BREAKING_SPACE = '\u00a0'

VocabInContextComponent = React.createClass
  displayName: 'VocabInContextComponent'
  render: ->
    { div, li } = React.DOM
    { state, dispatch } = @props

    if state.error
      return div {}, state.error

    div {},
      _.map state.data.lines, (line, lineNum) ->
        do (lineNum) ->
          div
            className: 'excerpt nonexpanded'
            key: lineNum
            div
              className: 'cover'
              style:
                background: "url(#{line.cover_image_url})"
            if line.play_state == 'LOADING'
              div className: 'spinner', style: display: 'block'
            else if line.play_state == 'PLAYING'
              null
            else
              div
                className: 'play-button'
                onClick: (e) ->
                  e.preventDefault()
                  dispatch
                    type: 'SET_AUDIO_PLAY_STATE'
                    play_state: 'LOADING'
                    line_num: lineNum
            div
              className: 'utterance'
              _.map line.words, (word, w) ->
                div
                  key: w
                  className: 'word'
                  div
                    className: "spanish rating#{word.rating}"
                    "#{word.before || ''}#{word.word}#{word.after || ''}"
                  div
                    className: 'gloss'
                    if word.gloss
                      "#{word.before || ''}#{word.gloss}#{word.after || ''}"
                    else
                      NON_BREAKING_SPACE

module.exports = VocabInContextComponent
