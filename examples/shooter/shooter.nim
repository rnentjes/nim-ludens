import csfml
import opengl as gl
import math

import screen
import game
import texture

import "screen/splash"

#

var shooter = game.create(startScreen = splash.create(), width = 600, height = 900)
shooter.SetClearColor(color(40, 40, 40))
shooter.SetOrthoHeight(900'f32)
shooter.Run()
