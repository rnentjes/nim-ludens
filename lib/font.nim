import csfml as sfml

import game

type
  Font* = ref object
    font: PFont
    color: TColor

proc createFont*(fontname: string, color: TColor = color(255, 255, 255)): Font =
  result = Font()
  result.font = newFont(fontname)
  result.color = color

proc Dispose*(font: Font) =
  font.font.destroy()

proc SetColor*(font: Font, color: TColor) =
  font.color = color

proc DrawCentered*(font: Font, txt: string, size: int, x,y: float) =
  var text = newText(txt, font.font, size)

  var width = text.getGlobalBounds().width
  var height = text.getGlobalBounds().height

  text.setColor(font.color)
  text.setPosition(vec2f(x - width / 2, y - height / 2))

  ludens.window.resetGlStates()
  ludens.window.setView(ludens.textview)
  ludens.window.draw(text)

  text.destroy()


proc DrawLeft*(font: Font, txt: string, size: int, x,y: float) =
  var text = newText(txt, font.font, size)

  var height = text.getGlobalBounds().height

  text.setColor(font.color)
  text.setPosition(vec2f(x, y - height / 2))

  ludens.window.resetGlStates()
  ludens.window.setView(ludens.textview)
  ludens.window.draw(text)

  text.destroy()


proc DrawRight*(font: Font, txt: string, size: int, x,y: float) =
  var text = newText(txt, font.font, size)

  var width = text.getGlobalBounds().width
  var height = text.getGlobalBounds().height

  text.setColor(font.color)
  text.setPosition(vec2f(x - width, y - height / 2))

  ludens.window.resetGlStates()
  ludens.window.setView(ludens.textview)
  ludens.window.draw(text)

  text.destroy()
