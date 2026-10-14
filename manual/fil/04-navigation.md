# Nabigasyon

Lahat sa Omarchy ay nangyayari sa pamamagitan ng keyboard — _LAHAT!_ Kapag unang nagsimula ang sistema, literal na wala kang magagawa gamit lang ang mouse. Pero maaari mong pindutin ang `Super + Space` para ipakita ang Omarchy Menu at mula rito ay magagawa mo na ang halos lahat ng bagay.

Pero ang menu ng Omarchy ay hindi pa nga nilalayong maging pangunahing paraan ng pagpapatakbo ng sistema sa karamihan ng panahon. Mas makakabilis pa tayo kaysa roon! Lahat ng pinakamahalagang application ay direktang nakatali sa mga indibidwal na hotkey. Sinisimulan mo ang terminal gamit ang `Super + Return` at ang isang browser gamit ang `Super + Shift + Return`. Subukang gawin ang isa pagkatapos ng isa pa, at makikita mo ang mahika ng tiling ng Hyprland na kumikilos:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Maaari mo nang pindutin ang `Super + J` para pagpatung-patungin sila sa ibabaw ng isa't isa sa halip na magkatabi:

 ![navigation-stacked](images/navigation-stacked.webp)

Pindutin ulit ang `Super + J` para ibalik sila sa kanilang magkatabing posisyon. Pagkatapos ay subukan ang `Super + Shift + Arrow Right` habang nasa browser para pagpalitin ang mga window.

Ngayon subukan ang `Super + Ctrl + T` para simulan ang Activity monitor. Lilitaw iyon bilang isang floating na window. Maaari mo itong i-tile gamit ang `Super + T` (at pindutin iyon ulit para gawin itong floating ulit). Ngayon pindutin ang `Super + Shift + F` para buksan ang files manager. Magkakaroon ka ng maayos na four-way na setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Nag-na-navigate ka sa pagitan ng window na gusto mong maging aktibo gamit ang `Super + Arrow`. Ililipat nito ang focus at ililipat ang cursor sa gitna ng bagong application.

Kung pipindutin mo ang `Super + Shift + 2`, ililipat mo ang kasalukuyang naka-focus na application papunta sa ikalawang workspace. Ibinabalik ito ng `Super + Shift + 1`. (At ililipat ng `Super + Shift + Alt + 2` ang kasalukuyang naka-focus na application papunta sa ikalawang workspace nang hindi lumilipat papunta rito).

Kung hahawakan mo ang `Super` at gagamitin ang mouse para mag-click sa isang window, magagawa mong muling ayusin kung saan ito nakaupo. Kung hahawakan mo ang `Super` at gagamitin ang kanang button sa mouse, malaya mong mababago ang laki ng window.

Isinasara mo ang isang window sa `Super + W` o `Super + Q` (at isinasara ang lahat ng window sa `Ctrl + Alt + Delete`).

Maaari ka ring mag-full screen gamit ang `Super + F` o kahit full-width lang (pinapanatili ang bar sa itaas) gamit ang `Super + Alt + F` o full-screen sa loob ng isang window gamit ang `Super + Ctrl + F` (mabuti para sa YouTube!).

### Dwindle vs scrolling na layout

Ang default na layout ng Omarchy ay tinatawag na dwindle. Pinapanatili nitong nakikita sa lahat ng oras ang lahat ng window na binuksan mo sa isang workspace, kahit pa kailangan nitong paliitin ang mga ito.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Pero maaari mo ring piliing gawing scrolling na layout ang isang workspace kung saan ang mga window ay nakahanay nang magkatabi, lampas sa nakikitang gilid ng display. Ginagawa mong ganitong layout ang isang workspace sa pamamagitan ng `Super + L`.

Ang pagpindot ulit sa `Super + L` ay ginagawang floating ang workspace, kung saan malayang nagpapatong-patong ang mga window at ikaw mismo ang naglalagay sa kanila, at ang ikatlong pagpindot ay ibinabalik ito sa dwindle. Ang `Super + Alt + L` ay dumaraan sa kanila sa kabilang direksyon. Ang isang window na floating na rin naman — isa na inilabas mo gamit ang `Super + T`, o isang app na laging bumubukas nang floating — ay nananatiling floating kapag bumalik ang workspace sa tiling. Minamarkahan ng bar sa itaas ang workspace na kinaroroonan mo kasama ang layout nito: isang parisukat para sa dwindle, isang bilog para sa scrolling, at isang tatsulok para sa floating. Ang pag-click sa markang iyon ay nagpapalipat-lipat din sa layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Ang pagpili ay bawat workspace, at nananatili ito. Kaya maaari mong panatilihin ang workspace 1 sa dwindle para sa pag-browse at ang workspace 2 sa scrolling para sa code, at babalik sila nang ganoon pagkatapos ng isang restart.

Kung nais mong gamitin ang scrolling na layout bilang default, maaari mo iyon itakda sa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Mga floating na workspace

