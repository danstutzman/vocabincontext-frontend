_      = require 'underscore'
React  = require 'react'

NON_BREAKING_SPACE = '\u00a0'

VocabInContextComponent = React.createClass
  displayName: 'VocabInContextComponent'
  render: ->
    { div, li } = React.DOM
    { state, dispatch } = @props

    div {},
      _.map state.data.lines, (line, lineNum) ->
        do (lineNum) ->
          div
            key: lineNum
            className: "excerpt #{if line.expanded then 'expanded' else 'nonexpanded'}"

            div
              className: 'cover'
              style:
                background: "url(#{line.cover_image_url})"
              onClick: (e) ->
                dispatch
                  type: 'SET_AUDIO_PLAY_STATE'
                  play_state: null
                  line_num: lineNum

            if line.play_state == 'LOADING'
              div className: 'spinner', style: display: 'block'
            else if line.play_state == 'PLAYING'
              null
            else
              div
                className: 'play-button'
                onClick: (e) ->
                  e.preventDefault()
                  if not line.expanded
                    dispatch type: 'SET_EXPANDED', line_num: lineNum
                  dispatch
                    type: 'SET_AUDIO_PLAY_STATE'
                    play_state: 'LOADING'
                    line_num: lineNum

            div
              className: 'utterance'
              onClick: (e) ->
                dispatch
                  type: 'SET_EXPANDED'
                  line_num: if line.expanded then null else lineNum
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
