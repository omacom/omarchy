# Ang Top Bar

Ang strip sa tuktok ng iyong screen ay ang bar ng Omarchy. Hindi ito isang ikinabit lang na status bar kundi bahagi ng shell ng Omarchy, ang nag-iisang matagal na tumatakbong proseso ng Quickshell na gumuguhit din ng menu, mga notipikasyon, mga popup na OSD, at ng lock screen. Kaya perpekto itong nagti-tema kasama ng lahat ng iba pa at kaya mabilis na bumubukas ang isang panel sa halip na maglunsad ng bagong app.

Ito rin ang nag-iisang bahagi ng desktop na palaging nasa screen, kaya sulit na malaman kung ano ang ginagawa ng lahat ng maliliit na glyph na iyon.

## Ano ang nasa ibabaw nito bilang default

May tatlong seksyon ang bar. Sa kaliwa nakaupo ang logo ng Omarchy (ang launcher ng menu) at ang mga indikator ng workspace. Sa gitna, makukuha mo ang mga status indicator, ang orasan, Elsewhen (isang world clock), ang panahon, at isang badge ng update ng Omarchy. Sa kanan: ang layout ng keyboard (kapag higit sa isa ang naka-configure), ang system tray, mga agent, bluetooth, network, audio, display, at power.

Ilan sa mga iyon ay lumalabas lang kapag mayroon silang gustong sabihin. Lumalabas lang ang layout ng keyboard kung nakapag-configure ka ng higit sa isang layout. Lumalabas lang ang badge ng update kapag may naghihintay na update ng Omarchy. At lumalabas ang icon ng mga agent sa unang pagkakataong makahanap ang Omarchy ng paggamit ng AI coding sa makina (tingnan ang [AI](17-ai.md)).

## Pag-click sa paligid

Halos bawat widget ay may ginagawa sa kaliwa, kanan, at gitnang click, at marami ang tumutugon sa pag-scroll. Ito ang bahaging hindi napapansin ng mga tao — ang kanan at gitnang button ang kinaroroonan ng maraming magagandang bagay.

| Widget | Kaliwa | Kanan | Gitna / scroll |
| --- | --- | --- | --- |
| Menu | Menu ng Omarchy | Bagong terminal | — |
| Mga Workspace | I-focus ang workspace na iyon | — | Scroll: susunod/nakaraang workspace |
| Orasan | Popup ng kalendaryo | I-cycle ang format ng label | Gitna: tagapili ng timezone |
| Panahon | Popup ng forecast | Buong panahon bilang notipikasyon | Gitna: i-refresh |
| Audio | Panel ng audio | I-mute | Gitna: panel · scroll: volume |
| Mikropono | I-mute ang mikropono | — | Gitna: panel ng audio · scroll: input volume |
| Network | Panel ng network | — | — |
| Bluetooth | Panel ng Bluetooth | I-toggle ang radyo | — |
| Display | Panel ng display | — | Scroll: liwanag |
| Power | Panel ng power | I-toggle ang porsyento ng baterya | — |
| Media | I-play/i-pause | Popup ng cover art | Gitna: susunod · scroll: nakaraan/susunod |
| Mga Agent | Panel ng mga agent | Ilunsad ang iyong agent | Gitna: susunod na subscription |
| Tray | I-hover para ipakita ang drawer | I-right-click ang chevron para pamahalaan | — |
| Update ng Omarchy | Patakbuhin ang update | — | — |

Hindi lahat ng nasa talahanayang iyon ay nasa iyong bar mula sa simula. Ang widget ng media (MPRIS now-playing, na may scrolling na track at artist) at ang widget ng mikropono ay parehong built-in ngunit naka-off bilang default — idagdag ang mga ito kung gusto mo, tulad ng inilalarawan sa ibaba.

## Ang mga panel

Ang pag-click sa isang icon ng bar ay nagbubukas ng panel, na isang tamang popup na may mga slider, listahan, at nabigasyon sa keyboard sa halip na isang tooltip. Bawat isa ay mayroon ding hotkey, kaya hindi mo na kailangang pumuntirya sa isang 16-pixel na glyph:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Kalendaryo |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | I-toggle ang ika-n na panel sa kanang seksyon |

Hindi mga read-out ang mga panel. Sila ang lugar kung saan talagang ginagawa mo ang bagay:

