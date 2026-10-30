# Mga Function ng Shell

May kasamang hanay ng mga function ng shell ang Omarchy para pasimplihin ang mga karaniwang gawain at i-encapsulate ang mga masalimuot na parameter call.

## Compression

- `compress [file/dir]`: Gumawa ng tar.gz archive mula sa file/dir.
- `decompress [file.tar.gz]`: Palawakin ang isang tar.gz file.

## Mga Drive

- `iso2sd [image.iso]`: Gumawa ng bootable drive sa isang SD card gamit ang tinukoy na iso file at pagpili ng drive nang interactive.
- `format-drive [device] [name]`: I-format ang isang buong disk na may iisang exFAT partition (na gumagana rin sa Windows at macOS). Patakbuhin ito nang walang argumento para makita ang mga available na drive. Mag-ingat!

## Mga layout para sa dev

Mga instant na multi-pane development layout para sa tmux:

- `tdl [ai]`: Gumawa ng Tmux Dev Layout na may editor mo, isang AI agent, at isang terminal. Gamitin ang mga agent alias, tulad ng `tdl c` para sa opencode o `tdl cx` para sa Claude Code, o magpasa ng pangalawang agent para patakbuhin ang dalawa, tulad ng `tdl c cx`.
- `tds`: Gumawa ng Tmux Dev Square na may editor, diff watching (sa pamamagitan ng `hunk diff --watch`), terminal, at opencode.
- `tdlm [ai]`: Gumawa ng `tdl` window para sa bawat subdirectory sa kasalukuyang direktoryo.
- `tsl [count] [command]`: Gumawa ng swarm ng mga pane na naka-tile sa isang grid, lahat tumatakbo ng parehong command (mahusay para sa mga AI agent).

Magagamit ang parehong mga layout para sa Herdr bilang `hdl`, `hds`, `hdlm`, at `hsl`.

## Mga Git worktree

- `ga [branch]`: Gumawa ng bagong worktree at branch sa tabi ng kasalukuyang repository at lumukso papasok dito.
- `gd`: Alisin ang kasalukuyang worktree at ang branch nito (humihingi muna ng kumpirmasyon).

## Mga Rsync watcher

- `rsw [source] [destination]`: Magsimula ng background watcher na nag-r-rsync ng source papunta sa destination tuwing may nagbabago. Maaaring remote host ang destination, tulad ng `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Ilista ang lahat ng aktibong watcher.
- `dsw`: Itigil ang lahat ng aktibong watcher.

## SSH Portforwarding

Ideal para sa paggawa ng web development na may localhost secure-context privileges laban sa isang remote box.

- `fip`: Mag-forward ng isa o higit pang port mula sa isang remote host papunta sa localhost sa pamamagitan ng SSH.
- `dip`: Idiskonekta ang isa o higit pang na-forward na port.
- `lip`: Ilista ang lahat ng aktibong SSH port forward.

Halimbawa, magsisimula ka ng dev server sa port `3000` sa isang makinang maa-access bilang `nyc-dev`, pagkatapos ay maaari mong patakbuhin ang `fip nyc-dev 3000` para i-forward ang port na iyon, kaya ang `localhost:3000` ay talagang nakakarating sa `nyc-dev:3000`, pero nang hindi kailangan ng SSL certificate para itatag ang secure context na kailangan para sa pagsubok ng mga web socket o katulad nito.

## SSH reconnection

Ang `ssh` mismo ay nakabalot sa isang function na naglilinis ng terminal kung mamamatay ang isang koneksyon habang inaangkin ito ng isang remote tmux, Herdr, o editor, at pagkatapos ay awtomatikong kumokonekta ulit kapag bumagsak ang isang interactive session (pinipigilan ng Ctrl-C ang retry loop).
