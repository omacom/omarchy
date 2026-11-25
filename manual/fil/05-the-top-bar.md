# Ang Bar sa Itaas

Ang strip sa kahabaan ng itaas ng screen mo ay ang Omarchy bar. Hindi ito isang status bar na ikinabit lang, kundi bahagi ng Omarchy shell, ang iisang matagalang tumatakbong proseso ng Quickshell na siya ring gumuguhit ng menu, ng mga notification, ng mga OSD popup, at ng lock screen. Kaya perpekto itong tumutugma sa tema ng lahat ng iba pa, at kaya agad-agad nagbubukas ang isang panel sa halip na magpatakbo ng bagong app.

Ito rin ang nag-iisang bahagi ng desktop na laging nasa screen, kaya sulit na malaman kung ano ang ginagawa ng lahat ng maliliit na glyph na iyon.

## Ano ang nandito bilang default

May tatlong seksyon ang bar. Sa kaliwa nakaupo ang logo ng Omarchy (ang launcher ng menu) at ang mga indicator ng workspace. Sa gitna makukuha mo ang mga status indicator, ang orasan, ang Elsewhen (isang world clock), ang panahon, at isang badge ng update ng Omarchy. Sa kanan: ang system tray, ang layout ng keyboard (kapag higit sa isang layout o input method ang naka-configure), mga agent, bluetooth, network, audio, display, at power.

Ilang sa mga iyon ay lumalabas lang kapag may sasabihin sila. Lumalabas lang ang layout ng keyboard kung nag-configure ka ng higit sa isang layout o input method. Lumalabas lang ang badge ng update kapag may naghihintay na update ng Omarchy.

## Pag-click sa paligid

Halos bawat widget ay may ginagawa sa left, right, at middle click, at ilan ang tumutugon sa pag-scroll. Ito ang bahaging hindi napapansin ng mga tao — sa right at middle button nagtatago ang marami sa magagandang bagay.

| Widget | Kaliwa | Kanan | Gitna / scroll |
| --- | --- | --- | --- |
| Menu | Menu ng Omarchy | Bagong terminal | — |
| Mga workspace | Ituon ang workspace na iyon sa monitor na ito | — | Scroll: susunod/nakaraang workspace |
| Orasan | Popup ng kalendaryo | Paikutin ang format ng label | Gitna: tagapili ng timezone |
| World clock | Panel ng world clock | I-refresh | Gitna: i-refresh |
| Panahon | Popup ng forecast | Buong panahon bilang notification | Gitna: i-refresh |
| Audio | Panel ng audio | I-mute | Gitna: panel · scroll: volume |
| Mikropono | I-mute ang mic | — | Gitna: panel ng audio · scroll: input volume |
| Network | Panel ng network | — | — |
| Bluetooth | Panel ng Bluetooth | I-toggle ang radio | — |
| Display | Panel ng display | — | Scroll: liwanag |
| Power | Panel ng power | I-toggle ang porsyento ng baterya | — |
| Media | I-play/i-pause | Popup ng cover art | Gitna: susunod · scroll: nakaraan/susunod |
| Mga agent | Panel ng mga agent | Ilunsad ang agent mo | Gitna: i-refresh ang usage |
| Tray | I-hover para ipakita ang drawer | Right-click sa chevron para pamahalaan | — |
| Update ng Omarchy | Patakbuhin ang update | — | — |

Hindi lahat ng nasa talahanayang iyon ay nasa bar mo agad-agad. Ang media widget (MPRIS now-playing, na may nag-i-scroll na track at artist) at ang microphone widget ay parehong built-in pero naka-off bilang default — idagdag mo sila kung gusto mo, gaya ng inilalarawan sa ibaba.

## Ang mga panel

Ang pag-click sa isang icon ng bar ay nagbubukas ng panel, na isang maayos na popup na may mga slider, listahan, at keyboard navigation sa halip na isang tooltip. May hotkey din ang bawat isa, kaya hindi mo na kailangang tumutok sa isang 16-pixel na glyph:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | I-toggle ang ika-n na panel sa kanang seksyon |

Hindi mga readout lang ang mga panel. Doon mo talaga ginagawa ang bagay:

