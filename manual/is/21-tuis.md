# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er yndislegur valkostur í stað forrits eins og GitHub Desktop, og það keyrir í útstöðinni.

Þú getur keyrt það beint með því að fara í hvaða möppu sem er undir stjórn git og keyra `lazygit`. Eða þú getur keyrt það inni í Neovim, þar sem hægt er að ræsa það með `Space G G`.

Þú hoppar á milli hinna ýmsu rúðna með `Tab`. Í Files-rúðunni velur þú skrár til að undirbúa með `Space`, og svo getur þú búið til nýja færslu með `c`. Þú getur séð allar tiltækar skipanir með `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er fallegur auðlindastjóri sem sýnir notkun minnis, CPU, disks og nets. Hann listar líka öll virk ferli og gerir þér kleift að stjórna þeim.

Omarchy kallar hann Activity Monitor, og þú ræsir hann úr forritaræsinum eða með því að ýta á `Super + Shift + T`. Hann opnast sem fljótandi gluggi, sem þú getur sett í flísalag með `Super + T`.

## Herdr

[Herdr](https://herdr.dev) er vinnusvæðastjóri fyrir útstöð sem gefur þér vinnusvæði, flipa og rúður, og heldur þeim öllum gangandi í viðvarandi setu sem þú getur aftengst og komið aftur í síðar.

Þú ræsir hann (eða tengist aftur við setuna þína) úr forritaræsinum eða með `Super + Ctrl + Return`. Omarchy fylgir með Herdr-stillingu sem endurspeglar Tmux-stillingarnar, svo forskeytislykillinn er `Ctrl + Space` hér líka. Þú getur skoðað allar lyklabindingar með `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) sýnir upplýsingar um kerfið, svo sem kjarnaútgáfu, uppitíma, þema, CPU, minni og fleira. Hann er arftaki hins vinsæla neofetch-tóls.

Omarchy hefur pakkað þessu sem _System > About_ í Omarchy-valmyndinni (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er retro tónlistarspilari fyrir útstöð, innblásinn af Winamp 2.x, með innbyggðum útvarpsstöðvum fyrir lo-fi tóna. Ræstu hann með `Super + Shift + Alt + M`, eða úr Omarchy-valmyndinni undir _Apps_. Ýttu á `?` til að fá heildarlistann yfir lyklabindingar.

## Hvað með Wi-Fi og Bluetooth?

Þú finnur engin TUI fyrir Wi-Fi og Bluetooth — þau verk tilheyra Omarchy-skelinni. Smelltu á Wi-Fi táknið á efstu stikunni (eða ýttu á `Super + Ctrl + N`) til að sjá net og tengjast, og smelltu á Bluetooth táknið (eða ýttu á `Super + Ctrl + B`) til að para og tengja tæki. Sjá [netkerfi](35-networking.md) fyrir alla söguna.

## Að bæta við eigin

Öll útstöðvarforrit geta fengið fulla forritsmeðferð. Farðu í _Install > TUI_ í Omarchy-valmyndinni (`Super + Space`), gefðu því nafn, ræsiskipun, gluggastíl og tákn, og það birtist í forritaræsinum eins og hvert annað forrit. Þú getur fjarlægt það aftur undir _Remove > TUI_.
