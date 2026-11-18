# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) er yndislegur valkostur við eitthvað á borð við GitHub Desktop forritið, og það keyrir inni í útstöðinni.

Þú getur keyrt það beint með því að fara í hvaða möppu sem er undir stjórn git og keyra `lazygit`. Eða þú getur keyrt það inni í Neovim þar sem hægt er að ræsa það með `Space G G`.

Þú hoppar á milli mismunandi glugga með `Tab`. Í Files-glugganum velur þú skrár til að setja á biðsvæði með `Space`, og síðan getur þú búið til nýtt commit með `c`. Þú getur séð allar tiltækar skipanir með `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) er fallegur auðlindastjóri sem sýnir minnis-, CPU-, diska- og netnotkun. Hann sýnir einnig öll virk ferli og gerir þér kleift að stjórna þeim.

Omarchy kallar það Activity Monitor, og þú ræsir það úr forritaræsinum eða með því að ýta á `Super + Shift + T`. Það opnast sem fljótandi gluggi, sem þú getur flísalagt með `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) er vinnusvæðastjóri fyrir útstöðvar sem gefur þér vinnusvæði, flipa og glugga, og heldur þeim öllum gangandi í viðvarandi lotu sem þú getur aftengt þig frá og komið aftur til síðar.

Þú ræsir það (eða tengist aftur við lotuna sem þú átt fyrir) úr forritaræsinum eða með `Super + Ctrl + Return`. Omarchy fylgir með Herdr uppsetningu sem speglar Tmux uppsetninguna þess, svo forskeytislykillinn er `Ctrl + Space` hér líka. Þú getur skoðað allar lyklabindingar með `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) sýnir upplýsingar um kerfið, eins og kjarnútgáfu, uppitíma, þema, CPU, minni og fleira. Það er arftaki hins vinsæla neofetch tóls.

Omarchy hefur pakkað þessu sem _About_ í Omarchy valmyndinni (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) er retro tónlistarspilari fyrir útstöðvar innblásinn af Winamp 2.x, með innbyggðum útvarpsstöðvum fyrir lo-fi takta. Ræstu hann með `Super + Shift + Alt + M`, eða úr Omarchy valmyndinni undir _Apps_. Ýttu á `?` til að fá allan listann yfir lyklabindingar.

## Hvað með Wi-Fi og Bluetooth?

Þú finnur engin TUI fyrir Wi-Fi og Bluetooth — þau verk tilheyra Omarchy skelinni. Smelltu á Wi-Fi táknið í efstu stikunni (eða ýttu á `Super + Ctrl + N`) til að sjá net og tengjast, og smelltu á Bluetooth táknið (eða ýttu á `Super + Ctrl + B`) til að para og tengja tæki. Sjá [nettengingar](35-networking.md) fyrir alla söguna.

## Bæta við eigin

Hvaða útstöðvarforrit sem er getur fengið fulla forritsmeðferð. Farðu í _Install > TUI_ í Omarchy valmyndinni (`Super + Space`), gefðu því nafn, ræsingarskipun, gluggastíl og tákn, og það birtist í forritaræsinum eins og hvert annað forrit. Þú getur fjarlægt það aftur undir _Remove > TUI_.
