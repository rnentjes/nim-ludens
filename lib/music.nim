# SoundHandler
#
# var music = createMusic()
# music.Load("sounds/bleepbleep.ogg")
# music.Play()
# music.Stop()
#

import csfml_audio as audio

# Music

type
  Music* = ref object of TObject
    song: PMusic


method Load*(mus: Music, songname: string) =
  if mus.song != nil:
    mus.song.destroy()

  mus.song = newMusic(songname)


method Play*(mus: Music) =
  mus.song.play()

method Pause*(mus: Music) =
  mus.song.pause()

method Stop*(mus: Music) =
  mus.song.stop()


method Dispose*(mus: Music) =
  if mus.song != nil:
    mus.song.destroy()

proc createMusic*(): Music =
    result = Music()

proc createMusic*(songname: string): Music =
    result = Music()
    result.Load(songname)

