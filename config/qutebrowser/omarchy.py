# Omarchy defaults for qutebrowser.
#
# This file is replaced on upgrade. Put your own settings in config.py, which
# sources this file and then loads anything you have changed with :set.

# Ads and trackers. "both" runs the Brave filter-list engine (python-adblock)
# alongside the hosts blocklist, so between them they cover requests that only
# one of the two knows about.
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://ublockorigin.github.io/uAssets/filters/filters.txt",
    "https://ublockorigin.github.io/uAssets/filters/privacy.txt",
]

# YouTube serves its video ads from the same hosts as the video itself, and
# qutebrowser's blocker only works at the network level -- it has no cosmetic
# filtering or scriptlet injection to strip them in the page. So no filter list
# will ever make YouTube ad-free here.
#
# Handing the URL to mpv does: yt-dlp resolves the stream directly, and the ad
# breaks are simply never part of it. ,m plays whatever page you are on, ,M
# lets you pick a link on the page first.
config.bind(",m", "spawn -d mpv --force-window=immediate {url}")
config.bind(",M", "hint links spawn -d mpv --force-window=immediate {hint-url}")
