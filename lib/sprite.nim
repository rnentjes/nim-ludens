
type
  Sprite* = ref object of TObject
    x,y,dx,dy: float32
    scale,angle: float32
    dead: bool

proc createSprite*(x,y,dx,dy: float32): Sprite =
  result = Sprite(x: x, y: y, dx: dx, dy: dy, dead: false)
  result.scale = 1'f32
  result.angle = 0'f32

proc X*(sprite: Sprite): float32 =
  result = sprite.x

proc X*(sprite: Sprite, x: float32) =
  sprite.x = x

proc Y*(sprite: Sprite): float32 =
  result = sprite.y

proc Y*(sprite: Sprite, y:float32) =
  sprite.y = y

proc Scale*(sprite: Sprite, scale: float32) =
  sprite.scale = scale

proc Scale*(sprite: Sprite): float32 =
  result = sprite.scale

proc Angle*(sprite: Sprite, angle: float32) =
  sprite.angle = angle

proc Angle*(sprite: Sprite): float32 =
  result = sprite.angle

proc Update*(sprite: Sprite, delta: float32) =
  sprite.x += sprite.dx * delta
  sprite.y += sprite.dy * delta

proc Died*(sprite: Sprite) =
  sprite.dead = true

proc Dead*(sprite: Sprite): bool =
 result = sprite.dead

