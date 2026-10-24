# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er yndislegur valkostur við eitthvað á borð við GitHub Desktop-forritið, og það keyrir inni í terminalinu.

Þú getur keyrt það beint með því að fara í hvaða möppu sem er sem git stjórnar og keyra `lazygit`. Eða þú getur keyrt það inni í Neovim þar sem hægt er að ræsa það með `Space G G`.

Þú hoppar á milli mismunandi rúða með `Tab`. Í Files-rúðunni velurðu skrár fyrir sviðsetningu með `Space`, og síðan geturðu búið til nýjan commit með `c`. Þú getur séð allar tiltækar skipanir með `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er fallegur auðlindastjóri sem sýnir minnis-, CPU-, diska- og netnotkun. Hann listar líka öll virk ferli og gerir þér kleift að stjórna þeim.

Omarchy kallar það Activity, og þú ræsir það með því að ýta á `Super + Ctrl + T`. Það opnast sem fljótandi gluggi, sem þú getur flísalagt með `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er terminal-vinnusvæðastjóri sem gefur þér vinnusvæði, flipa og rúður, og heldur þeim öllum gangandi í viðvarandi lotu sem þú getur aftengst og komið aftur í síðar.

Þú ræsir það (eða tengist aftur við núverandi lotu þína) með `Super + Ctrl + Return`. Omarchy kemur með Herdr-stillingar sem spegla Tmux-stillingarnar, þannig að forskeytislykillinn er `Ctrl + Space` hér líka. Þú getur skoðað allar flýtilykla með `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) sýnir kerfisupplýsingar, eins og kjarnútgáfu, keyrslutíma, þema, CPU, minni og fleira. Það er arftaki hins vinsæla neofetch-tóls.

Omarchy hefur pakkað þessu sem _Um_ í Omarchy-valmyndinni (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er retro terminal-tónlistarspilari innblásinn af Winamp 2.x, með innbyggðum útvarpsstöðvum fyrir lo-fi takta. Ræstu það með `Super + Shift + Alt + M`, eða úr Omarchy-valmyndinni undir _Forrit_. Ýttu á `?` fyrir heildarlista yfir flýtilykla.

## En hvað með Wi-Fi og Bluetooth?

Þú munt ekki finna TUI fyrir Wi-Fi og Bluetooth — þau störf tilheyra Omarchy-shellinu. Smelltu á Wi-Fi-táknið í efstu stikunni (eða ýttu á `Super + Ctrl + W`) til að sjá net og tengjast, og smelltu á Bluetooth-táknið (eða ýttu á `Super + Ctrl + B`) til að para og tengja tæki. Sjá [net](35-networking.md) fyrir alla söguna.

## Að bæta við þínu eigin

Hvaða terminal-forrit sem er getur fengið fulla forritsmeðferð. Farðu í _Setja upp > TUI_ í Omarchy-valmyndinni (`Super + Space`), gefðu því nafn, ræsingarskipun, gluggastíl og tákn, og það mun birtast í forritaræsinum eins og hvert annað forrit. Þú getur fjarlægt það aftur undir _Fjarlægja > TUI_.
