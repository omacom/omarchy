# Mga Background

Bawat tema ay may kasama nang sariling set ng mga background, at maaari kang magdagdag ng sarili mong mga extra sa `~/.config/omarchy/backgrounds/[theme]`. Kung gusto mong magdagdag ng extra na background image sa, halimbawa, ang nord na tema, ilagay mo lang ang file sa `~/.config/omarchy/backgrounds/nord`.

Pinakamadali itong gawin sa pamamagitan ng pagpunta sa _Install > Style > Background_ sa Omarchy Menu. Bubuksan nito ang folder kung saan nakaimbak ang mga background para sa temang iyon. Pindutin ang `Super + Shift + F` para magbukas ng isa pang file manager, hanapin ang background mo, at kopyahin ito papunta roon. Kasama na ito ngayon sa mga pagpipiliang background na maaari mong pagpilian gamit ang `Super + Ctrl + W`.

Maaari ring maging mga video ang mga background bukod sa mga still. Maglagay ng `mp4`, `m4v`, `mov`, `webm`, `mkv`, o `avi` na file sa parehong folder at lalabas ito kasama ng mga image. Pinapatugtog ang mga video ng OWE wallpaper engine. Minsan lang nito dine-decode ang video para sa lahat ng monitor at pinapatugtog ang tunog nito sa pamamagitan ng default na audio output, at itinitigil nito ang playback tuwing walang nakakakita rito. Mas malaki pa rin nang malaki ang konsumo ng kuryente ng isang video wallpaper kaysa sa isang still.

Maaaring magsama ang mga tema ng maikling intro para sa isang still na background. Para sa `backgrounds/road.webp`, ang katugmang video ay nasa `backgrounds/intros/road.mp4`. Awtomatiko itong tumutugtog sa boot at kapag lumilipat sa isang temang nakapili ang background na iyon, pagkatapos ay babalik ito sa still. Hindi lumalabas ang mga intro video sa background picker at hindi kailanman naglu-loop ang mga ito.

Ang pag-off sa _Appearance > Animations_ ay nag-o-off din sa mga background intro. Awtomatiko itong ginagawa ng Omarchy sa isang virtual machine. Maaaring i-toggle nang hiwalay ng `omarchy theme bg intro toggle` na command ang mga intro. Ang pag-refresh ng isang tema o pagpili ng ibang background sa loob ng parehong tema ay hindi nagpapatugtog ng intro.

Makakahanap ka ng napakalaking koleksyon ng magagandang curated na background sa [dharmx/walls](https://github.com/dharmx/walls).

Nagpapakita ang lock screen ng still frame ng isang video background, sa parehong paraan kung paano ito nagpapakita ng still frame ng isang animated na GIF.
