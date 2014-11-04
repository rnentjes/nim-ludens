# Screen

type
  Screen* = ref object of TObject

method Init*(screen: Screen) =
  discard

method Resize*(screen: Screen, width: int, height: int) =
  echo "Resize Screen"

method Update*(screen: Screen, delta: float32) =
  discard

method Render*(screen: Screen) =
  discard

method Dispose*(screen: Screen) =
  discard

method KeyDown*(screen: Screen, key, scancode, mods: int) =
  discard

method KeyUp*(screen: Screen, key, scancode, mods: int) =
  discard

method KeyRepeat*(screen: Screen, key, scancode, mods: int) =
  discard

