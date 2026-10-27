# Nabigasyon

Lahat sa Omarchy ay nangyayari sa pamamagitan ng keyboard — _LAHAT-LAHAT!_ Kapag unang nag-start ang system, literal na wala kang magagawa gamit lang ang mouse. Pero puwede mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito ay magagawa mo na ang halos lahat.

Pero hindi man lang nilalayon ang Omarchy menu na maging pangunahing paraan ng pagpapatakbo ng system sa halos lahat ng oras. Puwede tayong maging mas mabilis pa riyan! Lahat ng pinakamahahalagang application ay direktang nakatali sa kani-kaniyang hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang browser gamit ang `Super + Shift + Return`. Subukang gawin ang isa pagkatapos ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland sa aksyon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pagkatapos ay puwede mong pindutin ang `Super + J` para patung-patungin sila sa halip na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon ay subukan ang `Super + Shift + T` para simulan ang Activity monitor. Lalabas iyon bilang floating window. Puwede mo itong i-tile gamit ang `Super + T` (at pindutin ulit iyon para gawin ulit itong floating). Ngayon ay pindutin ang `Super + Shift + F` para buksan ang files manager. Magkakaroon ka ng maayos na four-way setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Naglalakbay ka sa pagitan ng mga window para piliin kung alin ang magiging aktibo gamit ang `Super + Arrow`. Lilipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, tutuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application sa ikalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application sa ikalawang workspace nang hindi lumilipat papunta roon).

Kapag higit sa isa ang monitor, bawat monitor ay may sarili nitong workspaces 1 hanggang 10. Pupunta ang `Super + 2` sa ikalawang workspace ng monitor na kinaroroonan mo, at ipinapakita ng top bar ng bawat monitor ang sarili nitong mga workspace at ang kasalukuyang ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Inililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo papunta sa monitor sa direksyong iyon, sa workspace na ipinapakita nito, at inililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo papunta sa monitor sa direksyong iyon, kung saan kukunin nito ang parehong numero kung bakante iyon. Pinapanatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa saksakan: sumasama ang mga ito sa isa pang screen, na binibilang pagkatapos ng mga mayroon na ito, at bumabalik sa dati nilang mga numero kapag bumalik ang monitor.

Kung hahawakan mo ang `Super` at gagamitin ang mouse para mag-click sa isang window, magagawa mong muling ayusin kung saan ito nakaupo. Kung hahawakan mo ang `Super` at gagamitin ang kanang button ng mouse, malaya mong mababago ang laki ng window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Puwede ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (na pinapanatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (mabuti para sa YouTube!).

### Layout na dwindle vs scrolling

Ang default layout ng Omarchy ay tinatawag na dwindle. Pinapanatili nitong nakikita sa lahat ng oras ang lahat ng window na binubuksan mo sa iisang workspace, kahit kailangan pa nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero puwede mo ring piliing gawing scrolling layout ang isang workspace kung saan nakahilera ang mga window nang magkatabi, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang iisang workspace sa pamamagitan ng `Super + L`.

Ang pagpindot ulit sa `Super + L` ay gagawing floating ang workspace, kung saan malayang nagpapatong-patong ang mga window at ikaw mismo ang naglalagay sa mga ito, at ang ikatlong pagpindot ay ibabalik ito sa dwindle. Ang `Super + Alt + L` ay dumaraan sa mga ito sa kabilang direksyon. Ang window na floating na talaga — isa na inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang floating — ay mananatiling floating kapag bumalik sa tiling ang workspace. Minamarkahan ng top bar ang workspace na kinaroroonan mo gamit ang layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Ang pag-click sa markang iyon ay nagpapaikot din sa layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya puwede mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik ang mga ito sa ganoong ayos pagkatapos ng restart.

Kung gusto mong gamitin ang scrolling layout bilang default, puwede mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating workspace

Gumagana ang isang floating workspace tulad ng tradisyonal na desktop: nagpapatong-patong ang mga window, at ikaw mismo ang naglilipat at nagpapalaki o nagpapaliit sa mga ito. Bawat window ay nagkakaroon ng titlebar sa mga kulay ng theme mo, na may mga button para mag-minimize, mag-maximize, at magsara. Mini-minimize rin ng `Super + M` ang naka-focus na window. Naghihintay sa dock ang isang naka-minimize na window; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa harapan. Baguhin ang laki nito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang pinapanatiling nakikita ang top bar, at ulitin para maibalik ang dati nitong laki.

Nagpapakita rin ang isang floating workspace ng dock, kasama ang mga naka-pin mong app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa Omarchy menu. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin sa harapan ang window nito; i-click ulit para umikot sa mga window nito. Nagbubukas ang middle-click ng bagong window. I-drag ang isang icon sa kahabaan ng dock para ilipat ito; ang pag-drag sa isang tumatakbong app papasok sa pagitan ng iba ay magpapanatili rito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito roon, o isara ito. Umiwas ang dock sa isang fullscreen window. I-right-click ang apps button para ilipat ang dock sa ibang gilid o para itago ito hanggang maabot ng pointer ang gilid nito. Ang posisyon ay nasa ilalim din ng _Appearance > Dock > Dock Position_, at itinatakda ng `omarchy dock position left` at `omarchy dock autohide on` ang dalawa mula sa isang terminal. Ang mga app na pinapanatili mo sa dock ay kupas habang hindi tumatakbo ang mga ito.

Ang mga bagong workspace, at anumang hindi mo pa binibigyan ng sarili nitong layout gamit ang `Super + L`, ay gumagamit ng default layout. Ang pagpapalit ng default ay nagre-reset sa bawat workspace na walang window papunta rito, habang ang may mga window ay pinapanatili ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy-hyprland-workspace-layout-default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Puwedeng ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Puwede kang lumipat sa pagitan ng mga nakapangkat na window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para direktang pumunta sa nakapangkat na window ayon sa pagkakasunod-sunod.

Puwede mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng pagpindot ulit sa `Super + G`. Panghuli, puwede mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Pag-pop out ng mga window

Puwede mong ilabas ang isang window mula sa pagkakatalaga nito sa workspace gamit ang `Super + O`. Ipi-pin nito ito bilang floating window na sumusunod sa iyo sa anumang workspace na puntahan mo. Mahusay para sa mga video player at katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

May espesyal na full-size scratchpad workspace na nag-o-overlay sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo kung ano ang naroroon gamit ang `Super + S`, at naglalagay ka ng mga window roon gamit ang `Super + Alt + S`.

Mahusay itong gumagana para sa mga control o isang terminal na gusto mong mabilis na gamitin nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Panghuli, may half-height Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + Grave`, at maglagay ng window roon gamit ang `Super + Shift + Grave`.

Bumubukas ito na handa nang gamitin ang default agent mo. Habang iisang window lang ang laman ng console, bumababa ito bilang nakagitnang panel sa halip na sumakop sa buong screen. Maglagay ng ikalawang app dito at babalik ito sa buong lapad, para magkaroon ng puwang ang dalawa na magkatabi.

Para ilipat ang isang window palabas ng scratchpad o ng console, ipadala ito nang direkta sa ibang workspace gamit ang tulad ng `Super + Shift + 1`.

### Kailangan ng kaunting pagsasanay!

Kailangan ng kaunting panahon para masanay sa pag-navigate sa desktop mo nang ganito, pero kapag nasanay ka na, mahihirapan ka nang bumalik sa tradisyonal na karanasang desktop na pinapatakbo ng mouse!
