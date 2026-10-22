# Mga Background

Ang bawat tema ay may kasamang sarili nitong hanay ng mga background, at maaari kang magdagdag ng sarili mong mga dagdag sa `~/.config/omarchy/backgrounds/[theme]`. Kung gusto mong magdagdag ng karagdagang larawan ng background sa, sabihin nating, tema na nord, ilagay mo lang ang file sa `~/.config/omarchy/backgrounds/nord`.

Pinakamadali mo itong magagawa sa pamamagitan ng pagpunta sa _I-install > Estilo > Background_ sa Menu ng Omarchy. Ilalabas niyon ang folder kung saan naka-imbak ang mga background para sa temang iyon. Pindutin ang `Super + Shift + F` para magsimula ng isa pang file manager, hanapin ang background mo, kopyahin ito papunta roon.  Ngayon ay isasama na ito sa mga pagpipiliang background na maaari mong pagpilian gamit ang `Super + Ctrl + Space`.

Ang mga background ay maaaring mga video pati na rin mga still. Maghulog ng file na `mp4`, `m4v`, `mov`, `webm`, `mkv`, o `avi` sa parehong folder at lalabas ito kasama ng mga larawan. Ang mga video ay pinapatugtog ng wallpaper engine na OWE. Dine-decode nito ang video nang isang beses para sa lahat ng monitor at pinapatugtog ang tunog nito sa pamamagitan ng default na output ng audio, at itinitigil nito ang playback tuwing walang makakakita nito. Ang lock screen ay gumuguhit ng parehong decode, naka-mute, sa pamamagitan ng OWE. Ang background na video ay kumukonsumo pa rin ng mas maraming kuryente kaysa sa still.

Ang mga tema ay maaaring magsama ng maikling intro para sa isang still na background. Para sa `backgrounds/road.webp`, ang tumutugmang video ay nakatira sa `backgrounds/intros/road.mp4`. Awtomatiko itong tumutugtog sa boot at kapag lumipat sa isang tema na napili ang background na iyon, pagkatapos ay bumabalik ito sa still. Ang mga video na intro ay hindi kasama sa tagapili ng background at hindi kailanman naglu-loop.

Ang pag-off sa _Mag-trigger > Hitsura > Animasyon_ ay nag-o-off din ng mga intro ng background. Ginagawa ito ng Omarchy bilang default sa isang virtual machine. Ang command na `omarchy theme bg intro toggle` ay maaaring mag-toggle ng mga intro nang hiwalay. Ang pag-refresh ng isang tema o pagpili ng ibang background sa loob ng parehong tema ay hindi nagpapatugtog ng intro.

Makakahanap ka ng napakalaking koleksyon ng magagandang piniling background sa https://github.com/dharmx/walls.

Ang mga background na video ay nagpapanatili ng naka-cache na still sa lock screen habang naka-pause o hindi available ang playback. Ang mga animated GIF ay tumutugtog sa desktop at nagpapakita ng still frame sa lock screen.