- Ang **Audio** ay may master volume slider, tagapili ng output device, at mixer bawat app, kaya maaari mong hinaan ang isang tab ng browser na iyon nang hindi nakikialam sa lahat ng iba pa.
- Ang **Network** ay nag-scan para sa Wi-Fi, nagpapakita ng lakas ng signal, kumukonekta, at hinahayaan kang pumili ng DNS provider.
- Inililista ng **Bluetooth** ang iyong mga device na may connect/disconnect at mga antas ng baterya.
- Ipinapakita ng **Power** ang mga stat ng baterya, nagpapalit ng mga power profile (naaalala nito ang hiwalay na pagpipilian para sa baterya at AC), at nagpi-print ng ilang impormasyon ng sistema.
- Ang **Display** ay may slider ng liwanag, laki ng teksto, mga preset ng scaling ng monitor, at — kapag mayroon kang higit sa isang screen — mga kontrol bawat monitor. Tingnan ang [mga monitor](33-monitors.md) para sa mas malalim na kuwento.
- Nagbubukas ang **Orasan** ng isang grid ng buwan na may mga numero ng linggo ng ISO at pag-step ng buwan.

Kinukuha ng bawat panel ang keyboard pati na rin ang mouse: ang mga arrow ay gumagalaw, ang Return ay nag-activate, ang Tab ay humahakbang papunta sa katabing panel, at ang Escape ay nagsasara.

Binibilang ng `Super + Ctrl + 1-9` ang mga panel mula kaliwa papunta sa kanan sa kanang seksyon, nilalampasan ang tray dahil wala itong sariling panel. Kaya tumutugma ang numero sa icon na pupuntiryahan mo.

### Tailscale at Dropbox

Dalawa pang widget ang lumalabas sa bar kapag ini-install mo ang katugmang serbisyo mula sa **I-install → Serbisyo**, at parehong sulit malaman dahil higit pa sa pag-uulat ng status ang ginagawa ng mga ito.

Kinukonekta at dinidiskonekta ng panel ng **Tailscale** ang tailnet, nagpapalit sa pagitan ng mga account, at pumipili ng exit node (ang iyong sariling mga makina at mga rehiyon ng Mullvad ay parehong lumalabas sa listahang iyon). Nagba-browse din ito ng iyong mga makina — at kapag may napili, ang `s` ay nagpapadala ng mga file dito sa pamamagitan ng Taildrop, na siyang pinakamabilis na paraan para ilipat ang isang file sa iyong telepono o ibang laptop. Kinokopya ng `c` ang IP ng makina, ng `n` ang pangalan nito, at ng `d` ang buong DNS name nito. Mayroon ding send button sa bawat row ng makina, kung mas gusto mong mag-click. Ang parehong bagay mula sa terminal ay `omarchy tailscale send <machine> [file...]`.

Pinangangasiwaan ng panel ng **Dropbox** ang pag-login, ipinapakita kung gaano karaming storage ang nagamit mo, at inililista ang mga kamakailang na-sync na file.

Ang pag-alis sa alinmang serbisyo ay muling nag-aalis ng widget nito sa bar.

## Mga indikator

Ang maliit na kumpol sa gitna ay ang widget ng mga indikator. Ito ay mga status glyph para sa mga mode na na-on mo: do not disturb, ilaw-panggabi, isang nakapilang [paalala](09-reminders.md), isang aktibong pag-record ng screen, manatiling gising, at [diktasyon](11-text-extraction-dictation.md). Umiilaw ang mga ito kapag aktibo ang mode at kung hindi ay nananatiling hindi nakakaabala — i-hover sa kaliwa ng orasan (sa itaas nito sa isang patayong bar) para masilip ang mga hindi aktibo. Ang pag-click sa isang indikator ay ini-toggle ang mode na iyon. Isa pa ay status lang: umiilaw nang pula ang isang remote session habang may nakakonekta sa makinang ito sa pamamagitan ng gliff.

Kung mas gusto mo silang palaging nakikita, itakda ang `alwaysShow` sa `true` sa widget. At kung ilan lang sa kanila ang inaalala mo, ilista ang mga gusto mo sa `items`: `["Dnd", "Reminder", "NightLight"]`. Maaari kang magkaroon ng higit sa isang widget ng mga indikator, kaya ang iba't ibang seksyon ay maaaring magpakita ng iba't ibang subset.

