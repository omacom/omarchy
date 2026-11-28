# Nabigasyon

Lahat sa Omarchy ay nangyayari sa pamamagitan ng keyboard — _LAHAT!_ Kapag unang nagbukas ang system, literal na wala kang magagawa gamit lang ang mouse. Pero maaari mong pindutin ang `Super + Space` upang ipakita ang Omarchy Menu at mula rito ay magagawa mo na halos lahat.

Ngunit ang Omarchy menu ay hindi pa nga nilalayon na maging pangunahing paraan ng pagpapatakbo ng system sa karamihan ng panahon. Kaya nating maging mas mabilis pa riyan! Lahat ng pinakamahahalagang application ay direktang nakatali sa kani-kaniyang hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang isang browser gamit ang `Super + Shift + Return`. Subukang gawin ang isa kasunod ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland sa aktuwal na pagkilos:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pagkatapos ay maaari mong pindutin ang `Super + J` upang pagpatung-patungin ang mga ito sa halip na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin muli ang `Super + J` upang ibalik ang mga ito sa magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser upang pagpalitin ang mga window.

Ngayon ay subukan ang `Super + Shift + T` upang simulan ang Activity monitor. Lalabas iyon bilang isang floating window, na may titlebar na maaari mong hilahin at mga button para i-minimize, i-maximize, at isara ito. Bawat floating window ay nagkakaroon ng ganoon, nasaan man ito. Maaari mo itong i-tile gamit ang `Super + T` (at pindutin muli iyon upang gawin itong floating ulit). Ngayon ay pindutin ang `Super + Shift + F` upang buksan ang file manager. Magkakaroon ka ng maayos na apatang setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Nagna-navigate ka sa pagitan ng mga window na gusto mong maging aktibo gamit ang `Super + Arrow`. Ililipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, nagpapatuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application sa ikalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application sa ikalawang workspace nang hindi lumilipat dito).

Kapag may higit sa isang monitor, bawat monitor ay may sariling mga workspace 1 hanggang 10. Ang `Super + 2` ay pupunta sa ikalawang workspace ng monitor na kinaroroonan mo, at ipinapakita ng top bar ng bawat monitor ang sarili nitong mga workspace at ang kasalukuyang ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Inililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo sa monitor sa direksyong iyon, sa workspace na ipinapakita nito, at inililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo sa monitor sa direksyong iyon, kung saan kukunin nito ang parehong numero kung bakante iyon. Pinananatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa pagkakasaksak: sumasali ang mga ito sa ibang screen, na binibilang kasunod ng mga mayroon na ito, at bumabalik sa dati nilang mga numero kapag bumalik ang monitor.

