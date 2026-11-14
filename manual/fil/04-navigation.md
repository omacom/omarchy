# Nabigasyon

Lahat sa Omarchy ay ginagawa sa pamamagitan ng keyboard — _LAHAT-LAHAT!_ Pagka-start pa lang ng system, literal na wala kang magagawa gamit lang ang mouse. Pero pwede mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito, magagawa mo na halos lahat.

Ngunit hindi pa nga nilalayon na ang Omarchy menu ang pangunahing paraan ng paggamit ng system sa karamihan ng oras. Kaya nating maging mas mabilis pa riyan! Lahat ng pinakamahahalagang application ay direktang naka-bind sa kanya-kanyang hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang browser gamit ang `Super + Shift + Return`. Subukan mong gawin ang isa pagkatapos ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland na kumikilos:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pagkatapos ay pwede mong pindutin ang `Super + J` para pagpatung-patungin sila sa halip na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon subukan ang `Super + Shift + T` para simulan ang Activity monitor. Lalabas iyon bilang floating na window. Pwede mo itong i-tile gamit ang `Super + T` (at pindutin ulit iyon para gawin ulit itong floating). Ngayon pindutin ang `Super + Shift + F` para buksan ang file manager. Magkakaroon ka ng maayos na four-way na setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Nagna-navigate ka sa pagitan ng window na gusto mong maging active gamit ang `Super + Arrow`. Ililipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, nagpapatuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application sa pangalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application sa pangalawang workspace nang hindi lumilipat dito).

Kapag may mahigit sa isang monitor, bawat monitor ay may sariling workspace 1 hanggang 10. Pupunta ang `Super + 2` sa pangalawang workspace ng monitor na kinaroroonan mo, at ipinapakita ng top bar ng bawat monitor ang sarili nitong mga workspace at ang ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Ililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo sa monitor sa direksyong iyon, sa workspace na ipinapakita nito, at ililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo sa monitor sa direksyong iyon, kung saan kinukuha nito ang parehong numero kung bakante iyon. Pinapanatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa saksakan: sumasali ang mga ito sa iba pang screen, na binibilang pagkatapos ng mga mayroon na ito, at bumabalik sa dati nilang mga numero kapag bumalik ang monitor.

