React  = require 'react'

MenuComponent = React.createClass
  displayName: 'MenuComponent'
  render: ->
    { a, div, li } = React.DOM
    div
      style:
        fontSize: '30pt'
      li {},
        a
          href: '#/dialog'
          'Dialogs'
      li {},
        a
          href: '#/flashcard'
          'Flashcards'

module.exports = MenuComponent