- **Audio** ay may master volume slider, isang tagapili ng output device, at isang per-app mixer, kaya maaari mong hinaan ang isang tab ng browser na iyon nang hindi ginagalaw ang lahat ng iba pa.
- **Network** ay nag-i-scan ng Wi-Fi, nagpapakita ng lakas ng signal, kumokonekta, at hinahayaan kang pumili ng DNS provider.
- **Bluetooth** ay naglilista ng mga device mo na may connect/disconnect at mga antas ng baterya.
- **Power** ay nagpapakita ng mga battery stat, nagpapalit ng mga power profile (naaalala nito ang hiwalay na pinili para sa baterya at AC), at nagpi-print ng ilang impormasyon ng system.
- **Display** ay may dalang brightness slider, laki ng text, mga preset ng scaling ng monitor, at — kapag may higit ka sa isang screen — mga kontrol na per-monitor. Tingnan ang [mga monitor](33-monitors.md) para sa mas malalim na kuwento.
- **Clock** ay nagbubukas ng grid ng buwan na may mga numero ng linggo ng ISO at paghakbang ng buwan.
- **World clock** ay nagpapanatili ng isang hilera bawat lungsod, kasama ang panahon nito at kung kumusta ang araw nito. Nakakahanap ang Search ng mga bayan pati ng mga time zone, kaya ang Fort Lauderdale ay Fort Lauderdale at hindi New York. Kung maling lungsod ang pinangalanan ng linya sa itaas, i-click ito at sabihin kung nasaan ka; pumili sa ibang time zone at lilipat din doon ang orasan ng system, na madaling gamitin kapag naglalakbay ka. Mag-hover sa isang lungsod at i-click ang button ng tao para sabihin kung sino ang nakatira roon — mga payak na pangalan, o mga `@` GitHub handle para isama ang kanilang mga mukha.

Tumatanggap ang bawat panel ng keyboard pati ng mouse: gumagalaw ang mga arrow, nag-a-activate ang Return, lumilipat ang Tab sa katabing panel, at nagsasara ang Escape.

Binibilang ng `Super + Ctrl + 1-9` ang mga panel mula kaliwa pakanan sa kanang seksyon, nilalaktawan ang tray dahil wala itong sariling panel. Kaya tumutugma ang numero sa icon na ituturo mo.

### Tailscale and Dropbox

Dalawa pang widget ang lumalabas sa bar kapag na-install mo na ang katugmang serbisyo mula sa **Install → Service**, at sulit na malaman ang dalawa dahil higit pa sa pag-uulat ng status ang ginagawa nila.

Kinokonekta at dinidiskonekta ng **Tailscale** panel ang tailnet, nagpapalit-palit sa pagitan ng mga account, at pumipili ng exit node (parehong lumalabas sa listahang iyon ang sarili mong mga makina at ang mga rehiyon ng Mullvad). Nagba-browse din ito ng mga makina mo — at kapag may napili na, ipinapadala ng `s` ang mga file dito sa pamamagitan ng Taildrop, na pinakamabilis na paraan para ilipat ang isang file sa telepono mo o sa ibang laptop. Kinokopya ng `c` ang IP ng makina, ng `n` ang pangalan nito, at ng `d` ang buong DNS name nito. May send button din sa bawat hilera ng makina, kung mas gusto mong mag-click. Ang parehong bagay mula sa terminal ay `omarchy tailscale send <machine> [file...]`.

Hinahawakan ng **Dropbox** panel ang login, ipinapakita kung gaano karaming storage ang nagamit mo na, at inililista ang mga file na kamakailang na-sync.

Ang pag-aalis sa alinman sa serbisyo ay nagtatanggal ulit ng widget nito sa bar.

## Mga Indicator

Ang maliit na kumpol sa gitna ay ang indicators widget. Mga glyph ng status ito para sa mga mode na binuksan mo: do not disturb, night light, isang nakapilang [paalala](09-reminders.md), isang aktibong screen recording, at stay awake, pati mga babala habang naka-on ang passwordless sudo o may nakakonekta sa isang remote session. Umiilaw sila kapag aktibo ang mode at kung hindi ay nananatili silang hindi nakahahadlang — mag-hover lang sa tabi nila, kung saan uupo ang mga hindi aktibo, para silipin ang mga iyon. Ang pag-click sa isang indicator ay nagto-toggle sa mode na iyon. Isa pa ay status lang: umiilaw nang pula ang isang remote session habang may nakakonekta sa makinang ito sa pamamagitan ng gliff.

Kung mas gusto mong lagi silang nakikita, itakda ang `alwaysShow` sa `true` sa widget. At kung ilan lang sa kanila ang mahalaga sa iyo, ilista ang mga gusto mo sa `items`: `["Dnd", "Reminder", "NightLight"]`. Maaari kang magkaroon ng higit sa isang indicators widget, kaya maaaring magpakita ang iba't ibang seksyon ng iba't ibang subset.

