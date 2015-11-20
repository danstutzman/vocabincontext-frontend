React  = require 'react'
dialog = require './dialog.js'

DialogComponent = React.createClass
  displayName: 'DialogComponent'
  render: ->
    { div } = React.DOM

    utterances = []
    for utterance, utterance_num in dialog
      words = utterance.gloss_table
      side = (if utterance.speaker_num == 1 then 'left' else 'right')
      is_selected = (utterance_num == @props.selected_utterance_num)

      word_divs = []
      for word, word_num in utterance.gloss_table
        if word_num < words.length - 1
          is_penultimate = (word_num == words.length - 2)
          word_divs.push div
            key: word_num
            className: "word" + (if is_penultimate then ' last' else '')
            div
              className: 'pinyin'
              if is_penultimate
                word[1] + words[words.length - 1][1]
              else
                word[1]
            if is_selected
              div
                className: 'gloss'
                if is_penultimate
                  word[2] + words[words.length - 1][2]
                else
                  word[2]
      if is_selected
        word_divs.push div
          key: 'english'
          className: 'english'
          utterance.english
       
      utterances.push div
        key: utterance_num
        'data-utterance-num': utterance_num
        className: "utterance #{side} #{if is_selected then 'selected' else ''}"
        onMouseEnter: do (utterance_num) => (e) =>
          @props.dispatch e, type: 'SELECT_UTTERANCE', utterance_num: utterance_num
        word_divs

    find_utterance = (e) =>
      element = document.elementFromPoint(e.touches[0].pageX, e.touches[0].pageY)
      while element.getAttribute
        utterance_num = element.getAttribute('data-utterance-num')
        if utterance_num
          @props.dispatch e,
            type: 'SELECT_UTTERANCE',
            utterance_num: parseInt(utterance_num)
          break
        element = element.parentNode

    div
      className: 'screen'
      onTouchStart: find_utterance
      onTouchMove: find_utterance
      div
        style:
          fontSize: '30pt'
        onClick: (e) =>
          @props.dispatch e,
            type: 'DIALOG/SET_PAUSED',
            new_paused: not @props.paused
        if @props.paused
          'PLAY ALL'
        else
          'PAUSE ALL'
      div
        className: 'dialog'
        utterances

module.exports = DialogComponent
