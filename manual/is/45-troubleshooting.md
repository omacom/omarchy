# Úrræðaleit

### Ég braut kerfið mitt með uppfærslu!

Reyndu fyrst að [endurheimta kerfið þitt](47-system-snapshots.md) í útgáfuna fyrir síðustu uppfærslu þína. Ef það virkar ekki skaltu nota `omarchy-debug` til að deila vandamálinu þínu á #omarchy-help á Discord. Og ef allt það mistekst geturðu sett sjálfgefnar stillingar og pakka upp aftur með `omarchy-reinstall`.

### Af hverju eru sum forrit svo stór á skjánum mínum?

Omarchy gerir ráð fyrir 2x háupplausnarskjá, sem krefst þess að `GDK_SCALE` sé stillt á 2 í `~/.config/hypr/monitors.lua`. En ef þú ert á 1x skjá geturðu breytt `local omarchy_gdk_scale = 2` í 1 (og endurræst svo öll forrit sem eru of stór). Sjá [handbókina um skjái](33-monitors.md).

Fyrir Spotify geturðu notað `Ctrl + Minus` til að minnka viðmótið (og `Ctrl + Plus` til að stækka það).

### Wi-Fi, Bluetooth, hljóð eða snertiflöturinn minn hætti bara að virka

Áður en þú endurræsir skaltu prófa að endurræsa sökudólgsundirkerfið eitt sér. _Uppfæra > Vélbúnaður_ í Omarchy-valmyndinni er með Wi-Fi, Bluetooth, hljóð og snertiflötu, og að endurhlaða einum þeirra hreinsar meirihluta „það virkaði fyrir fimm mínútum“ aðstæðna — Bluetooth heyrnartól sem vilja ekki tengjast aftur, snertiflötu sem dó eftir svefn, hljóð sem hvarf þegar þú tókst skjá úr sambandi.

### Af hverju spila ytri hátalararnir mínir ekki?

Líklega vegna þess að þeir eru ekki stilltir sem aðalúttak. Smelltu á hátalaratáknið hægra megin á stikunni, og það mun opna hljóðstyrksgluggann þar sem þú getur valið úttakstækið (og blandað hljóðstyrk fyrir hvert forrit líka).

### Fartölvuhátalararnir mínir hljóma einkennilega

Á sumum fartölvum beitir Omarchy sjálfkrafa hátalarastillingu sem leiðréttir tíðnisvörun innbyggðu hátalaranna. `omarchy audio tuning status` segir þér hvort ein er virk á vélinni þinni, og `omarchy audio tuning off` slekkur á henni ef þú vilt heldur heyra hátalarana hráa.

### Af hverju get ég ekki skráð mig inn eða notað sudo með lykilorðinu mínu?

Þú slóst það líklega rangt inn of oft og varst læstur úti. Ef þetta gerist á læsiskjánum geturðu ýtt á `CTRL + ALT + F2` til að ræsa nýja TTY þar sem þú getur skráð þig inn sem root og keyrt svo `faillock --reset --user [your-username]`. Það mun endurstilla læsinguna og þú ert tilbúinn.

### Af hverju birtast 1Password heimildakvaðningarnar mínar fyrir 1Password SSH Agent / CLI ekki?

Þetta getur gerst af tveimur ástæðum:

Til að ríkulega samþykktarkvaðningin birtist verður Settings > Advanced > Use Hardware Acceleration að vera á. _Athugaðu: Þetta krefst endurræsingar til að byrja að virka._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eða ef þú hefur ekki ræst 1Password síðan þú ræstir vélina mun kvaðningin ekki birtast.
