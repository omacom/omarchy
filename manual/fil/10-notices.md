# Mga Abiso

Dumarating ang mga notification sa kanang itaas na sulok ng naka-focus na display. Mabilis mo ring maa-access ang petsa at oras, status ng baterya, at kasalukuyang panahon gamit ang mga hotkey notice.

## Mga Notification

Nagsasalansan ang mga notification mula sa iisang app o site sa isang deck, kaya hindi maitutulak ng isang madaldal na Slack channel ang build failure mo palabas ng screen. I-hover ang isang deck para bumuka ito; walang bagong darating sa ilalim ng pointer mo habang nagbabasa ka. I-click ang isang card para pumunta sa pinanggalingan nito, i-right-click, i-middle-click, o pindutin ang ✕ para i-dismiss ito.

Inaalok ng mga card kung ano ang dala nila: _Kopyahin ang code_ para sa mga verification code (hindi isinasama sa [kasaysayan ng clipboard](08-unified-clipboard-history.md) at binubura pagkalipas ng isang minuto), pati anumang mga button na ibinibigay ng app. Nagbubukas ang mga link sa text ng isang notification kapag na-click.

Para gamitin ang mga ito nang walang mouse, pindutin ang `Super + Ctrl + ,`. Napili ang pinakabagong notification at nakabilang ang mga button nito: pindutin ang isang numero para gamitin ang isa, `Enter` para i-click ang notification, `↑` at `↓` para lumipat sa pagitan ng mga notification, `Delete` para mag-dismiss ng isa, at `Esc` para ibalik ang keyboard. Kusang bumibitaw din ito pagkalipas ng ilang segundong walang ginagawa.

Pinipigilan ng pagpapatahimik sa mga notification ang mga ito, maliban sa sariling mga kumpirmasyon ng Omarchy, mga emergency alert, at mga verification code, na hiniling mo kanina lang. Ibalik sa screen ang huling iilan, napigilan man o hindi, gamit ang `Super + Shift + Alt + ,`. Itinatago ang kasaysayan sa loob ng isang araw.

## Mga hotkey notice

### Petsa at Oras

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Panahon

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Natutukoy ang lokasyon mula sa iyong IP address, na karaniwang sapat na ang lapit, pero hindi palagi. Maaari mo itong itakda gamit ang `omarchy weather location --set Malibu`, o maging eksakto tungkol dito sa pamamagitan ng pagdaragdag ng mga coordinate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Patakbuhin ang `omarchy weather location` nang mag-isa para makita kung nasaan ka sa palagay nito, at `--clear` para bumalik sa auto-detection.

### Baterya

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
