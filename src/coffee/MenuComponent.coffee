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
          href: '#'
          onClick: (e) => @props.dispatch e,
            type: 'MENU_CHOICE'
            new_current_screen: 'DialogComponent'
          'Dialogs'
      li {},
        a
          href: '#'
          onClick: (e) => @props.dispatch e,
            type: 'MENU_CHOICE'
            new_current_screen: 'FlashcardComponent'
          'Flashcards'

module.exports = MenuComponent
