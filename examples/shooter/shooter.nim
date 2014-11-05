import src/glfw3 as glfw
import opengl as gl
import math

import screen
import game
import texture

import "screen/splash"

#

var shooter = game.create(startScreen = splash.create())
shooter.SetOrthoHeight(10'f32)
shooter.Run()