## Pag-aayos ulit ng bar

Ang bar ang nagko-configure sa sarili nito. Hindi mo kailangang magbukas ng config file para ilipat ang mga bagay.

Hawakan ang isang bakanteng bahagi ng bar sa paligid ng gitna at i-drag ito patungo sa ibang gilid ng screen, at lilipat doon ang bar — gumagana ang kaliwa, kanan, itaas, o ibaba, at umaangkop ang bawat widget (ang mga vertical na bar ay bumabalik sa mga compact na anyong icon lang). Ang click-and-hold ay nagsisimula ng parehong drag. I-double-left-click ang parehong bakanteng espasyo para paikutin ang background ng bar mula clear patungong glassy patungong opaque. At i-drag ang anumang widget para ayusin ulit ito o ihagis ito sa ibang seksyon; maghihiwalay ang iba pang widget para magbigay ng puwang kung saan ito lalapag.

Ang gitna ng bar ay isang kahon: anumang nasa loob nito ay nananatiling nakagitna bilang isang grupo, at ang mga widget sa magkabilang panig nito ay nakasabit sa mga gilid nito. Habang nagda-drag ka ng widget, lumalabas ang kahon bilang isang outline, o isang linya sa kahabaan ng bar kapag wala itong laman, at maaari kang mag-drop sa loob nito o sa tabi nito. Kapag ang isang drop ay lalapag sa kahon, lumalaki ang kahon para tanggapin ang widget.

Ang isang widget na gusto mong nariyan pero hindi laging nakikita ay maaaring pumunta sa drawer ng tray: i-drag ito papunta sa tray, at magbubukas ang drawer para tanggapin ito. Nakaupo ito roon pagkatapos ng mga icon ng app, lumalabas tuwing lumalabas ang drawer, at pinananatiling bukas ang drawer nito habang nakataas ang panel nito. I-drag ito palabas pabalik sa bar para ibalik ito.

Kung mas gusto mong pumili mula sa isang menu, nasa **Appearance → Menu Bar** ang posisyon, at pinipili ng **Bar Background** kung paano iginuguhit ang bar: **Opaque Bar**, **Glassy Bar** (see-through, na blurred ang nasa likod nito), o **Clear Bar**.

Ang parehong mga bagay ay may mga command, na siyang gusto mo para sa isang setup ng [dotfiles](31-dotfiles.md):

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

Ino-toggle ng `Super + Shift + Space` ang bar na naka-off at naka-on ulit nang hindi pinapatay ang shell — patuloy na gumagana ang mga panel at hotkey, nababawi mo lang ang mga pixel. Nasa menu rin ito sa ilalim ng **Appearance → Menu Bar → Hide Bar**.

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

Bawat widget ay isang entry sa isa sa limang layout array, at ang mga setting nito ay nakaupo nang inline sa entry na iyon — walang hiwalay na file ng mga setting at walang `config` sub-object. Ang `format`, `formatAlt` (kung saan umiikot ang right-click) ng orasan, at ang `verticalFormat` ay lahat nakatira mismo roon sa `{ "id": "omarchy.clock" }`.

Ang `center` ay ang kahon sa gitna ng bar: lahat ng nasa loob nito ay nakagitna sa screen bilang isang grupo. Nakasabit ang `centerBegin` at `centerEnd` sa magkabilang panig ng kahon, kaya nananatiling eksaktong nasa gitna ang orasan kahit dumarating at umaalis ang panahon at ang badge ng update. Maglagay ng higit sa isang widget sa `center` at magkakasama silang nakagitna; iwan itong walang laman at magkikita ang `centerBegin` at `centerEnd` sa gitna ng bar.

Isang patakarang sulit isaloob: **kapag may sarili ka nang `shell.json`, ito ang canonical**. Hanggang wala ka pang kino-customize, binabasa ng shell ang default file ng Omarchy. Sa sandaling mag-drag ka ng widget, magpatakbo ng `omarchy bar`, o ikaw mismo ang mag-edit ng file, sa iyo na ito — walang deep merge, kaya ang mga bagong default widget sa mga susunod na release ng Omarchy ay hindi awtomatikong lalabas sa bar mo. Ibinabalik ng `omarchy bar defaults` ang kasamang layout tuwing gusto mo ng malinis na panimula.

Hawak din ng parehong file ang iyong mga idle timing sa top level, sa labas ng `bar` key: `idle.screensaver` at `idle.lock`, parehong nasa segundo mula nang naging idle ka. Kaya ang default na screensaver ay gumagana sa 150 segundo at ang lock sa 300.
