# Úrræðaleit

### Ég eyðilagði kerfið mitt með uppfærslu!

Reyndu fyrst að [færa kerfið þitt aftur](47-system-snapshots.md) í útgáfuna fyrir nýlegu uppfærsluna þína. Ef það virkar ekki skaltu nota `omarchy-debug` til að deila vandanum þínum á #omarchy-help á Discord. Og ef allt annað bregst geturðu sett upp sjálfgefnar stillingar og pakka aftur með `omarchy-reinstall`.

### Af hverju eru sum forrit svona stór á skjánum mínum?

Omarchy gerir ráð fyrir 2x háupplausnarskjá, sem krefst þess að `GDK_SCALE` sé stillt á 2 í `~/.config/hypr/monitors.lua`. En ef þú ert á 1x skjá geturðu breytt `local omarchy_gdk_scale = 2` í 1 (og endurræst síðan öll forrit sem eru of stór). Sjá [handbókina um skjái](33-monitors.md).

Fyrir Spotify geturðu notað `Ctrl + Minus` til að minnka viðmótið (og `Ctrl + Plus` til að stækka það).

### Af hverju hættu allar Super-lyklabindingarnar mínar að virka?

Á sumum ASUS ROG og TUF fartölvum er `Fn + Super` auðgleymanleg lyklasamsetning sem kveikir og slekkur á Windows-lyklalás í fastbúnaði (ætlað fyrir tölvuleiki svo þú farir ekki úr leik fyrir slysni). Ekkert á skjánum segir þér að þetta hafi gerst. Á meðan lásinn er á sendir Super alls ekkert frá sér — svo hver einasta Omarchy-binding sem notar Super hættir einfaldlega að virka, og það lítur út eins og Hyprland hafi bilað.

Ýttu einu sinni á `Fn + Super` áður en þú ferð að grafa í `~/.config/hypr/`, og ef það fær Super ekki til baka skaltu ýta aftur á það svo þú skiljir lásinn ekki eftir á. Þetta er ekki Fn-lock, sem breytir aðeins því hvað F-lyklaröðin gerir.

### Wi-Fi, Bluetooth, hljóð eða snertiborðið mitt hætti bara að virka

Áður en þú endurræsir skaltu reyna að endurræsa viðkomandi undirkerfi eitt og sér. _Update > Hardware_ í Omarchy-valmyndinni er með Wi-Fi, Bluetooth, Audio og Trackpad, og að endurhlaða einum þeirra leysir meirihluta „þetta virkaði fyrir fimm mínútum“ tilvika — Bluetooth-heyrnartól sem vilja ekki tengjast aftur, snertiborð sem dó eftir svefn, hljóð sem hvarf þegar þú tókst skjá úr sambandi.

### Af hverju spila ytri hátalararnir mínir ekki?

Líklega vegna þess að þeir eru ekki stilltir sem aðalútgangur. Smelltu á hátalaratáknið hægra megin á stikunni, og það opnar hljóðstyrksgluggann þar sem þú getur valið úttakstækið (og stillt hljóðstyrk fyrir hvert forrit líka).

### Hátalarar fartölvunnar minnar hljóma undarlega

Á sumum fartölvum beitir Omarchy sjálfkrafa hátalarastillingu sem leiðréttir tíðnisvörun innbyggðu hátalaranna. `omarchy audio tuning status` segir þér hvort slík stilling sé virk á vélinni þinni, og `omarchy audio tuning off` slekkur á henni ef þú vilt frekar heyra hátalarana óbreytta.

### Af hverju get ég ekki skráð mig inn eða notað sudo með lykilorðinu mínu?

Þú slóst það líklega rangt inn of oft og varst læst úti. Ef þetta gerist á læsiskjánum geturðu ýtt á `CTRL + ALT + F2` til að ræsa nýtt TTY þar sem þú getur skráð þig inn sem root og síðan keyrt `faillock --reset --user [your-username]`. Það endurstillir læsinguna, og þú ert klár.

### Af hverju birtast ekki heimildarbeiðnir 1Password fyrir 1Password SSH Agent / CLI hjá mér?

Þetta getur gerst af 2 ástæðum:

Til þess að ítarlega samþykktarbeiðnin birtist þarf að vera kveikt á Settings > Advanced > Use Hardware Acceleration. _Athugið: Þetta krefst endurræsingar til að byrja að virka._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eða ef þú hefur ekki ræst 1Password síðan þú ræstir tölvuna mun beiðnin ekki birtast.
