
type
  Sprite* = ref object of TObject
    x,y,dx,dy: float32
    dead: bool

proc createSprite*(x,y,dx,dy: float32): Sprite =
  result = Sprite(x: x, y: y, dx: dx, dy: dy, dead: false)

proc X*(sprite: Sprite): float32 =
  result = sprite.x

proc X*(sprite: Sprite, x: float32) =
  sprite.x = x

proc Y*(sprite: Sprite): float32 =
  result = sprite.y

proc Y*(sprite: Sprite, y:float32) =
  sprite.y = y

proc Update*(sprite: Sprite, delta: float32) =
  sprite.x += sprite.dx * delta
  sprite.y += sprite.dy * delta

proc Died*(sprite: Sprite) =
  sprite.dead = true

proc Dead*(sprite: Sprite): bool =
 result = sprite.dead