Kung pipindutin mo nang matagal ang `Super` at gagamitin ang mouse upang i-click ang isang window, magagawa mong muling ayusin kung saan ito nakaupo. Kung pipindutin mo nang matagal ang `Super` at gagamitin ang kanang button ng mouse, malaya mong mababago ang laki ng window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Maaari ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (na pinananatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (maganda para sa YouTube!).

### Dwindle kumpara sa scrolling layout

Ang default na layout ng Omarchy ay tinatawag na dwindle. Pinananatili nitong nakikita sa lahat ng oras ang lahat ng window na binubuksan mo sa isang workspace, kahit pa kailangan nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ngunit maaari mo ring piliing gawing scrolling layout ang isang workspace kung saan nakahilera nang magkatabi ang mga window, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang isang workspace sa pamamagitan ng `Super + L`.

Ang muling pagpindot sa `Super + L` ay ginagawang floating ang workspace, kung saan malayang nagpapatong-patong ang mga window at ikaw mismo ang naglalagay sa mga ito, at ang ikatlong pagpindot ay ibinabalik ito sa dwindle. Ang `Super + Alt + L` ay dumaraan sa mga ito sa kabaligtarang direksyon. Ang isang window na floating na talaga — isa na inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang floating — ay nananatiling floating kapag bumalik sa tiling ang workspace. Minamarkahan ng top bar ang workspace na kinaroroonan mo ng layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Iniikot din ng pag-click sa markang iyon ang layout, ganoon din ang display key sa mga laptop na mayroon nito.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya maaari mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik ang mga ito nang ganoon pagkatapos ng isang restart.

Kung nais mong gamitin ang scrolling layout bilang default, maaari mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating na workspace

Gumagana ang isang floating workspace na parang tradisyonal na desktop: nagpapatong-patong ang mga window, at ikaw mismo ang naglilipat at nagpapalaki o nagpapaliit sa mga ito. Bawat window ay nagkakaroon ng titlebar sa mga kulay ng iyong theme, na may mga button para i-minimize, i-maximize, at isara. Ini-minimize rin ng `Super + M` ang naka-focus na window. Naghihintay ang isang naka-minimize na window sa dock; i-click ang app nito upang ibalik ito. I-click ang isang window upang dalhin ito sa harapan. Baguhin ang laki nito mula sa anumang gilid o sulok. I-double-click ang isang titlebar upang i-maximize ang window habang pinananatiling nakikita ang top bar, at muli upang maibalik ang dati nitong laki. Nilalaktawan ng Chrome at ng iba pang browser na nakabatay sa Chromium, ng Disks at ng Document Viewer ang titlebar at sa halip ay ginagamit ang sarili nilang header; ini-maximize sila ng `Super + Alt + F`, at ini-minimize sila ng `Super + M`.

Bawat workspace ay may dock, kasama ang iyong mga naka-pin na app, lahat ng kasalukuyang tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa Omarchy menu. I-right-click ang isang app sa grid, o pindutin ang `Delete`, upang i-uninstall ito. I-click ang isang app upang buksan ito, o upang dalhin sa harapan ang window nito; i-click muli upang umikot sa mga window nito. Ibinabalik lang ng Files ang isang window mula sa workspace na kinaroroonan mo at kung hindi ay nagbubukas ng bago, at palaging nagsisimula ng isa pa ang Terminal at Agent, bagaman unang bumabalik ang isang naka-minimize na window. Nagbubukas ng bagong window ang middle-click. Hilahin ang isang icon sa kahabaan ng dock upang ilipat ito; ang paghila ng isang tumatakbong app sa pagitan ng iba pa ay nagpapanatili dito roon. I-right-click upang panatilihin ang isang app sa dock, alisin ito roon, o isara ito. Nananatiling nakalabas ang dock habang walang laman ang isang workspace, at kapag nagkaroon na ng window ang workspace ay nagtatago ito hanggang sa makarating ang pointer sa gilid nito. Ganap itong itinatago ng isang fullscreen na window. Hilahin ang apps button patungo sa ibang gilid ng screen upang ilipat ang dock doon. I-right-click ito para sa _Position_, upang pumili ng gilid, at para sa _Layout_, upang itakda ang default na layout tulad ng ginagawa ng _Appearance > Workspace Layout_. Ang posisyon ay nasa ilalim din ng _Appearance > Dock > Dock Position_, at itinatakda ito ng `omarchy dock position left` mula sa isang terminal. Ang mga app na pinananatili mo sa dock ay kupas habang hindi tumatakbo ang mga ito. Upang panatilihin ang dock sa mga floating workspace lamang, gamitin ang _Appearance > Dock > Dock Only on Floating_ o ang `omarchy dock tiling off`.

Ang mga bagong workspace, at anumang hindi mo pa binibigyan ng sarili nitong layout gamit ang `Super + L`, ay gumagamit ng default na layout. Ang pagpapalit ng default ay nagre-reset dito ng bawat workspace na walang window, habang pinananatili ng isang may mga window ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy hyprland workspace layout default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Maaaring ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Maaari kang lumipat sa pagitan ng mga nakapangkat na window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o ang `Super + Alt + 1/2/3/4` upang direktang pumunta sa mga nakapangkat na window ayon sa pagkakasunod-sunod.

Maaari mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng muling pagpindot sa `Super + G`. Sa huli, maaari mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Paglalabas ng mga window

Maaari mong ilabas ang isang window mula sa alokasyon nito sa workspace gamit ang `Super + O`. Ipi-pin nito ito bilang isang floating window na sumusunod sa iyo sa anumang workspace na puntahan mo. Mahusay para sa mga video player at mga katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad na workspace

May isang espesyal na full-size na scratchpad workspace na nagpapatong sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo ang naroon gamit ang `Super + S`, at naglalagay ka ng mga window doon gamit ang `Super + Alt + S`.

Mahusay itong gumagana para sa mga control o isang terminal na gusto mong mabilis na gamitin nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Sa huli, may isang half-height na Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + the key above Tab` (grave sa mga US layout), at maglagay ng window doon gamit ang `Super + Shift + the key above Tab`.

Sa unang pagkakataon na magbukas ito, sinisimulan nito ang iyong default na agent, o hihilingin sa iyong pumili ng isa kung hindi ka pa nakakapili. Habang isang window lang ang laman ng console, bumababa ito bilang isang nakagitnang panel sa halip na sumakop sa buong screen. Maglagay ng ikalawang app dito at babalik ito sa buong lapad, upang magkaroon ng puwang ang dalawa na magkatabing umupo.

Upang ilipat ang isang window palabas ng scratchpad o ng console, ipadala ito nang direkta sa ibang workspace gamit ang tulad ng `Super + Shift + 1`.

### Kailangan lang masanay dito!

Kailangan ng kaunting panahon upang masanay sa pag-navigate sa iyong desktop nang ganito, ngunit kapag nasanay ka na, mahihirapan ka nang bumalik sa tradisyonal na karanasan sa desktop na pinapatakbo ng mouse!
