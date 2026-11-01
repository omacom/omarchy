# Nabigasyon

Lahat sa Omarchy ay nangyayari sa pamamagitan ng keyboard — _LAHAT!_ Kapag unang nag-start ang system, literal na wala kang magagawa gamit lang ang mouse. Pero puwede mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito ay magagawa mo na ang halos lahat ng bagay.

Pero hindi pa nga nilalayon ang Omarchy menu na maging pangunahing paraan ng pagpapatakbo ng system sa karamihan ng oras. Puwede tayong maging mas mabilis pa riyan! Lahat ng pinakamahahalagang application ay direktang naka-bind sa indibidwal na mga hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang browser gamit ang `Super + Shift + Return`. Subukang gawin ang isa pagkatapos ang isa pa, at makikita mo ang mahika ng tiling ng Hyprland sa aksyon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Puwede mo nang pindutin ang `Super + J` para pagpatung-patungin sila sa ibabaw ng isa't isa imbes na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon subukan ang `Super + Shift + T` para simulan ang Activity monitor. Lalabas iyon bilang isang lumulutang na window. Puwede mo itong i-tile gamit ang `Super + T` (at pindutin ulit iyon para gawin ulit itong lumulutang). Ngayon pindutin ang `Super + Shift + F` para buksan ang file manager. Magkakaroon ka ng maayos na four-way na setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Maglalakbay ka sa pagitan ng window na gusto mong maging aktibo gamit ang `Super + Arrow`. Ililipat nito ang focus at ililipat ang cursor sa gitna ng bagong application. Sa gilid ng isang screen, tutuloy ito sa monitor sa panig na iyon.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application papunta sa pangalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application papunta sa pangalawang workspace nang hindi lumilipat papunta rito).

Sa higit sa isang monitor, ang bawat monitor ay may sarili nitong workspace 1 hanggang 10. Pumupunta ang `Super + 2` sa pangalawang workspace ng monitor na kinaroroonan mo, at ipinapakita ng top bar ng bawat monitor ang sarili nitong mga workspace at ang ipinapakita nito. Iniikot ng `Super + Tab` ang mga workspace sa monitor na kinaroroonan mo. Inililipat ng `Super + Shift + Ctrl + Arrows` ang window na kinaroroonan mo papunta sa monitor sa direksyong iyon, papunta sa workspace na ipinapakita nito, at inililipat ng `Super + Shift + Alt + Arrows` ang workspace na kinaroroonan mo papunta sa monitor sa direksyong iyon, kung saan kukunin nito ang parehong numero kung bakante ito. Pinapanatili ng isang monitor ang mga workspace nito kapag tinanggal mo ito sa saksakan: sumasali ang mga ito sa iba pang screen, na binibilang pagkatapos ng mga mayroon na ito, at bumabalik sa ilalim ng kanilang lumang numero kapag bumalik ang monitor.

Kung hahawakan mo ang `Super` at gagamitin ang mouse para mag-click sa isang window, magagawa mong muling ayusin kung saan ito nakaupo. Kung hahawakan mo ang `Super` at gagamitin ang kanang button sa mouse, malaya mong mai-resize ang window.

Isinasara mo ang isang window gamit ang `Super + W` o `Super + Q` (at isinasara ang lahat ng window gamit ang `Ctrl + Alt + Delete`).

Puwede ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (pinapanatili ang top bar) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (maganda para sa YouTube!).

### Dwindle vs scrolling layout

Ang default layout ng Omarchy ay tinatawag na dwindle. Pinapanatili nitong nakikita sa lahat ng oras ang lahat ng window na binubuksan mo sa isang workspace, kahit kailangan nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero puwede mo ring piliing gawing scrolling layout ang isang workspace kung saan ang mga window ay nakahilera nang magkatabi, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang isang workspace sa pamamagitan ng `Super + L`.

Ang muling pagpindot sa `Super + L` ay ginagawang lumulutang ang workspace, kung saan malayang nagpapatong-patong ang mga window at ikaw mismo ang naglalagay sa kanila, at ang pangatlong pagpindot ay ibinabalik ito sa dwindle. Ang `Super + Alt + L` ay dumadaan sa mga ito sa kabaligtarang direksyon. Ang isang window na lumulutang pa rin — isa na inilabas mo gamit ang `Super + T`, o isang app na palaging bumubukas nang lumulutang — ay nananatiling lumulutang kapag bumalik ang workspace sa tiling. Minamarkahan ng top bar ang workspace na kinaroroonan mo ng layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Ang pag-click sa markang iyon ay nagpapaikot din sa layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya puwede mong panatilihin ang workspace 1 sa dwindle para sa pagba-browse at ang workspace 2 sa scrolling para sa code, at babalik sila sa ganoong paraan pagkatapos ng isang restart.

