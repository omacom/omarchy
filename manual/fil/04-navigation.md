# Nabigasyon

Lahat sa Omarchy ay ginagawa sa pamamagitan ng keyboard — _LAHAT!_ Pagka-start pa lang ng sistema, literal na wala kang magagawa gamit ang mouse lang. Pero maaari mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito ay magagawa mo na halos lahat.

Ngunit ang menu ng Omarchy ay hindi pa nga nilalayong maging pangunahing paraan ng pagpapatakbo ng sistema sa karamihan ng oras. Mas bibilis pa tayo kaysa riyan! Lahat ng pinakamahahalagang application ay direktang nakatali sa mga indibidwal na hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang browser gamit ang `Super + Shift + Return`. Subukang gawin ang isa pagkatapos ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland sa aksyon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Maaari mo ring pindutin ang `Super + J` para pagpatung-patungin sila sa ibabaw ng isa't isa imbes na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon ay subukan ang `Super + Shift + T` para simulan ang Activity monitor. Lalabas iyon bilang isang floating na window, na may titlebar na maaari mong hilahin at mga button para i-minimize, i-maximize, at isara ito. Bawat floating na window ay nagkakaroon nito, saanman ito naroon. Maaari mo itong i-tile gamit ang `Super + T` (at pindutin ulit iyon para gawin itong floating ulit). Ngayon ay pindutin ang `Super + Shift + F` para buksan ang file manager. Magkakaroon ka ng maayos na four-way na setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Naglalakbay ka sa pagitan ng mga window na gusto mong maging aktibo gamit ang `Super + Arrow`. Lilipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, nagpapatuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application sa pangalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application sa pangalawang workspace nang hindi lumilipat dito).

Kapag higit sa isa ang monitor, bawat monitor ay may sarili nitong workspaces 1 hanggang 10. Ang `Super + 2` ay pupunta sa pangalawang workspace ng monitor na kinaroroonan mo, at ang top bar ng bawat monitor ay nagpapakita ng sarili nitong mga workspace at ng ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Inililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo sa monitor sa direksyong iyon, sa workspace na ipinapakita nito, at inililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo sa monitor sa direksyong iyon, kung saan kinukuha nito ang parehong numero kung bakante iyon. Pinananatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa saksakan: sumasama ang mga ito sa ibang screen, na binibilang pagkatapos ng mga mayroon na iyon, at bumabalik sa ilalim ng dati nilang mga numero kapag bumalik ang monitor.

