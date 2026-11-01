# Networking

Ang networking sa Omarchy ay pinamamahalaan ng NetworkManager, at kinokontrol mo ito mula sa icon ng network sa [bar sa itaas](05-the-top-bar.md) o gamit ang `Super + Ctrl + N`.

Ini-scan ng panel na iyon ang mga Wi-Fi network, ipinapakita ang lakas ng signal, at kumokonekta. Wala ka nang kailangang gawin para sa Ethernet — ikabit mo lang at gagana na. Kung mas gusto mong manatili sa terminal, ibinibigay ng `nmtui` sa iyo ang parehong mga kontrol, at mayroon ding grupo ng utos na `omarchy network`.

## Pagbabahagi ng iyong Wi-Fi

Sa halip na basahin nang malakas ang isang mahabang password, patakbuhin ang _Setup > Network > QR Code_ habang naka-Wi-Fi ka. Maglalagay iyon ng QR code sa screen na maaaring i-scan ng anumang camera ng telepono para sumali. Isa iyon sa mga bagay na mas madalas mong gagamitin kaysa inaasahan mo kapag nalaman mong nandoon pala iyon.

Kung talagang kailangan mo mismo ang password, ipi-print ito ng `omarchy network password <interface>`.

## DNS

Ginagamit ng Omarchy ang anumang DNS na ibinibigay ng iyong network sa pamamagitan ng DHCP. Maaari mo itong palitan para sa buong makina sa ilalim ng _Setup > Network > DNS_, kung saan isang click lang ang layo ng Cloudflare at Google. Piliin ang _Custom_ para i-type ang sarili mong mga server.

Mula sa terminal, ipi-print ng `omarchy dns` ang kasalukuyang provider at itinatakda ng `omarchy dns Cloudflare` ang isa.

## Pag-pin sa band ng Wi-Fi

Kung inilalagay ng iyong router ang 2.4GHz, 5GHz, at 6GHz sa iisang pangalan ng network, minsan kakapit ang iyong laptop sa mabagal. Ipinapakita ng `omarchy network band` kung saang band ka naroon, at ipi-pin ito ng `omarchy network band 5`. Gamitin ang `auto` para hayaan itong pumili ulit.

Ipi-pin nito ang band sa halip na isang partikular na access point, kaya normal ka pa ring makakapag-roam sa pagitan ng mga AP.

## Gaano ito kabilis?

Sinusukat ng _Trigger > Speed Test > Network Speed Test_ ang aktuwal mong bilis pataas at pababa gamit ang isang pares ng dial. Mula sa terminal, ito ay `omarchy network speedtest down` o `up`. Sinusukat ito laban sa sariling serbisyo ng Omarchy at binibilang lamang ang mga test transfer nito. Maaaring makipagkumpitensya ang ibang mga download para sa bandwidth, pero hindi sila idinaragdag sa resulta ng speed test. (May disk speed test na katabi nito sa menu na iyon, kung bina-benchmark mo ang kabilang bottleneck.)

## Ang firewall

Naka-on ang firewall bilang default at hinaharangan nito ang lahat ng papasok na traffic, na may isang eksepsiyon: ang port 53317, para gumana agad ang [LocalSend](22-guis.md) nang wala nang kailangang ayusin.

Naka-off ang SSH hanggang buksan mo ito gamit ang _Setup > Security > SSHD_, na magsisimula sa daemon, magbubukas sa port 22 na may rate limit laban sa brute force, at mag-a-awtorisa ng isang key. Naka-lock down din ang Docker, kaya hindi aksidenteng mailalantad ng mga container ang kanilang sarili sa mundo. Tingnan ang [seguridad](48-security.md) para sa buong kuwento.

## Tailscale

Ang [Tailscale](https://tailscale.com/) ay isang mesh VPN na ginagawang simple at secure ang pag-abot sa lahat ng iyong mga computer at server sa internet. I-install ito gamit ang _Install > Service > Tailscale_.

Bibigyan ka niyan ng panel ng Tailscale sa bar, na kumokonekta at nagdi-disconnect sa tailnet, nagpapalit ng mga account, at pumipili ng exit node — lumalabas sa listahan ang sarili mong mga makina at ang mga rehiyon ng Mullvad. Bina-browse din nito ang iyong mga makina, at doon nakatira ang Taildrop: pumili ng makina at pindutin ang `s` para padalhan ito ng mga file, o ang `c`, `n`, at `d` para kopyahin ang IP, pangalan, o buong pangalan ng DNS nito. Ang katumbas nito sa terminal ay `omarchy tailscale send <machine> [file...]`, at awtomatikong dumarating sa `~/Downloads` ang mga file na ipinadala sa iyo. Ang notification na nag-aanunsyo ng pagdating ay naghihintay hanggang i-click mo itong buksan o i-dismiss, kaya ang isang file na dumating habang wala ka sa makina ay nandoon pa rin para sagutin pagbalik mo.

Nagdaragdag din ang pag-install nito ng web app para sa admin console ng Tailscale.

## Kapag tumigil itong gumana

Bago mag-reboot, subukang i-restart nang mag-isa ang pirasong nagkakaproblema. May Wi-Fi, Bluetooth, Audio, at Trackpad ang _Update > Hardware_, at ang pag-reload sa isa sa mga iyon ay nag-aayos sa karamihan ng mga sitwasyong "gumana ito limang minuto lang ang nakalipas". Tingnan ang [pag-troubleshoot](45-troubleshooting.md).