Ang isang floating na workspace ay gumagana tulad ng isang tradisyonal na desktop: nagpapatong-patong ang mga window, at ikaw mismo ang naglilipat at nagbabago ng laki ng mga ito. Bawat window ay nakakakuha ng titlebar sa mga kulay ng iyong tema, na may mga button para mag-minimize, mag-maximize, at magsara. Pina-minimize rin ng `Super + M` ang naka-focus na window. Ang isang naka-minimize na window ay naghihintay sa dock; i-click ang app nito para ibalik ito. I-click ang isang window para dalhin ito sa unahan. Baguhin ang laki nito mula sa anumang gilid o sulok. I-double-click ang isang titlebar para i-maximize ang window habang pinapanatiling nakikita ang bar sa itaas, at ulit para maibalik ang dati nitong laki.

Ang isang floating na workspace ay nagpapakita rin ng isang dock, kasama ang iyong mga naka-pin na app, lahat ng tumatakbo, at isang grid ng bawat app sa likod ng apps na button, na binubuksan din ng `Super + Alt + Space` at ng _Apps_ sa menu ng Omarchy. I-right-click ang isang app sa grid, o pindutin ang `Delete`, para i-uninstall ito. I-click ang isang app para buksan ito, o para dalhin ang window nito sa unahan; i-click ulit para magpalipat-lipat sa mga window nito. Ang middle-click ay nagbubukas ng bagong window. I-drag ang isang icon sa haba ng dock para ilipat ito; ang pag-drag sa isang tumatakbong app papasok sa gitna ng iba pa ay pinapanatili ito roon. I-right-click para panatilihin ang isang app sa dock, alisin ito, o isara ito. Umiwas ang dock sa daan ng isang fullscreen na window. I-right-click ang apps na button para ilipat ang dock sa ibang gilid o para itago ito hanggang maabot ng pointer ang gilid nito. Ang posisyon ay nasa ilalim din ng _Trigger > Appearance > Dock > Dock Position_, at itinatakda ng `omarchy dock position left` at `omarchy dock autohide on` ang dalawa mula sa isang terminal. Ang mga app na pinapanatili mo sa dock ay malabo habang hindi sila tumatakbo.

Ang mga bagong workspace, at anumang hindi mo pa binigyan ng sariling layout gamit ang `Super + L`, ay gumagamit ng default na layout. Ang pagpapalit sa default ay nire-reset ang bawat workspace na walang mga window papunta rito, habang ang isang may mga window dito ay pinapanatili ang layout na mayroon ito. Ang isang window na naka-minimize sa dock ay binibilang pa rin bilang isang window sa workspace na iniwan nito. Piliin ito sa ilalim ng _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling, o Floating. Itinatakda ito ng `omarchy-hyprland-workspace-layout-default scrolling` mula sa isang terminal.

### Pagpapangkat ng mga window

Maaaring ipangkat ang mga window gamit ang `Super + G`. Kapag nasa isang grupo ka na, bawat window na sisimulan mo habang aktibo iyon ay mapapabilang sa grupo. Maaari kang lumipat sa pagitan ng mga nakapangkat na window na ito gamit ang `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` para direktang pumunta sa nakapangkat na window ayon sa pagkakasunod-sunod.

Maaari mong ilipat ang isang window palabas ng pagpapangkat gamit ang `Super + Alt + G` o buwagin ang buong grupo sa pamamagitan ng pagpindot ulit sa `Super + G`. Panghuli, maaari mong ilipat ang mga window sa labas ng grupo papasok dito gamit ang `Super + Alt + Arrows`.

### Pag-pop ng mga window

Maaari mong i-pop ang isang window palabas ng alokasyon nito sa workspace gamit ang `Super + O`. Ipi-pin nito iyon bilang isang floating na window na sumusunod sa iyo sa anumang workspace na puntahan mo. Mahusay para sa mga video player at mga katulad niyon.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad na workspace

Panghuli, mayroong isang espesyal na scratchpad na workspace na bumababa sa ibabaw ng anumang workspace na kasalukuyan mong kinaroroonan, katulad ng isang Quake console. I-toggle ito gamit ang `Super + Grave` o `Super + S`, at maglagay ng isang window roon gamit ang `Super + Shift + Grave` o `Super + Alt + S`.

Partikular itong gumagana nang mahusay para sa isang terminal na nagpapatakbo ng isang agent, o para sa mga kontrol na gusto mong mabilis na makipag-ugnayan nang hindi umaalis sa kasalukuyang workspace. Para ilipat ang isang window mula sa scratchpad, direktang ipadala ito sa ibang workspace gamit ang isang bagay tulad ng `Super + Shift + 1`.

Habang ang scratchpad ay naglalaman ng isang window lang, bumababa ito bilang isang naka-sentrong panel sa halip na sumasaklaw sa screen. Maglagay ng ikalawang app dito at babalik ito sa buong lapad, para magkaroon ng espasyo ang dalawa na umupo nang magkatabi.

### Kailangan itong masanay!

Kailangan ng kaunting panahon para masanay sa pag-navigate sa iyong desktop nang ganito, pero kapag nasanay ka na, mahirap nang bumalik sa isang tradisyonal na karanasan sa desktop na pinapatakbo ng mouse!
