#!/usr/bin/env python3
import pathlib
conf = pathlib.Path("/etc/mpv/mpv.conf")
is_nouveau = pathlib.Path("/sys/module/nouveau").exists()
conf.parent.mkdir(parents=True, exist_ok=True)
if is_nouveau:
    conf.write_text("hwdec=no\n# forced on nouveau, see GH #17210\n")
else:
    conf.write_text("hwdec=auto-safe\n")
