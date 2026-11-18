# Nabigasyon

Lahat sa Omarchy ay nangyayari sa pamamagitan ng keyboard — _LAHAT!_ Kapag unang nagbukas ang system, literal na wala kang magagawa gamit lang ang mouse. Pero maaari mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito ay magagawa mo na halos lahat.

Pero ang Omarchy menu ay hindi pa nga nilalayong maging pangunahing paraan para patakbuhin ang system sa karamihan ng oras. Kaya nating maging mas mabilis kaysa riyan! Lahat ng pinakamahahalagang application ay direktang nakatali sa kani-kanilang hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang browser gamit ang `Super + Shift + Return`. Subukan mong gawin ang isa pagkatapos ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland na gumagana:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Maaari mo namang pindutin ang `Super + J` para pagpatung-patungin sila sa ibabaw ng isa't isa sa halip na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa magkatabi nilang posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon subukan ang `Super + Shift + T` para simulan ang Activity monitor. Lalabas iyon bilang isang floating window. Maaari mo itong i-tile gamit ang `Super + T` (at pindutin ulit iyon para gawin ulit itong floating). Ngayon pindutin ang `Super + Shift + F` para buksan ang file manager. Magkakaroon ka ng maayos na apatang setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Maglalakbay ka sa pagitan ng mga window na gusto mong maging aktibo gamit ang `Super + Arrow`. Lilipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, nagpapatuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application sa pangalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application sa pangalawang workspace nang hindi lumilipat dito).

Kapag may higit sa isang monitor, bawat monitor ay may sarili nitong mga workspace 1 hanggang 10. Pupunta ang `Super + 2` sa pangalawang workspace ng monitor na kinaroroonan mo, at ipinapakita ng top bar ng bawat monitor ang sarili nitong mga workspace at ang kasalukuyang ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Inililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo sa monitor sa direksyong iyon, sa workspace na ipinapakita nito, at inililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo papunta sa monitor sa direksyong iyon, kung saan kukunin nito ang parehong numero kung bakante iyon. Pinananatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa saksakan: sumasama ang mga ito sa isa pang screen, na binibilang pagkatapos ng mga mayroon na ito, at bumabalik sa dati nilang mga numero kapag bumalik ang monitor.

