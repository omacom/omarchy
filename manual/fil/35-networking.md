# Networking

Ang networking sa Omarchy ay pinamamahalaan ng NetworkManager, at pinapatakbo mo ito mula sa icon ng network sa [bar sa itaas](05-the-top-bar.md) o gamit ang `Super + Ctrl + W`.

Ang panel na iyon ay nag-i-scan ng mga Wi-Fi network, nagpapakita ng lakas ng signal, at kumokonekta. Walang kailangang gawin para sa Ethernet — isaksak mo lang ito at gagana na. Kung mas gusto mong manatili sa terminal, ang `nmtui` ay nagbibigay sa iyo ng parehong mga kontrol, at may grupong command na `omarchy network` din.

## Pagbabahagi ng iyong Wi-Fi

Imbes na basahin nang malakas ang isang mahabang password, patakbuhin ang _Pag-setup > Network > QR Code_ habang nasa Wi-Fi ka. Naglalagay iyon ng QR code sa screen na maaaring i-scan ng anumang camera ng telepono para sumali. Isa iyon sa mga bagay na gagamitin mo nang mas madalas kaysa inaakala mo kapag nalaman mong nandiyan pala iyon.

Kung talagang kailangan mo ang password mismo, ipi-print ito ng `omarchy network password <interface>`.

## DNS

Ginagamit ng Omarchy ang anumang DNS na ibinibigay ng network mo sa pamamagitan ng DHCP. Maaari mo itong i-override para sa buong makina sa ilalim ng _Pag-setup > Network > DNS_, kung saan isang click na lang ang layo ng Cloudflare at Google. Piliin ang _Pasadya_ para i-type ang sarili mong mga server.

Mula sa terminal, ipi-print ng `omarchy dns` ang kasalukuyang provider at ang `omarchy dns Cloudflare` ay nagtatakda ng isa.

## Pag-pin sa banda ng Wi-Fi

Kung inilalagay ng router mo ang 2.4GHz, 5GHz, at 6GHz sa iisang pangalan ng network, kung minsan ay kakapit ang laptop mo sa mabagal na banda. Ipinapakita ng `omarchy network band` kung saang banda ka naroroon, at ini-pin ito ng `omarchy network band 5`. Gamitin ang `auto` para hayaan itong mamili ulit.

Inipi-pin nito ang banda imbes na isang partikular na access point, kaya patuloy kang makakapag-roam sa pagitan ng mga AP nang normal.

## Gaano ito kabilis?

Sinusukat ng _Mag-trigger > Test ng Bilis > Test ng Bilis ng Network_ ang tunay mong bilis ng upload at download gamit ang isang pares ng dial. Mula sa terminal ay `omarchy network speedtest down` o `up`. (May test ng bilis ng disk na katabi nito sa menu na iyon, kung bine-benchmark mo ang kabilang bottleneck.)

## Ang firewall

Naka-on ang firewall bilang default at hinaharangan nito ang lahat ng paparating na trapiko, maliban sa isa: ang port 53317, kaya gumagana agad ang [LocalSend](22-guis.md).

Naka-off ang SSH hanggang sa i-on mo ito gamit ang _Pag-setup > Seguridad > SSHD_, na nagsisimula ng daemon, nagbubukas ng port 22 na naka-rate-limit laban sa brute force, at nag-aawtorisa ng isang key. Naka-lock down din ang Docker, kaya hindi aksidenteng mailantad ng mga container ang sarili nila sa mundo. Tingnan ang [seguridad](48-security.md) para sa buong kuwento.

## Tailscale

Ang [Tailscale](https://tailscale.com/) ay isang mesh VPN na nagpapadali at nagpapasiguro sa pag-abot sa lahat ng computer at server mo sa internet. I-install ito gamit ang _I-install > Serbisyo > Tailscale_.

Nagbibigay iyon sa iyo ng panel ng Tailscale sa bar, na kumokonekta at nagdidiskonekta sa tailnet, nagpapalit ng account, at pumipili ng exit node — lumalabas sa listahan ang sarili mong mga makina at ang mga rehiyon ng Mullvad. Bina-browse din nito ang mga makina mo, at doon nakatira ang Taildrop: pumili ng makina at pindutin ang `s` para padalhan ito ng mga file, o ang `c`, `n`, at `d` para kopyahin ang IP nito, pangalan, o buong pangalan ng DNS. Ang katumbas nito sa terminal ay `omarchy tailscale send <machine> [file...]`, at ang mga file na ipinadala sa iyo ay awtomatikong dumarating sa `~/Downloads`. Ang notipikasyong nag-aanunsyo ng pagdating ay naghihintay hanggang sa i-click mo itong buksan o i-dismiss ito, kaya ang file na dumating habang wala ka sa makina ay nandiyan pa rin para sagutin pagbalik mo.

Ang pag-install nito ay nagdaragdag din ng web app para sa admin console ng Tailscale.

## Kapag tumigil itong gumana

Bago mag-reboot, subukang i-restart nang mag-isa ang sangkap na may sala. Ang _I-update > Hardware_ ay may Wi-Fi, Bluetooth, Audio, at Trackpad, at ang pag-reload ng isa sa mga iyon ay nag-aayos ng karamihan ng mga sitwasyong "gumana pa ito limang minuto ang nakalipas". Tingnan ang [pag-troubleshoot](45-troubleshooting.md).