Kung hahawakan mo ang `Super` at gagamitin ang mouse para mag-click sa isang window, magagawa mong muling ayusin kung saan ito nakaupo. Kung hahawakan mo ang `Super` at gagamitin ang kanang button sa mouse, malaya mong mababago ang laki ng window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Maaari ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (na pinananatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (maganda para sa YouTube!).

### Dwindle vs scrolling layout

Ang default na layout ng Omarchy ay tinatawag na dwindle. Pinananatili nitong nakikita sa lahat ng oras ang lahat ng window na binubuksan mo sa isang workspace, kahit pa kailangan nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ngunit maaari mo ring piliing gawing scrolling layout ang isang workspace kung saan ang mga window ay nakahilera nang magkatabi, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang isang workspace sa pamamagitan ng `Super + L`.

Ang pagpindot ulit sa `Super + L` ay ginagawang floating ang workspace, kung saan malayang nagpapatong-patong ang mga window at ikaw mismo ang naglalagay sa mga ito, at ang ikatlong pagpindot ay ibinabalik ito sa dwindle. Ang `Super + Alt + L` ay dumadaan sa mga ito sa kabilang direksyon. Ang isang window na floating na talaga — isa na inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang floating — ay nananatiling floating kapag bumalik ang workspace sa tiling. Minamarkahan ng top bar ang workspace na kinaroroonan mo ng layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Iniikot din ng pag-click sa markang iyon ang layout, at gayundin ang display key sa mga laptop na mayroon nito.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya maaari mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik sila nang ganoon pagkatapos ng restart.

Kung nais mong gamitin ang scrolling layout bilang default, maaari mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating na workspace

Gumagana ang isang floating na workspace tulad ng tradisyunal na desktop: nagpapatong-patong ang mga window, at ikaw mismo ang naglilipat at nagpapalaki o nagpapaliit sa mga ito. Bawat window ay nagkakaroon ng titlebar sa mga kulay ng iyong theme, na may mga button para i-minimize, i-maximize, at isara. Mini-minimize din ng `Super + M` ang naka-focus na window. Ang isang naka-minimize na window ay naghihintay sa dock; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa harap. Baguhin ang laki nito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang pinananatiling nakikita ang top bar, at ulitin para maibalik ang dati nitong laki. Nilalaktawan ng Chrome at iba pang mga browser na nakabase sa Chromium, ng Disks at ng Document Viewer ang titlebar at ginagamit ang sarili nilang header sa halip; mini-maximize sila ng `Super + Alt + F`, at mini-minimize sila ng `Super + M`.

Bawat workspace ay may dock, kasama ang iyong mga naka-pin na app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa menu ng Omarchy. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin sa harap ang window nito; i-click ulit para umikot sa mga window nito. Ibinabalik lang ng Files ang isang window mula sa workspace na kinaroroonan mo at kung hindi ay nagbubukas ng bago, at palaging nagsisimula ng isa pa ang Terminal at Agent, bagaman nauunang bumalik ang isang naka-minimize na window. Ang middle-click ay nagbubukas ng bagong window. I-drag ang isang icon sa kahabaan ng dock para ilipat ito; ang pag-drag ng isang tumatakbong app sa gitna ng iba ay pinananatili ito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito, o i-quit ito. Nananatiling nakalabas ang dock habang walang laman ang isang workspace, at kapag nagkaroon na ng window ang workspace ay nagtatago ito hanggang sa maabot ng pointer ang gilid nito. Ganap itong itinatago ng isang fullscreen na window. I-drag ang apps button patungo sa ibang gilid ng screen para ilipat doon ang dock. I-right-click ito para sa _Position_, para pumili ng gilid, _Layout_, para itakda ang default na layout tulad ng ginagawa ng _Appearance > Workspace Layout_, at _Visibility_, para panatilihing laging nakabukas ang dock, hayaang itago ito ng unang app, o panatilihin itong laging nakatago. Itinatakda iyon ng `omarchy dock visibility always` mula sa terminal. Ang posisyon ay nasa ilalim din ng _Appearance > Dock > Dock Position_, at itinatakda ito ng `omarchy dock position left` mula sa terminal. Ang mga app na pinananatili mo sa dock ay kupas habang hindi sila tumatakbo. Para panatilihin ang dock sa mga floating na workspace lang, gamitin ang _Appearance > Dock > Dock Only on Floating_ o `omarchy dock tiling off`.

Ang mga bagong workspace, at anumang hindi mo pa binigyan ng sarili nilang layout gamit ang `Super + L`, ay gumagamit ng default na layout. Ang pagbabago sa default ay nagre-reset dito sa bawat workspace na walang mga window, habang ang may mga window dito ay pinananatili ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy hyprland workspace layout default scrolling` mula sa terminal.

### Pagpapangkat ng mga window

Maaaring ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Maaari kang lumipat sa pagitan ng mga nakagrupong window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para direktang pumunta sa mga nakagrupong window ayon sa pagkakasunod-sunod.

Maaari mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng pagpindot ulit sa `Super + G`. Sa huli, maaari mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Paglalabas ng mga window

Maaari mong ilabas ang isang window mula sa alokasyon nito sa workspace gamit ang `Super + O`. Ipi-pin nito iyon bilang isang floating na window na sumusunod sa iyo sa anumang workspace na puntahan mo. Mahusay para sa mga video player at mga katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

Mayroong isang espesyal na full-size na scratchpad workspace na nagpapatong sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo ang naroon gamit ang `Super + S`, at naglalagay ka ng mga window doon gamit ang `Super + Alt + S`.

Mahusay itong gumagana para sa mga control o isang terminal na gusto mong mabilis na gamitin nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Sa huli, mayroong isang half-height na Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + the key above Tab` (grave sa mga US layout), at maglagay ng window doon gamit ang `Super + Shift + the key above Tab`.

Sa unang pagbukas nito, sinisimulan nito ang iyong default na agent, o hihilingin sa iyong pumili ng isa kung hindi ka pa nakakapili. Habang isang window lang ang laman ng console, bumababa ito bilang isang panel na nakagitna imbes na sumaklaw sa screen. Maglagay ng pangalawang app dito at babalik ito sa buong lapad, para magkaroon ng puwang ang dalawa na magkatabi.

Para ilipat ang isang window palabas ng scratchpad o ng console, ipadala ito nang direkta sa ibang workspace gamit ang tulad ng `Super + Shift + 1`.

### Kailangan lang masanay!

Medyo matatagalan bago masanay sa ganitong paraan ng paglalakbay sa iyong desktop, pero kapag nasanay ka na, mahihirapan ka nang bumalik sa tradisyunal na karanasan sa desktop na pinapatakbo ng mouse!
