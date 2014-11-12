import screen
import game

import screen/splash as splash

#

var shooter = game.create(startScreen = splash.createSplash(),
                          title = "Nimvaders!",
                          vsync = true,
                          fullscreen = false,
                          width = 600,
                          height = 900)

shooter.SetClearColor(0.16'f32, 0.16'f32, 0.16'f32)
shooter.SetOrthoHeight(900'f32)
shooter.Run()
