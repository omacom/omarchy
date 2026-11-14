echo "Install the GStreamer plugins Nautilus and Sushi need for MP4 and MP3"

# Of GStreamer, Sushi and Nautilus pull in only gst-plugins-base-libs, so no MP4
# or ID3 demuxer and no H.264 or AAC decoder, and previews and media details fail.
omarchy-pkg-add gst-plugins-good gst-libav
