# Ang Bar sa Itaas

Ang strip sa tuktok ng screen mo ay ang Omarchy bar. Hindi ito isang bolted-on na status bar kundi bahagi ng Omarchy shell, ang iisang matagal nang tumatakbong proseso ng Quickshell na gumuguhit din ng menu, mga notification, mga OSD popup, at lock screen. Kaya perpekto itong tumutugma sa tema ng lahat ng iba pa at kaya agad nagbubukas ang isang panel imbes na maglunsad ng bagong app.

Ito rin ang iisang bahagi ng desktop na laging nasa screen, kaya sulit alamin kung ano ang ginagawa ng lahat ng maliliit na glyph na iyon.

## Ano ang nasa ibabaw nito bilang default

May tatlong seksyon ang bar. Sa kaliwa naroon ang logo ng Omarchy (ang launcher ng menu) at mga indicator ng workspace. Sa gitna makukuha mo ang mga indicator ng status, ang orasan, ang Elsewhen (isang world clock), ang panahon, at isang badge ng update ng Omarchy. Sa kanan: ang system tray, ang layout ng keyboard (kapag higit sa isa ang naka-configure), agents, bluetooth, network, audio, display, at power.

Ilan sa mga iyon ay lumalabas lang kapag may sasabihin sila. Lumalabas lang ang layout ng keyboard kung higit sa isang layout ang na-configure mo. Lumalabas lang ang badge ng update kapag may update ng Omarchy na naghihintay. At lumalabas ang icon ng agents sa unang pagkakataong makakita ang Omarchy ng paggamit ng AI coding sa machine (tingnan ang [AI](17-ai.md)).

## Pag-click sa paligid

Halos bawat widget ay may ginagawa sa left, right, at middle click, at ilan ay tumutugon sa pag-scroll. Ito ang bahaging hindi napapansin ng mga tao — nasa right at middle button ang marami sa magagandang bagay na nakatago.

| Widget | Kaliwa | Kanan | Gitna / scroll |
| --- | --- | --- | --- |
| Menu | Menu ng Omarchy | Bagong terminal | — |
| Workspaces | Ituon sa workspace na iyon sa monitor na ito | — | Scroll: susunod/nakaraang workspace |
| Clock | Popup ng kalendaryo | I-cycle ang format ng label | Gitna: tagapili ng timezone |
| Weather | Popup ng forecast | Buong panahon bilang notification | Gitna: i-refresh |
| Audio | Panel ng audio | I-mute | Gitna: panel · scroll: volume |
| Microphone | I-mute ang mic | — | Gitna: panel ng audio · scroll: input volume |
| Network | Panel ng network | — | — |
| Bluetooth | Panel ng Bluetooth | I-toggle ang radio | — |
| Display | Panel ng display | — | Scroll: brightness |
| Power | Panel ng power | I-toggle ang porsyento ng baterya | — |
| Media | Play/pause | Popup ng cover-art | Gitna: susunod · scroll: nakaraan/susunod |
| Agents | Panel ng Agents | Ilunsad ang agent mo | Gitna: susunod na subscription |
| Tray | I-hover para ipakita ang drawer | Mag-right click sa chevron para pamahalaan | — |
| Omarchy update | Patakbuhin ang update | — | — |

Hindi lahat ng nasa talahanayang iyon ay nasa bar mo agad. Ang media widget (MPRIS now-playing, na may nag-i-scroll na track at artist) at ang microphone widget ay parehong built in pero naka-off bilang default — idagdag mo sila kung gusto mo, gaya ng inilarawan sa ibaba.

## Ang mga panel

Ang pag-click sa icon ng bar ay nagbubukas ng panel, na isang tamang popup na may mga slider, listahan, at keyboard navigation imbes na isang tooltip. Bawat isa ay may hotkey din, kaya hindi mo kailangang tumutok sa isang 16-pixel na glyph:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | I-toggle ang ika-nth na panel sa right section |

Hindi mga read-out lamang ang mga panel. Doon mo talaga ginagawa ang bagay:

