# Úrræðaleit

### Ég eyðilagði kerfið mitt með uppfærslu!

Prófaðu fyrst að [færa kerfið þitt til baka](47-system-snapshots.md) í útgáfuna fyrir nýjustu uppfærsluna þína. Ef það virkar ekki, notaðu `omarchy-debug` til að deila vandamálinu þínu á #omarchy-help í Discord. Og ef allt þetta bregst geturðu sett upp sjálfgefnar stillingar og pakka aftur með `omarchy-reinstall`.

### Hvers vegna eru sum forrit svona stór á skjánum mínum?

Omarchy gerir ráð fyrir 2x skjái í háum upplausn, svo það stillir `GDK_SCALE` á 2 þangað til þú velur kvörðun í skjáborðinu. Ef þú ert með 1x skjá og GTK eða X11 forrit birtast of stór, veldu 1x fyrir hann í skjáborðinu, eða bættu `hl.env("GDK_SCALE", "1")` við `~/.config/hypr/monitors.lua` (og endurræstu svo öll forrit sem eru of stór). Sjá [handbókina um skjái](33-monitors.md).

Fyrir Spotify geturðu notað `Ctrl + Minus` til að minnka viðmótið (og `Ctrl + Plus` til að stækka það).

### Hvers vegna hættu allar Super-lyklabindingarnar mínar að virka?

Á sumum ASUS ROG og TUF fartölvum er `Fn + Super` lyklasamsetning sem auðvelt er að missa af og kveikir og slökkvir á Windows-lyklalás í fastbúnaði (ætlaður fyrir tölvuleiki svo þú farir ekki úr leik fyrir slysni). Ekkert á skjánum segir þér að þetta hafi gerst. Á meðan lásinn er á sendir Super alls ekkert frá sér — svo sérhver Omarchy-binding sem notar Super hættir einfaldlega að virka, og það lítur út eins og Hyprland hafi brotnað.

Ýttu einu sinni á `Fn + Super` áður en þú ferð að grafa í `~/.config/hypr/`, og ef það kemur Super ekki aftur, ýttu þá aftur á það svo þú skiljir lásinn ekki eftir á. Þetta er ekki Fn-lás, sem breytir aðeins því hvað F-lyklaröðin gerir.

### Wi-Fi, Bluetooth, hljóð eða snertiflöturinn minn hætti bara að virka

Áður en þú endurræsir skaltu prófa að endurræsa viðkomandi undirkerfi út af fyrir sig. _Update > Hardware_ í Omarchy-valmyndinni er með Wi-Fi, Bluetooth, Audio og Trackpad, og að endurhlaða einu þeirra lagar meirihluta tilfella þar sem „þetta virkaði fyrir fimm mínútum“ — Bluetooth-heyrnartól sem vilja ekki tengjast aftur, snertiflötur sem dó eftir svefn, hljóð sem hvarf þegar þú tókst skjá úr sambandi.

### Hvers vegna spila ytri hátalararnir mínir ekki?

Líklega vegna þess að þeir eru ekki stilltir sem aðalúttak. Smelltu á hátalaratáknið hægra megin á stykunni, og þá opnast hljóðstyrksglugginn þar sem þú getur valið úttakstækið (og stillt hljóðstyrk fyrir hvert forrit líka).

### Hátalarar fartölvunnar minnar hljóma undarlega

Á sumum fartölvum beitir Omarchy sjálfkrafa hátalaratillingu sem leiðréttir tíðnisvörun innbyggðu hátalaranna. `omarchy audio tuning status` segir þér hvort slík sé virk á vélinni þinni, og `omarchy audio tuning off` slökkvir á henni ef þú vilt frekar heyra hátalarana óbreytta.

### Hvers vegna get ég ekki skráð mig inn eða notað sudo með lykilorðinu mínu?

Þú slóst það líklega rangt inn of oft og varðst læst úti. Ef þetta gerist á læsiskjánum geturðu ýtt á `CTRL + ALT + F2` til að opna nýja TTY þar sem þú getur skráð þig inn sem root, og keyrt svo `faillock --reset --user [your-username]`. Það núllstillir læsinguna, og þá er allt klárt.

### Lykilorðið mitt er samþykkt, en ég fer aftur á innskráningarskjáinn

Bilud umhverfisskrá fyrir setu getur komið í veg fyrir að skjáborðið ræsist jafnvel þegar lykilorðið þitt er rétt. Þetta er sérstaklega vert að athuga eftir að þú hefur breytt `~/.config/uwsm/env.d/`.

Ýttu á `Ctrl + Alt + F2`, skráðu þig inn með venjulega notandanafninu þínu og lykilorði, og skoðaðu notendadagbók núverandi ræsingar:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Leitaðu að villu sem nefnir eina af umhverfisskránum þínum, eins og `bad substitution`, rétt á undan skilaboðum um að env-úttaksmerkið hafi ekki fundist. Færðu þá skrá úr `env.d` áður en þú reynir að skrá þig inn aftur. Til dæmis, ef villan nefnir `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sleppir skrá með setningafræðivillu, en banvæn villa sem kemur aðeins fram á meðan skráin keyrir, eins og `bad substitution`, getur samt komið í veg fyrir að skjáborðið ræsist. Að færa kerfið til baka með skyndimynd lagar ekki þessar skrár, vegna þess að `/home` er ekki fært til baka.

Þegar þú getur skráð þig inn skaltu laga vistaða afritið áður en þú færir það til baka. `sh -n` grípur setningafræðivillur án þess að keyra skrána, en getur ekki gripið allar villur sem koma upp þegar hún er sótt. Hafðu virkan útstöð opinn á meðan þú prófar breytingar.

### Hvers vegna birtast ekki 1Password heimildarbeiðnirnar mínar fyrir 1Password SSH Agent / CLI?

Þetta getur gerst af 2 ástæðum:

Til þess að ítarlega samþykktarbeiðnin birtist þarf að vera kveikt á Settings > Advanced > Use Hardware Acceleration. _Athugið: Þetta krefst endurræsingar til að fara að virka._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eða ef þú hefur ekki ræst 1Password síðan þú kveiktir á tölvunni, þá birtist beiðnin ekki.
