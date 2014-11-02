import game
import screen

#

type
  MyScreen* = ref object of Screen


#

method Resize(screen: MyScreen) =
  echo "Resize MyScreen"


##

var testScreen = MyScreen()
testScreen.Resize()

#echo("Screen: ", testScreen)
