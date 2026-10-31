# Vandamálaleit

### Ég eyðilagði kerfið mitt með uppfærslu!

Prófaðu fyrst að [færa kerfið þitt aftur](47-system-snapshots.md) í útgáfuna fyrir nýjustu uppfærsluna þína. Ef það virkar ekki skaltu nota `omarchy-debug` til að deila vandamálinu þínu á #omarchy-help á Discord. Og ef allt það bregst geturðu sett upp sjálfgefnu stillingarnar og pakkana aftur með `omarchy-reinstall`.

### Af hverju eru sum forrit svona stór á skjánum mínum?

Omarchy gerir ráð fyrir 2x háskerpuskjá, svo það setur `GDK_SCALE` á 2 þar til þú velur kvarða í skjáborðinu. Ef þú ert á 1x skjá og GTK eða X11 forrit verða of stór skaltu velja 1x fyrir hann í skjáborðinu, eða bæta `hl.env("GDK_SCALE", "1")` við `~/.config/hypr/monitors.lua` (og endurræsa síðan öll forrit sem eru of stór). Sjá [handbókina um skjái](33-monitors.md).

Fyrir Spotify geturðu notað `Ctrl + Minus` til að minnka viðmótið (og `Ctrl + Plus` til að stækka það).

### Af hverju hættu allar Super-lyklabindingar mínar að virka?

Á sumum ASUS ROG og TUF fartölvum er `Fn + Super` auðyfirfarn samsettur ásláttur sem kveikir og slekkur á læsingu á Windows-lykli í fastbúnaði (ætlaður fyrir leiki svo þú farir ekki úr leik fyrir slysni). Ekkert á skjánum segir þér að það hafi gerst. Á meðan læsingin er á sendir Super alls ekkert frá sér — svo allar Omarchy-bindingar sem nota Super hætta bara, og það lítur út fyrir að Hyprland hafi bilað.

Ýttu einu sinni á `Fn + Super` áður en þú ferð að grafa í `~/.config/hypr/`, og ef það færir Super ekki aftur skaltu ýta á það aftur svo þú skiljir læsinguna ekki eftir á. Þetta er ekki Fn-læsing, sem breytir aðeins því hvað F-lyklaröðin gerir.

### Wi-Fi, Bluetooth, hljóð eða snertiplattinn minn hætti bara að virka

Áður en þú endurræsir skaltu reyna að endurræsa viðkomandi undirkerfi eitt og sér. _Uppfærsla > Vélbúnaður_ í Omarchy-valmyndinni er með Wi-Fi, Bluetooth, Hljóð og Snertiplatta, og að endurhlaða einum af þeim leysir meirihluta „þetta virkaði fyrir fimm mínútum“ tilfella — Bluetooth-heyrnartól sem neitar að tengjast aftur, snertiplatti sem dó eftir svefn, hljóð sem hvarf þegar þú tókst skjá úr sambandi.

### Af hverju spila ytri hátalararnir mínir ekki?

Líklega vegna þess að þeir eru ekki stilltir sem aðalúttak. Smelltu á hátalaratáknið hægra megin á stikunni, og það opnar hljóðstyrksgluggann þar sem þú getur valið úttakstækið (og blandað hljóðstyrk fyrir hvert forrit líka).

### Hátalarar fartölvunnar minnar hljóma undarlega

Á sumum fartölvum beitir Omarchy sjálfkrafa hátalarastillingu sem leiðréttir tíðnisvörun innbyggðu hátalaranna. `omarchy audio tuning status` segir þér hvort ein sé virk á vélinni þinni, og `omarchy audio tuning off` slekkur á henni ef þú vilt frekar heyra hátalarana óbreytta.

### Af hverju get ég ekki skráð mig inn eða notað sudo með lykilorðinu mínu?

Þú slóst það líklega rangt inn of oft og varst læstur út. Ef þetta er að gerast á læsiskjánum geturðu ýtt á `CTRL + ALT + F2` til að ræsa nýtt TTY þar sem þú getur skráð þig inn sem root, og keyrt síðan `faillock --reset --user [your-username]`. Það núllstillir læsinguna, og þú ert tilbúinn.

### Af hverju birtast staðfestingarbeiðnir 1Password fyrir 1Password SSH Agent / CLI ekki hjá mér?

Þetta getur gerst af 2 ástæðum:

Til þess að ítarlega samþykktarbeiðnin birtist þarf Stillingar > Ítarlegt > Nota vélbúnaðarhröðun að vera kveikt. _Athugið: Þetta krefst endurræsingar til að byrja að virka._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eða ef þú hefur ekki ræst 1Password síðan þú kveiktir á tölvunni birtist beiðnin ekki.
