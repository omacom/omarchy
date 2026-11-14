# Ang Bar sa Itaas

Ang strip sa kahabaan ng itaas ng screen mo ay ang Omarchy bar. Hindi ito isang basta ikinabit na status bar kundi bahagi ng Omarchy shell, ang iisang matagal na tumatakbong proseso ng Quickshell na siyang gumuguhit din ng menu, ng mga notification, ng mga OSD popup, at ng lock screen. Kaya perpekto ang tema nito kasama ng lahat ng iba pa at kaya agad-agad bumubukas ang isang panel imbes na magbukas ng bagong app.

Ito rin ang nag-iisang bahagi ng desktop na palaging nasa screen, kaya sulit na malaman kung ano ang ginagawa ng lahat ng maliliit na glyph na iyon.

## Ano ang nandito bilang default

May tatlong seksyon ang bar. Sa kaliwa nakaupo ang logo ng Omarchy (ang launcher ng menu) at ang mga indicator ng workspace. Sa gitna, makukuha mo ang mga indicator ng status, ang orasan, ang Elsewhen (isang world clock), ang panahon, at isang badge ng update ng Omarchy. Sa kanan: ang system tray, ang layout ng keyboard (kapag higit sa isa ang naka-configure), mga agent, bluetooth, network, audio, display, at power.

Ilan sa mga iyon ay lumalabas lang kapag may sasabihin sila. Lumalabas lang ang layout ng keyboard kung higit sa isang layout ang na-configure mo. Lumalabas lang ang badge ng update kapag may naghihintay na update ng Omarchy. At lumalabas ang icon ng mga agent sa unang pagkakataong makahanap ang Omarchy ng paggamit ng AI coding sa machine (tingnan ang [AI](17-ai.md)).

## Pag-click kung saan-saan

Halos bawat widget ay may ginagawa sa left, right, at middle click, at marami ang tumutugon sa pag-scroll. Ito ang bahaging hindi napapansin ng mga tao — nasa right at middle button ang maraming magagandang bagay na nakatago.

| Widget | Kaliwa | Kanan | Gitna / scroll |
| --- | --- | --- | --- |
| Menu | Menu ng Omarchy | Bagong terminal | — |
| Workspaces | I-focus ang workspace na iyon sa monitor na ito | — | Scroll: susunod/nakaraang workspace |
| Clock | Popup ng kalendaryo | Palitan nang paikot ang format ng label | Gitna: tagapili ng timezone |
| Weather | Popup ng forecast | Buong panahon bilang isang notification | Gitna: i-refresh |
| Audio | Panel ng audio | I-mute | Gitna: panel · scroll: volume |
| Microphone | I-mute ang mic | — | Gitna: panel ng audio · scroll: volume ng input |
| Network | Panel ng network | — | — |
| Bluetooth | Panel ng Bluetooth | I-toggle ang radio | — |
| Display | Panel ng display | — | Scroll: brightness |
| Power | Panel ng power | I-toggle ang porsyento ng baterya | — |
| Media | I-play/i-pause | Popup ng cover-art | Gitna: susunod · scroll: nakaraan/susunod |
| Agents | Panel ng mga agent | Ilunsad ang agent mo | Gitna: susunod na subscription |
| Tray | I-hover para ipakita ang drawer | I-right-click ang chevron para pamahalaan | — |
| Omarchy update | Patakbuhin ang update | — | — |

Hindi lahat ng nasa talahanayang iyan ay nasa bar mo agad. Ang media widget (MPRIS na now-playing, na may nag-i-scroll na track at artist) at ang microphone widget ay parehong built-in pero naka-off bilang default — idagdag mo sila kung gusto mo, gaya ng inilalarawan sa ibaba.

## Ang mga panel

Ang pag-click sa isang icon ng bar ay nagbubukas ng isang panel, na isang tamang popup na may mga slider, listahan, at keyboard navigation imbes na isang tooltip. Bawat isa ay may hotkey din, kaya hindi mo kailanman kailangang tumutok sa isang glyph na 16-pixel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Kalendaryo |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | I-toggle ang ika-n na panel sa kanang seksyon |

Hindi mga readout lang ang mga panel. Dito mo talaga ginagawa ang bagay:

