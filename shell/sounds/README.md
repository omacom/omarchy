# Sound credits

`omakase-seasonal.wav` is **Omakase Seasonal**, shared by [marceloarruda01](https://github.com/marceloarruda01) in the [Omarchy startup sound discussion #6690](https://github.com/omacom/omarchy/discussions/6690#discussioncomment-17978085), with Amiga-inspired concepts following suggestions from bjarneo.

Source: [omakase_seasonal.mp3](https://github.com/user-attachments/files/30941251/omakase_seasonal.mp3).

The original MP3 was decoded to 16-bit PCM WAV for playback with `pw-play`, preserving its sample rate and channel count. No trimming, gain adjustment, or musical edits were applied. The output test controls its playback level separately.

Conversion:

```sh
ffmpeg -i omakase_seasonal.mp3 -map_metadata -1 -c:a pcm_s16le omakase-seasonal.wav
```