Kung pipindutin mo nang matagal ang `Super` at gagamitin ang mouse para mag-click sa isang window, maaayos mo ulit kung saan ito nakaupo. Kung pipindutin mo nang matagal ang `Super` at gagamitin ang kanang button ng mouse, malaya mong mai-resize ang window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Pwede ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (pinapanatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (maganda para sa YouTube!).

### Layout na dwindle vs scrolling

Ang default na layout ng Omarchy ay tinatawag na dwindle. Pinapanatili nitong nakikita sa lahat ng oras ang lahat ng window na binubuksan mo sa iisang workspace, kahit kailangan pa nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ngunit pwede mo ring piliing gawing scrolling layout ang isang workspace kung saan nakahilera ang mga window nang magkatabi, lagpas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang iisang workspace sa pamamagitan ng `Super + L`.

Ang pagpindot ulit sa `Super + L` ay ginagawang floating ang workspace, kung saan malayang nagpapatung-patong ang mga window at ikaw mismo ang naglalagay sa kanila, at ang pangatlong pagpindot ay ibabalik ito sa dwindle. Ang `Super + Alt + L` ay dumadaan sa kanila sa kabaligtarang direksyon. Ang isang window na floating naman talaga — iyong inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang floating — ay nananatiling floating kapag bumalik sa tiling ang workspace. Minamarkahan ng top bar ang workspace na kinaroroonan mo ng layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Ang pag-click sa markang iyon ay nagpapaikot din sa layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpipilian ay kada workspace, at nananatili ito. Kaya pwede mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik sila sa ganoong ayos pagkatapos ng restart.

Kung gusto mong gamitin ang scrolling layout bilang default, pwede mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating na workspace

Ang isang floating na workspace ay gumagana tulad ng tradisyonal na desktop: nagpapatung-patong ang mga window, at ikaw mismo ang naglilipat at nagpapalaki o nagpapaliit sa kanila. Bawat window ay nakakakuha ng titlebar sa mga kulay ng theme mo, na may mga button para mag-minimize, mag-maximize, at magsara. Mini-minimize rin ng `Super + M` ang naka-focus na window. Ang isang na-minimize na window ay naghihintay sa dock; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa harap. I-resize ito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang nakikita pa rin ang top bar, at ulitin para maibalik ang dati nitong laki. Nilalaktawan ng Chrome at ng iba pang browser na nakabase sa Chromium, ng Disks at ng Document Viewer ang titlebar at ginagamit ang sarili nilang header sa halip; mini-maximize sila ng `Super + Alt + F`, at mini-minimize sila ng `Super + M`.

Nagpapakita rin ang isang floating na workspace ng dock, na may mga naka-pin mong app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa Omarchy menu. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin sa harap ang window nito; i-click ulit para umikot sa mga window nito. Ang middle-click ay nagbubukas ng bagong window. I-drag ang isang icon sa kahabaan ng dock para ilipat ito; ang pag-drag ng isang tumatakbong app papasok sa iba ay pinapanatili ito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito, o i-quit ito. Umiwas ang dock sa isang fullscreen na window. I-right-click ang apps button para ilipat ang dock sa ibang gilid o para itago ito hanggang sa umabot ang pointer sa gilid nito. Ang posisyon ay nasa ilalim din ng _Appearance > Dock > Dock Position_, at itinatakda ng `omarchy dock position left` at `omarchy dock autohide on` ang dalawa mula sa isang terminal. Ang mga app na pinapanatili mo sa dock ay malabo habang hindi sila tumatakbo.

Ang mga bagong workspace, at anumang hindi mo pa binibigyan ng sarili nitong layout gamit ang `Super + L`, ay gumagamit ng default na layout. Ang pagpapalit ng default ay nagre-reset dito sa bawat workspace na walang window, habang ang isang may mga window dito ay pinapanatili ang layout na mayroon ito. Ang isang window na na-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy-hyprland-workspace-layout-default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Pwede mong ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang active iyon ay mapapabilang sa grupo. Pwede kang gumalaw sa pagitan ng mga nakagrupong window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para direktang pumunta sa mga nakagrupong window ayon sa pagkakasunod-sunod.

Pwede mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng pagpindot ulit sa `Super + G`. Panghuli, pwede mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Paglalabas ng mga window

Pwede mong ilabas ang isang window mula sa alokasyon nito sa workspace gamit ang `Super + O`. Ipi-pin nito ito bilang isang floating na window na sumusunod sa iyo sa anumang workspace na puntahan mo. Mahusay para sa mga video player at mga katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace na scratchpad

May isang espesyal na full-size na scratchpad workspace na nagpapatong sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo ang naroon gamit ang `Super + S`, at naglalagay ka ng mga window roon gamit ang `Super + Alt + S`.

Mahusay itong gumagana para sa mga control o isang terminal na gusto mong gamitin nang mabilis nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Panghuli, may isang kalahating-taas na Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + Grave`, at maglagay ng window roon gamit ang `Super + Shift + Grave`.

Bumubukas ito na handa na ang default agent mo. Habang iisang window lang ang laman ng console, bumababa ito bilang isang nakagitnang panel sa halip na sakupin ang buong screen. Maglagay ka ng pangalawang app dito at babalik ito sa buong lapad, para may puwang ang dalawa na magkatabi.

Para ilipat ang isang window mula sa scratchpad o sa console, ipadala ito nang direkta sa ibang workspace gamit ang isang bagay tulad ng `Super + Shift + 1`.

### Kailangan lang masanay dito!

Medyo matatagalan bago ka masanay sa ganitong pag-navigate sa desktop mo, ngunit kapag nasanay ka na, mahihirapan ka nang bumalik sa tradisyonal na karanasang pinapatakbo ng mouse!
