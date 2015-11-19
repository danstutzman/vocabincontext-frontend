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
            div
              className: 'gloss'
              if is_penultimate
                word[2] + words[words.length - 1][2]
              else
                word[2]
      word_divs.push div
        key: 'english'
        className: 'english'
        utterance.english
       
      utterances.push div
        className: "utterance #{side}"
        key: utterance_num
        word_divs

    div
      className: 'screen'
      div
        className: 'dialog'
        utterances

module.exports = DialogComponent
