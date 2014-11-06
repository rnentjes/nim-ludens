import csfml as sfml

# Screen

type
  Screen* = ref object of TObject
    window*: sfml.PRenderWindow
    textview*: sfml.PView

method Init*(screen: Screen) =
  discard

method Update*(screen: Screen, delta: float32) =
  discard

method Render*(screen: Screen) =
  discard

method Dispose*(screen: Screen) =
  discard

method KeyDown*(screen: Screen, key: TKeyCode) =
  discard

method KeyUp*(screen: Screen, key: TKeyCode) =
  discard

method KeyRepeat*(screen: Screen, key: TKeyCode) =
  discard

proc DrawText*(screen: Screen, text: Ptext) =
  screen.window.resetGlStates()
  screen.window.setView(screen.textview)
  screen.window.draw(text)
  #screen.window.setView(game.window.getDefaultView())