- **Audio** ay may master volume slider, isang tagapili ng output-device, at isang per-app mixer, kaya maaari mong hinaan ang isang tab ng browser na iyon nang hindi ginagalaw ang lahat ng iba pa.
- **Network** ay nag-i-scan ng Wi-Fi, nagpapakita ng lakas ng signal, kumokonekta, at hinahayaan kang pumili ng DNS provider.
- **Bluetooth** ay inililista ang mga device mo na may connect/disconnect at mga antas ng baterya.
- **Power** ay nagpapakita ng mga istatistika ng baterya, nagpapalit ng mga power profile (natatandaan nito ang magkahiwalay na pinili para sa baterya at AC), at nagpi-print ng ilang impormasyon ng system.
- **Display** ay may slider ng brightness, laki ng text, mga preset ng scaling ng monitor, at — kapag higit sa isa ang screen mo — mga kontrol para sa bawat monitor. Tingnan ang [mga monitor](33-monitors.md) para sa mas malalim na kuwento.
- **Clock** ay nagbubukas ng grid ng buwan na may mga numero ng linggo ayon sa ISO at paghakbang sa buwan.
- **World clock** ay may isang row para sa bawat lungsod, kasama ang panahon nito at kung kumusta ang takbo ng araw nito. Nakakahanap ang search ng mga bayan pati na rin ng mga time zone, kaya ang Fort Lauderdale ay Fort Lauderdale at hindi New York. Kung maling lungsod ang pinapangalanan ng linya sa itaas, i-click ito at sabihin kung nasaan ka; pumili ka sa ibang time zone at lilipat din doon ang system clock, na madaling gamitin kapag naglalakbay ka. I-hover ang isang lungsod at i-click ang button ng tao para sabihin kung sino ang nakatira roon — mga simpleng pangalan, o mga `@` GitHub handle para isama ang kanilang mga mukha.

Bawat panel ay tumatanggap ng keyboard pati ng mouse: gumagalaw ang mga arrow, nag-a-activate ang Return, humahakbang ang Tab papunta sa katabing panel, at nagsasara ang Escape.

Binibilang ng `Super + Ctrl + 1-9` ang mga panel mula kaliwa papuntang kanan sa kanang seksyon, nilalaktawan ang tray dahil wala itong sariling panel. Kaya tumutugma ang numero sa icon na ituturo mo.

### Tailscale at Dropbox

Dalawa pang widget ang lumalabas sa bar kapag na-install mo lang ang katugmang serbisyo mula sa **Install → Service**, at parehong sulit malaman dahil higit pa sa pag-uulat ng status ang ginagawa nila.

Kinokonekta at dinidiskonekta ng **Tailscale** panel ang tailnet, nagpapalit sa pagitan ng mga account, at pumipili ng exit node (lumalabas sa listahang iyon ang sarili mong mga machine at ang mga rehiyon ng Mullvad). Bine-browse din nito ang mga machine mo — at kapag may napili na, nagpapadala ang `s` ng mga file papunta rito sa pamamagitan ng Taildrop, na siyang pinakamabilis na paraan para maglipat ng file papunta sa phone mo o sa ibang laptop. Kinokopya ng `c` ang IP ng machine, ng `n` ang pangalan nito, at ng `d` ang buong DNS name nito. May send button din sa bawat row ng machine, kung mas gusto mong mag-click. Ang katumbas nito mula sa terminal ay `omarchy tailscale send <machine> [file...]`.

Ang **Dropbox** panel ang humahawak sa login, nagpapakita kung gaano karaming storage ang nagamit mo na, at naglilista ng mga kamakailang na-sync na file.

Ang pag-aalis sa alinman sa serbisyo ay magtatanggal muli ng widget nito mula sa bar.

## Mga Indicator

Ang maliit na kumpol sa gitna ay ang indicators widget. Mga glyph ito ng status para sa mga mode na in-on mo: do not disturb, night light, isang nakapilang [paalala](09-reminders.md), isang aktibong pag-record ng screen, stay awake, at [diktasyon](11-text-extraction-dictation.md). Umiilaw sila kapag aktibo ang mode at kung hindi ay hindi sila nakaharang — i-hover lang sa tabi nila, kung saan uupo ang mga hindi aktibo, para sumilip sa mga iyon. Ang pag-click sa isang indicator ay nagto-toggle sa mode na iyon. Isa pa ang para lang sa status: umiilaw nang pula ang isang remote session habang may nakakonekta sa machine na ito sa pamamagitan ng gliff.

Kung mas gusto mong palagi silang nakikita, itakda ang `alwaysShow` sa `true` sa widget. At kung ilan lang sa kanila ang mahalaga sa iyo, ilista ang mga gusto mo sa `items`: `["Dnd", "Reminder", "NightLight"]`. Maaari kang magkaroon ng higit sa isang indicators widget, kaya maaaring magpakita ng iba't ibang subset ang iba't ibang seksyon.

## Muling pag-aayos ng bar

Ang bar ang nagko-configure sa sarili nito. Hindi mo kailangang magbukas ng config file para ilipat ang mga bagay.