- **Audio** ay may master volume slider, tagapili ng output-device, at per-app mixer, kaya maaari mong hinaan ang browser tab na iyon nang hindi ginagalaw ang lahat ng iba pa.
- **Network** ay nag-i-scan para sa Wi-Fi, nagpapakita ng signal strength, kumokonekta, at hinahayaan kang pumili ng DNS provider.
- **Bluetooth** ay naglilista ng mga device mo na may connect/disconnect at antas ng baterya.
- **Power** ay nagpapakita ng battery stats, nagpapalit ng power profiles (naaalala nito ang hiwalay na pinili para sa baterya at AC), at nagpi-print ng ilang impormasyon ng system.
- **Display** ay may brightness slider, text size, mga preset ng monitor scaling, at — kapag higit sa isa ang screen mo — mga per-monitor control. Tingnan ang [mga monitor](33-monitors.md) para sa mas malalim na kuwento.
- **Clock** ay nagbubukas ng month grid na may ISO week numbers at paghakbang ng buwan.
- **World clock** ay nagpapanatili ng isang row bawat lungsod, kasama ang panahon nito at kung kumusta ang araw nito. Nakakahanap ang Search ng mga bayan pati mga time zone, kaya ang Fort Lauderdale ay Fort Lauderdale at hindi New York. Kung maling lungsod ang pinapangalanan ng linya sa itaas, i-click ito at sabihin kung nasaan ka; pumili ng lugar sa ibang time zone at lilipat din doon ang system clock, na madaling gamitin kapag naglalakbay ka. I-hover ang isang lungsod at i-click ang button ng tao para sabihin kung sino ang nakatira doon — mga plain na pangalan, o `@` GitHub handles para isama ang kanilang mga mukha.

Tinatanggap ng bawat panel ang keyboard pati ang mouse: gumagalaw ang mga arrow, nag-a-activate ang Return, humahakbang ang Tab papunta sa katabing panel, at nagsasara ang Escape.

Binibilang ng `Super + Ctrl + 1-9` ang mga panel mula kaliwa pakanan sa right section, nilalaktawan ang tray dahil wala itong sariling panel. Kaya tumutugma ang numero sa icon na ituturo mo.

### Tailscale at Dropbox

Dalawa pang widget ang lumalabas sa bar kapag na-install mo lang ang katugmang serbisyo mula sa **Install → Service**, at parehong sulit malaman dahil higit pa sa pag-uulat ng status ang ginagawa nila.

Ikinokonekta at idini-disconnect ng **Tailscale** panel ang tailnet, nagpapalit ito sa pagitan ng mga account, at pumipili ng exit node (lumalabas sa listahang iyon ang sarili mong mga machine at mga rehiyon ng Mullvad). Nagba-browse din ito ng mga machine mo — at kapag may napili, ipinapadala ng `s` ang mga file papunta roon sa pamamagitan ng Taildrop, na pinakamabilis na paraan para maglipat ng file papunta sa telepono mo o sa ibang laptop. Kinokopya ng `c` ang IP ng machine, ng `n` ang pangalan nito, at ng `d` ang buong DNS name nito. May send button din sa bawat row ng machine, kung mas gusto mong mag-click. Ang parehong bagay mula sa terminal ay `omarchy tailscale send <machine> [file...]`.

Pinamamahalaan ng **Dropbox** panel ang login, ipinapakita nito kung gaano karaming storage ang nagamit mo, at inililista ang mga kamakailang na-sync na file.

Ang pag-alis sa alinmang serbisyo ay nagtatanggal muli ng widget nito mula sa bar.

## Mga Indicator

Ang munting kumpol sa gitna ay ang indicators widget. Mga status glyph ito para sa mga mode na in-on mo: do not disturb, night light, isang nakapilang [paalala](09-reminders.md), isang aktibong screen recording, stay awake, at [diktasyon](11-text-extraction-dictation.md). Nagliliwanag sila kapag aktibo ang mode at kung hindi ay hindi nakahahadlang — i-hover kahit saan sa bar para silipin ang mga hindi aktibo. Ang pag-click sa isang indicator ay nagto-toggle sa mode na iyon. Isa pa ay status lang: nagliliwanag nang pula ang isang remote session habang may nakakonekta sa machine na ito sa pamamagitan ng gliff.

Kung mas gusto mong lagi silang nakikita, itakda ang `alwaysShow` sa `true` sa widget. At kung ilan lang sa kanila ang mahalaga sa iyo, ilista ang gusto mo sa `items`: `["Dnd", "Reminder", "NightLight"]`. Maaari kang magkaroon ng higit sa isang indicators widget, kaya maaaring magpakita ng iba't ibang subset ang iba't ibang seksyon.

## Pag-aayos muli ng bar

Kusa nitong inaayos ang sarili nito. Hindi mo kailangang magbukas ng config file para ilipat ang mga bagay.