Kung nais mong gamitin ang scrolling layout bilang default, puwede mong itakda iyon sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga lumulutang na workspace

Gumagana ang isang floating workspace tulad ng tradisyonal na desktop: nagpapatong-patong ang mga window, at ikaw mismo ang naglilipat at nagtatakda ng laki ng mga ito. Nakakakuha ang bawat window ng titlebar sa mga kulay ng iyong theme, na may mga button para mag-minimize, mag-maximize, at magsara. Mini-minimize din ng `Super + M` ang naka-focus na window. Naghihintay sa dock ang isang naka-minimize na window; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa harapan. I-resize ito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang pinapanatiling nakikita ang top bar, at ulitin para maibalik ang lumang laki nito.

Nagpapakita rin ang isang floating workspace ng dock, kasama ang iyong mga naka-pin na app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa Omarchy menu. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin sa harapan ang window nito; i-click ulit para umikot sa mga window nito. Ang middle-click ay nagbubukas ng bagong window. I-drag ang isang icon sa kahabaan ng dock para ilipat ito; ang pag-drag ng isang tumatakbong app sa gitna ng iba pa ay pinapanatili ito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito, o isara ito. Lumalayo ang dock sa daan ng isang fullscreen na window. I-right-click ang apps button para ilipat ang dock sa ibang gilid o para itago ito hanggang sa maabot ng pointer ang gilid nito. Nasa ilalim din ng _Appearance > Dock > Dock Position_ ang posisyon, at itinatakda ng `omarchy dock position left` at `omarchy dock autohide on` ang dalawa mula sa isang terminal. Ang mga app na pinapanatili mo sa dock ay kupas habang hindi sila tumatakbo.

Ang mga bagong workspace, at anumang hindi mo pa binibigyan ng sarili nitong layout gamit ang `Super + L`, ay gumagamit ng default layout. Ang pagpapalit ng default ay nagre-reset sa bawat workspace na walang window papunta rito, habang ang isang may mga window dito ay pinapanatili ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy-hyprland-workspace-layout-default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Puwedeng ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Puwede kang lumipat sa pagitan ng mga nakagrupong window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para direktang pumunta sa mga nakagrupong window nang magkakasunod.

Puwede mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng muling pagpindot sa `Super + G`. Sa wakas, puwede mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Paglalabas ng mga window

Puwede mong ilabas ang isang window mula sa alokasyon nito sa workspace gamit ang `Super + O`. Ipi-pin nito ito bilang isang lumulutang na window na sumusunod sa iyo sa anumang workspace na pupuntahan mo. Maganda para sa mga video player at katulad nito.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad workspace

May isang espesyal na full-size na scratchpad workspace na nagpapatong sa anumang workspace na kasalukuyan mong kinaroroonan. Ina-access mo ang nasa loob nito gamit ang `Super + S`, at naglalagay ka ng mga window roon gamit ang `Super + Alt + S`.

Mahusay itong gumagana para sa mga control o isang terminal na gusto mong mabilis na gamitin nang hindi umaalis sa kasalukuyang workspace.

### Quake console

Sa wakas, may isang half-height na Quake console na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan. I-toggle ito gamit ang `Super + Grave`, at maglagay ng window roon gamit ang `Super + Shift + Grave`.

Bumubukas ito kasama ang iyong default agent na handa nang gamitin. Habang isang window lang ang laman ng console, bumababa ito bilang isang panel na nasa gitna imbes na sumasaklaw sa screen. Maglagay ng pangalawang app dito at babalik ito sa buong lapad, para may puwang ang dalawa na magkatabi.

Para ilipat ang isang window palabas ng scratchpad o ng console, ipadala ito nang direkta sa ibang workspace gamit ang tulad ng `Super + Shift + 1`.

### Kailangan lang masanay!

Kailangan ng kaunting panahon para masanay sa pag-navigate sa iyong desktop nang ganito, pero kapag nasanay ka na, mahihirapan ka nang bumalik sa tradisyonal na karanasang desktop na pinapatakbo ng mouse!
