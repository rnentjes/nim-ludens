# Screen

type
  Screen* = ref object of TObject

method Init*(screen: Screen) =
  discard

method Resize*(screen: Screen, width: int, height: int) =
  echo "Resize Screen"

method Render*(screen: Screen, delta: float32) =
  discard

method Dispose*(screen: Screen) =
  discard

