# Úrræðaleit

### Ég rústaði kerfinu mínu með uppfærslu!

Reyndu fyrst að [færa kerfið aftur](47-system-snapshots.md) í útgáfuna fyrir nýlegu uppfærsluna. Ef það virkar ekki skaltu nota `omarchy-debug` til að deila vandamálinu þínu á #omarchy-help á Discord. Og ef allt það bregst geturðu sett sjálfgefnar stillingar og pakka upp aftur með `omarchy-reinstall`.

### Af hverju eru sum forrit svona stór á skjánum mínum?

Omarchy gerir ráð fyrir 2x háupplausnarskjá, svo það setur `GDK_SCALE` á 2 þangað til þú velur kvarða í skjáborðinu fyrir skjái. Ef þú ert á 1x skjá og GTK eða X11 forrit verða of stór skaltu velja 1x fyrir hann í skjáborðinu fyrir skjái, eða bæta `hl.env("GDK_SCALE", "1")` við `~/.config/hypr/monitors.lua` (og endurræsa svo öll forrit sem eru of stór). Sjá [handbókina um skjái](33-monitors.md).

Fyrir Spotify geturðu notað `Ctrl + Minus` til að minnka viðmótið (og `Ctrl + Plus` til að stækka það).

### Af hverju hættu allar Super-lyklabindingarnar mínar að virka?

Á sumum ASUS ROG og TUF fartölvum er `Fn + Super` auðgleymanleg lyklasamsetning sem kveikir og slekkur á Windows-lyklalæsingu í fastbúnaði (ætluð til leikjaspilunar svo þú farir ekki úr leik fyrir slysni). Ekkert á skjánum segir þér að það hafi gerst. Á meðan læsingin er á sendir Super alls ekkert frá sér — svo allar Omarchy-bindingar sem nota Super hætta bara að virka, og það lítur út fyrir að Hyprland hafi brotnað.

Ýttu einu sinni á `Fn + Super` áður en þú ferð að grafa í `~/.config/hypr/`, og ef það færir Super ekki aftur skaltu ýta einu sinni enn svo þú skiljir læsinguna ekki eftir á. Þetta er ekki Fn-læsing, sem breytir bara því hvað F-lyklaröðin gerir.

### Wi-Fi, Bluetooth, hljóðið eða snertiplattinn minn hætti bara að virka

Áður en þú endurræsir skaltu reyna að endurræsa viðkomandi undirkerfi út af fyrir sig. _Update > Hardware_ í Omarchy-valmyndinni er með Wi-Fi, Bluetooth, Audio og Trackpad, og að endurhlaða einu af því leysir meirihluta tilvika þar sem „þetta virkaði fyrir fimm mínútum“ — Bluetooth-heyrnartól sem neita að tengjast aftur, snertiplatti sem dó eftir hvíld, hljóð sem hvarf þegar þú tókst skjá úr sambandi.

### Af hverju spila ytri hátalararnir mínir ekki?

Líklega vegna þess að þeir eru ekki stilltir sem aðalúttak. Smelltu á hátalaratáknið hægra megin á stikunni, og þá opnast hljóðstyrksglugginn þar sem þú getur valið úttakstækið (og stillt hljóðstyrk fyrir hvert forrit líka).

### Hátalarar fartölvunnar minnar hljóma undarlega

Á sumum fartölvum beitir Omarchy sjálfkrafa hátalarastillingu sem leiðréttir tíðnisvörun innbyggðu hátalaranna. `omarchy audio tuning status` segir þér hvort ein sé virk á vélinni þinni, og `omarchy audio tuning off` slekkur á henni ef þú vilt frekar heyra hátalarana óbreytta.

### Af hverju get ég ekki skráð mig inn eða notað sudo með lykilorðinu mínu?

Þú slóst það líklega rangt inn tíu sinnum og þér var lokað úti. Læsingin hreinsast af sjálfu sér eftir tvær mínútur. Ef þú getur ekki beðið, og þetta gerist á læsiskjánum, geturðu ýtt á `CTRL + ALT + F2` til að ræsa nýtt TTY þar sem þú getur skráð þig inn sem root, og keyrt svo `faillock --reset --user [your-username]`. Það endurstillir læsinguna, og þú ert klár.

### Lykilorðið mitt er samþykkt, en ég fer aftur á innskráningarskjáinn

Biluð umhverfisskrá fyrir setu getur komið í veg fyrir að skjáborðið ræsist jafnvel þegar lykilorðið þitt er rétt. Þetta er sérstaklega vert að athuga eftir að þú hefur breytt `~/.config/uwsm/env.d/`.

Ýttu á `Ctrl + Alt + F2`, skráðu þig inn með venjulega notandanafninu þínu og lykilorði, og skoðaðu notendadagbók núverandi ræsingar:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Leitaðu að villu sem nefnir eina af umhverfisskránum þínum, eins og `bad substitution`, rétt á undan skilaboðum um að merkið fyrir env-úttak hafi ekki fundist. Færðu þá skrá út úr `env.d` áður en þú reynir að skrá þig inn aftur. Til dæmis, ef villan nefnir `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sleppir skrá með málfræðivillu, en banvæn villa sem kemur bara fram á meðan skráin keyrir, eins og `bad substitution`, getur samt komið í veg fyrir að skjáborðið ræsist. Að færa kerfið aftur með skyndimynd lagar ekki þessar skrár, því `/home` er ekki fært aftur.

Þegar þú getur skráð þig inn skaltu laga vistaða eintakið áður en þú færir það til baka. `sh -n` grípur málfræðivillur án þess að keyra skrána, en getur ekki gripið allar villur sem koma upp þegar hún er sótt. Haltu virkum terminal opnum á meðan þú prófar breytingar.

### Af hverju birtast staðfestingargluggar 1Password fyrir 1Password SSH Agent / CLI ekki?

Þetta getur gerst af 2 ástæðum:

Til að ítarlegi staðfestingarglugginn birtist þarf Settings > Advanced > Use Hardware Acceleration að vera kveikt. _Athugið: Þetta krefst endurræsingar til að byrja að virka._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eða ef þú hefur ekki ræst 1Password síðan þú ræstir tölvuna mun glugginn ekki birtast.