Humawak sa isang bakanteng bahagi ng bar sa paligid ng gitna at i-drag ito papunta sa ibang gilid ng screen, at lilipat doon ang bar — gumagana ang kaliwa, kanan, itaas, o ibaba, at umaangkop ang bawat widget (bumabalik ang mga vertical bar sa mga compact na anyong icon-only). Ang click-and-hold ang nagsisimula ng parehong pag-drag. I-double-left-click ang parehong bakanteng espasyo para paikutin ang background ng bar mula clear papuntang glassy papuntang opaque. At i-drag ang anumang widget para muling ayusin ito o ihagis ito sa ibang seksyon; magkakahiwalay na dumudulas ang ibang mga widget para magbigay ng lugar kung saan ito lalapag.

Ang gitna ng bar ay isang box: anuman ang nasa loob nito ay nananatiling nakasentro bilang isang grupo, at ang mga widget sa alinmang panig nito ay nakasabit sa mga gilid nito. Habang nagda-drag ka ng widget, lumalabas ang box bilang isang outline, o isang linya sa kahabaan ng bar kapag wala itong laman, at maaari kang maghulog sa loob nito o sa tabi nito. Kapag sa box lalapag ang isang hulog, lumalaki ang box para tanggapin ang widget.

Ang isang widget na gusto mong nasa paligid pero hindi palaging nakikita ay maaaring pumasok sa drawer ng tray: i-drag ito papunta sa tray, at bubukas ang drawer para tanggapin ito. Nakaupo ito roon pagkatapos ng mga icon ng app, lumalabas tuwing lumalabas ang drawer, at pinananatiling bukas ang drawer nito habang nakataas ang panel nito. I-drag ito pabalik palabas papunta sa bar para ibalik ito.

Kung mas gusto mong pumili mula sa isang menu, nasa **Appearance → Menu Bar** ang posisyon, at pinipili ng **Bar Background** kung paano iginuguhit ang bar: **Opaque Bar**, **Glassy Bar** (see-through, na blurred ang nasa likod nito), o **Clear Bar**.

May mga command din ang parehong mga bagay, na siyang gusto mo para sa isang setup ng [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para magdagdag o mag-alis ng widget nang buo, gamitin ang mga command ng plugin. Ini-print ng `omarchy plugin list` ang bawat widget na alam ng shell kasama ang id nito, at pagkatapos:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Pagtatago ng bar

`Super + Shift + Space` ang nagto-toggle ng bar off at pabalik on nang hindi pinapatay ang shell — patuloy na gumagana ang mga panel at hotkey, makukuha mo lang pabalik ang mga pixel. Nasa menu din ito sa ilalim ng **Appearance → Menu Bar → Hide Bar**.

## Ang config file

Lahat ng ito ay nakaimbak sa `~/.config/omarchy/shell.json`, sa ilalim ng `bar` key. Narito ang isang pinaikling bersyon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Bawat widget ay isang entry sa isa sa limang array ng layout, at ang mga setting nito ay nasa inline sa entry na iyon — walang hiwalay na file ng mga setting at walang sub-object na `config`. Ang `format`, `formatAlt` ng orasan (kung ano ang pinapalitan nang paikot ng right-click), at `verticalFormat` ay naroon lahat mismo sa `{ "id": "omarchy.clock" }`.

`center` ang box sa gitna ng bar: lahat ng nasa loob nito ay nakasentro sa screen bilang isang grupo. Nakasabit ang `centerBegin` at `centerEnd` sa alinmang panig ng box, na siyang paraan kung paano nananatiling nasa pinakagitna ang orasan kahit pa dumarating at umaalis ang panahon at ang badge ng update. Maglagay ng higit sa isang widget sa `center` at magkakasama silang isesentro; iwan itong walang laman at magkikita ang `centerBegin` at `centerEnd` sa gitna ng bar.

Isang panuntunang sulit na isaisip: **kapag mayroon ka nang sarili mong `shell.json`, ito na ang canonical**. Hanggang wala ka pang kino-customize, binabasa ng shell ang default file ng Omarchy. Sa sandaling mag-drag ka ng widget, magpatakbo ng `omarchy bar`, o ikaw mismo ang mag-edit ng file, sa iyo na ito — walang deep merge, kaya hindi awtomatikong lalabas sa bar mo ang mga bagong default widget sa mga darating na release ng Omarchy. Ibinabalik ng `omarchy bar defaults` ang inilabas na layout tuwing gusto mo ng malinis na panimula.

Ang parehong file ay naglalaman din ng mga timing mo sa idle sa top level, sa labas ng `bar` key: `idle.screensaver` at `idle.lock`, parehong sa segundo mula nang maging idle ka. Kaya sumasipa ang default screensaver sa 150 segundo at ang lock sa 300.