Kumuha ng walang lamang bahagi ng bar sa paligid ng gitna at i-drag ito papunta sa ibang gilid ng screen, at lilipat doon ang bar — gumagana ang kaliwa, kanan, itaas, o ibaba, at umaangkop ang bawat widget (bumabalik ang mga vertical bar sa compact na icon-only na anyo). Nagsisimula ng parehong drag ang click-and-hold. I-double-left-click ang parehong walang lamang espasyo para i-cycle ang background ng bar mula clear hanggang glassy hanggang opaque. At i-drag ang anumang widget para ayusin muli ito o itapon ito sa ibang seksyon; magkakahiwalay na dumudulas ang ibang mga widget para magbigay ng puwang kung saan ito lalapag.

Ang gitna ng bar ay isang kahon: mananatiling nakagitna bilang isang grupo ang anumang nasa loob nito, at nakasabit sa mga gilid nito ang mga widget sa magkabilang panig nito. Habang nagda-drag ka ng widget, nagpapakita ang kahon bilang outline, o bilang linya sa bar kapag wala itong laman, at maaari kang mag-drop sa loob nito o sa tabi nito. Kapag sa kahon lalapag ang isang drop, lalaki ang kahon para tanggapin ang widget.

Ang widget na gusto mong nasa paligid pero hindi laging nakikita ay maaaring mapunta sa drawer ng tray: i-drag ito papunta sa tray, at magbubukas ang drawer para tanggapin ito. Nakaupo ito roon pagkatapos ng mga icon ng app, lumalabas tuwing lumalabas ang drawer, at pinapanatiling bukas ang drawer nito habang nakabukas ang panel nito. I-drag ito pabalik palabas papunta sa bar para ibalik ito.

Kung mas gusto mong pumili mula sa isang menu, nasa **Appearance → Menu Bar** ang posisyon, at pinipili ng **Bar Background** kung paano iginuguhit ang bar: **Opaque Bar**, **Glassy Bar** (see-through, na naka-blur ang nasa likod nito), o **Clear Bar**.

May mga command ang parehong mga bagay, na siyang gusto mo para sa isang [dotfiles](31-dotfiles.md) setup:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para magdagdag o mag-alis ng widget nang buo, gamitin ang mga plugin command. Ini-print ng `omarchy plugin list` ang bawat widget na alam ng shell kasama ang id nito, at pagkatapos:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Pagtatago ng bar

Ino-toggle ng `Super + Shift + Space` ang bar off at pabalik on nang hindi pinapatay ang shell — patuloy na gumagana ang mga panel at hotkey, makukuha mo lang pabalik ang mga pixel. Nasa menu din ito sa ilalim ng **Appearance → Menu Bar → Hide Bar**.

## Ang config file

Naka-store ang lahat ng ito sa `~/.config/omarchy/shell.json`, sa ilalim ng `bar` key. Narito ang isang pinaikling bersyon:

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

Bawat widget ay isang entry sa isa sa limang layout array, at nakaupo nang inline sa entry na iyon ang mga setting nito — walang hiwalay na settings file at walang `config` sub-object. Ang `format`, `formatAlt` (kung ano ang pini-cycle ng right-click), at `verticalFormat` ng clock ay pawang naroon mismo sa `{ "id": "omarchy.clock" }`.

Ang `center` ay ang kahon sa gitna ng bar: lahat ng nasa loob nito ay nakagitna sa screen bilang isang grupo. Nakasabit ang `centerBegin` at `centerEnd` sa magkabilang panig ng kahon, na siyang dahilan kung paano nananatiling nasa mismong gitna ang orasan kahit dumarating at umaalis ang panahon at update badge. Maglagay ng higit sa isang widget sa `center` at magkakasama silang magigitna; iwan itong walang laman at magtatagpo ang `centerBegin` at `centerEnd` sa gitna ng bar.

Isang panuntunang sulit tandaan: **kapag mayroon ka nang sariling `shell.json`, ito ay canonical**. Hanggang wala ka pang kino-customize, binabasa ng shell ang default file ng Omarchy. Sa sandaling mag-drag ka ng widget, magpatakbo ng `omarchy bar`, o ikaw mismo ang mag-edit ng file, pagmamay-ari mo na ito — walang deep merge, kaya hindi awtomatikong lilitaw sa bar mo ang mga bagong default widget sa mga susunod na release ng Omarchy. Ibinabalik ng `omarchy bar defaults` ang shipped layout tuwing gusto mo ng malinis na simula.

Hawak din ng parehong file ang idle timings mo sa top level, sa labas ng `bar` key: `idle.screensaver` at `idle.lock`, parehong nasa segundo mula nang naging idle ka. Kaya pumapasok ang default screensaver sa 150 segundo at ang lock sa 300.