## Muling pagsasaayos ng bar

Ang bar mismo ang nagko-configure. Hindi mo kailangang magbukas ng config file para ilipat ang mga bagay.

Hawakan ang isang bakanteng bahagi ng bar sa paligid ng gitna at i-drag ito papunta sa ibang gilid ng screen, at lilipat ang bar roon — kaliwa, kanan, itaas, o ibaba ay gumagana lahat, at ang bawat widget ay umaangkop (ang mga patayong bar ay bumabalik sa mga compact na anyong icon-only). Sinisimulan ng click-and-hold ang parehong drag. I-double-left-click ang parehong bakanteng espasyong iyon para i-cycle ang background ng bar mula clear papunta sa glassy papunta sa opaque. At i-drag ang anumang widget para muling ayusin ito o ihagis ito sa ibang seksyon.

Ang isang widget na gusto mong nasa paligid ngunit hindi palaging nakikita ay maaaring ilagay sa drawer ng tray: i-drag ito papunta sa tray, at bubukas ang drawer para tanggapin ito. Nakaupo ito roon pagkatapos ng mga icon ng app, lumalabas tuwing lumalabas ang drawer, at pinananatiling bukas ang drawer nito habang nakabukas ang panel nito. I-drag ito pabalik palabas papunta sa bar para ibalik ito.

Kung mas gusto mong pumili mula sa isang menu, ang **Mag-trigger → Hitsura → Menu Bar** ay mayroong posisyon, at ang **Background ng Bar** ang pumipili kung paano iguguhit ang bar: **Opaque na Bar**, **Mala-salaming Bar** (see-through, na naka-blur ang nasa likod nito), o **Malinaw na Bar**.

Ang parehong mga bagay ay may mga command, na siyang gusto mo para sa isang [dotfiles](31-dotfiles.md) na setup:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Para magdagdag o mag-alis ng isang widget nang buo, gamitin ang mga command ng plugin. Ini-print ng `omarchy plugin list` ang bawat widget na kilala ng shell kasama ang id nito, at pagkatapos:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Pagtatago ng bar

Ini-toggle ng `Super + Shift + Space` ang bar off at on muli nang hindi pinapatay ang shell — patuloy na gumagana ang mga panel at hotkey, nababawi mo lang ang mga pixel. Nasa menu din ito sa ilalim ng **Mag-trigger → Hitsura → Menu Bar → Itago ang Bar**.

## Ang config file

Ang lahat ng ito ay nakaimbak sa `~/.config/omarchy/shell.json`, sa ilalim ng `bar` key. Narito ang isang pinaikling bersyon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Bawat widget ay isang entry sa isa sa tatlong layout array, at ang mga setting nito ay nakaupo nang inline sa entry na iyon — walang hiwalay na settings file at walang `config` na sub-object. Ang `format` ng orasan, ang `formatAlt` (kung saan nag-cycle ang right-click), at ang `verticalFormat` ay lahat nakatira roon sa `{ "id": "omarchy.clock" }`.

Pinapangalanan ng `centerAnchor` ang nag-iisang center widget na napipinned sa eksaktong gitna ng screen, habang ang iba ay nasa gilid nito. Ganiyan nananatiling nasa pinakagitna ang orasan kahit dumarating at umaalis ang panahon at badge ng update. Itakda ito sa isang empty string at ang center list ay isesentro na lang bilang isang grupo.

Isang panuntunan na sulit tandaan: **kapag mayroon ka nang sarili mong `shell.json`, ito ay canonical**. Hanggang wala ka pang kino-customize, binabasa ng shell ang default file ng Omarchy. Sa sandaling mag-drag ka ng widget, magpatakbo ng `omarchy bar`, o mag-edit ng file mismo, sa iyo na ito — walang deep merge, kaya ang mga bagong default widget sa mga susunod na release ng Omarchy ay hindi awtomatikong lalabas sa iyong bar. Ibinabalik ng `omarchy bar defaults` ang shipped na layout tuwing gusto mo ng malinis na simula.

Ang parehong file ay naglalaman din ng iyong mga idle timing sa top level, sa labas ng `bar` key: `idle.screensaver` at `idle.lock`, parehong sa segundo mula nang maging idle ka. Kaya ang default na screensaver ay nagsisimula sa 150 segundo at ang lock sa 300.