Kung pipigilan mo ang `Super` at gagamitin ang mouse para mag-click sa isang window, magagawa mong muling ayusin kung saan ito nakapuwesto. Kung pipigilan mo ang `Super` at gagamitin ang kanang button ng mouse, malaya mong mababago ang laki ng window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Maaari ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (na pinananatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (maganda para sa YouTube!).

### Dwindle vs scrolling na layout

Ang default na layout ng Omarchy ay tinatawag na dwindle. Pinananatili nitong nakikita sa lahat ng oras ang lahat ng window na bubuksan mo sa isang workspace, kahit kailangan nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero maaari mo ring piliing gawing scrolling layout ang isang workspace kung saan nakahilera ang mga window nang magkatabi, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang isang workspace sa pamamagitan ng `Super + L`.

Ang muling pagpindot sa `Super + L` ay ginagawang floating ang workspace, kung saan malayang nagpapatung-patong ang mga window at ikaw mismo ang naglalagay sa mga ito, at ang pangatlong pagpindot ay ibinabalik ito sa dwindle. Ang `Super + Alt + L` ay dumadaan sa mga ito sa kabaligtarang paraan. Ang isang window na lumulutang naman talaga — isa na inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang floating — ay nananatiling floating kapag bumalik sa tiling ang workspace. Minamarkahan ng top bar ang workspace na kinaroroonan mo ng layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Ang pag-click sa markang iyon ay pinaiikot din ang layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya maaari mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik sila nang ganoon pagkatapos ng isang restart.

Kung nais mong gamitin ang scrolling layout bilang default, maaari mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating workspace

Gumagana ang isang floating workspace tulad ng isang tradisyunal na desktop: nagpapatung-patong ang mga window, at ikaw mismo ang naglilipat at nagpapalaki o nagpapaliit sa mga ito. Bawat window ay nagkakaroon ng titlebar sa mga kulay ng theme mo, na may mga button para mag-minimize, mag-maximize, at magsara. Mini-minimize rin ng `Super + M` ang naka-focus na window. Ang isang naka-minimize na window ay naghihintay sa dock; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa harap. Baguhin ang laki nito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang pinananatiling nakikita ang top bar, at ulitin para maibalik ang dati nitong laki. Nilalaktawan ng Chrome at ng iba pang Chromium-based na browser, ng Disks at ng Document Viewer ang titlebar at ginagamit ang sarili nilang header sa halip; imina-maximize sila ng `Super + Alt + F`, at mini-minimize sila ng `Super + M`.

Nagpapakita rin ang isang floating workspace ng dock, kasama ang mga naka-pin mong app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa Omarchy menu. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin sa harap ang window nito; i-click ulit para umikot sa mga window nito. Ibinabalik lang ng Files ang isang window mula sa workspace na kinaroroonan mo at kung hindi ay nagbubukas ng bago, at palaging nagsisimula ng panibago ang Terminal at Agent, bagaman nauunang bumalik ang isang naka-minimize na window. Nagbubukas ng bagong window ang middle-click. I-drag ang isang icon sa kahabaan ng dock para ilipat ito; ang pag-drag ng isang tumatakbong app papasok sa pagitan ng iba ay pinananatili ito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito mula roon, o isara ito. Umuurong ang dock palayo sa isang fullscreen window. I-right-click ang apps button para ilipat ang dock sa ibang gilid o para itago ito hanggang sa maabot ng pointer ang gilid nito. Ang posisyon ay nasa ilalim din ng _Appearance > Dock > Dock Position_, at itinatakda ng `omarchy dock position left` at `omarchy dock autohide on` ang dalawa mula sa isang terminal. Ang mga app na pinananatili mo sa dock ay kupas habang hindi sila tumatakbo.

Ginagamit ng mga bagong workspace, at ng anumang hindi mo pa binigyan ng sarili nitong layout gamit ang `Super + L`, ang default na layout. Ang pagpapalit ng default ay nire-reset dito ang bawat workspace na walang window, habang pinananatili ng isa na may mga window ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy-hyprland-workspace-layout-default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Maaaring ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Maaari kang gumalaw sa pagitan ng mga nakapangkat na window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o ang `Super + Alt + 1/2/3/4` para direktang pumunta sa mga nakapangkat na window nang magkakasunod.

Maaari mong ilabas ang isang window mula sa pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng muling pagpindot sa `Super + G`. Panghuli, maaari mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Pag-pop ng mga window

Maaari mong ilabas ang isang window mula sa pagkakatalaga nito sa workspace gamit ang `Super + O`. Ipi-pin nito iyon bilang isang floating window na sumusunod sa iyo sa anumang workspace na puntahan mo. Maganda para sa mga video player at mga katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

May isang espesyal na full-size na scratchpad workspace na pumapatong sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo ang laman nito gamit ang `Super + S`, at naglalagay ka ng mga window roon gamit ang `Super + Alt + S`.

Gumagana ito nang maayos para sa mga control o isang terminal na gusto mong gamitin nang mabilis nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Panghuli, may isang half-height na Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + Grave`, at maglagay ng window roon gamit ang `Super + Shift + Grave`.

Bumubukas ito na handa nang gamitin ang default agent mo. Habang iisang window lang ang laman ng console, bumababa ito bilang isang panel na nakagitna sa halip na sumaklaw sa screen. Maglagay ng pangalawang app dito at babalik ito sa buong lapad, para may puwang ang dalawa na magkatabi.

Para ilipat ang isang window palabas mula sa scratchpad o sa console, ipadala ito nang direkta sa ibang workspace gamit ang tulad ng `Super + Shift + 1`.

### Kailangan lang masanay!

Medyo matatagalan bago ka masanay sa paglalakbay sa desktop mo nang ganito, pero kapag nasanay ka na, mahihirapan ka nang bumalik sa isang tradisyunal na karanasan sa desktop na pinapatakbo ng mouse!
