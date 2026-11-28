# Mga Paunawa

Dumarating ang mga abiso sa kanang itaas na sulok ng naka-focus na display. Mabilis mo ring matingnan ang petsa at oras, katayuan ng baterya, at kasalukuyang panahon gamit ang mga hotkey notice.

## Mga Abiso

Nagsasalansan bilang isang deck ang mga abiso mula sa iisang app o site, kaya hindi itataboy palabas ng screen ng isang madaldal na Slack channel ang iyong build failure. I-hover ang isang deck para buksan ito na parang pamaypay; walang bagong dadulas sa ilalim ng iyong pointer habang nagbabasa ka. I-click ang isang card para pumunta kung saan ito nanggaling, i-right-click, i-middle-click, o pindutin ang ✕ para i-dismiss ito.

Inaalok ng mga card kung ano ang dala nila: _Kopyahin ang code_ para sa mga verification code (hindi isinasama sa [kasaysayan ng clipboard](08-unified-clipboard-history.md) at binubura pagkalipas ng isang minuto), pati na ang anumang button na ibinibigay ng app. Nagbubukas ang mga link sa teksto ng isang abiso kapag na-click ang mga ito.

Ang `Super + ,` ang nagdi-dismiss sa pinakabagong abiso, o nagbubukas sa itinuturo nito kapag iniaalok nito iyon, ang `Super + Alt + ,` ay nagdi-dismiss lamang sa huli, ang `Super + Shift + ,` ay nagdi-dismiss sa lahat ng mga ito, at ang `Super + Shift + Alt + ,` ay nagbubukas sa kasaysayan. Para gamitin ang mga ito nang walang mouse, pindutin ang `Super + Ctrl + ,`. Napili ang pinakabagong abiso at nakabilang ang mga button nito: pindutin ang isang numero para gamitin ang isa, `Enter` para i-click ang abiso, `↑` at `↓` para lumipat-lipat sa mga abiso, `Delete` para mag-dismiss ng isa, at `Esc` para ibalik ang keyboard. Kusa rin itong bumibitaw pagkalipas ng ilang segundong walang ginagawa.

Pinipigilan ng pagtatahimik sa mga abiso ang mga ito, maliban sa sariling mga kumpirmasyon ng Omarchy, mga emergency alert, at mga verification code, na hiniling mo pa lang kanina. Ibalik sa screen ang ilan sa mga huli, napigilan man o hindi, gamit ang `Super + Shift + Alt + ,`. Pinapanatili ang kasaysayan sa loob ng isang araw.

## Mga paunawa sa hotkey

### Petsa at Oras

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Panahon

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Natutukoy ang lokasyon mula sa iyong IP address, na karaniwang sapat nang malapit, pero hindi palagi. Maaari mo itong tiyakin gamit ang `omarchy weather location --set Malibu`, o maging eksakto tungkol dito sa pamamagitan ng pagdaragdag ng mga coordinate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Patakbuhin ang `omarchy weather location` nang mag-isa para makita kung nasaan ka sa tingin nito, at `--clear` para bumalik sa auto-detection.

### Baterya

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
