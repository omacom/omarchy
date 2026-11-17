# Flakk

Allt í Omarchy gerist með lyklaborðinu — _ALLT!_ Þegar kerfið ræsist í fyrsta sinn geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að opna Omarchy-valmyndina og þaðan geturðu gert nánast allt.

En Omarchy-valmyndin á ekki einu sinni að vera helsta leiðin til að stjórna kerfinu mestan tímann. Við getum gert þetta hraðar en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir flugstöðina með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú munt sjá töfra flísalags Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim ofan á hvorn annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta um glugga.

Prófaðu nú `Super + Shift + T` til að ræsa Activity-skerminn. Hann birtist sem fljótandi gluggi. Þú getur flísalagt hann með `Super + T` (og ýtt aftur á það til að gera hann fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú verður með snyrtilega uppsetningu í fjórar áttir:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú færir þig á milli glugganna sem þú vilt að séu virkir með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færir þú forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Þegar þú ert með fleiri en einn skjá hefur hver skjár sín eigin vinnusvæði 1 til 10. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efsta stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem hann hefur þegar, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur `Super` inni og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur `Super` inni og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (og haldið efstu stikunni) með `Super + Alt + F` eða í fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunuppsetningu

Sjálfgefna uppsetningin í Omarchy heitir dwindle. Hún heldur öllum gluggunum sem þú opnar á einu vinnusvæði sýnilegum á öllum tímum, jafnvel þótt hún þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunuppsetninguna þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir einu vinnusvæði í þessa uppsetningu með `Super + L`.

Þegar ýtt er aftur á `Super + L` verður vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðji ýtingurinn færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þær í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísalag. Efsta stikan merkir vinnusvæðið sem þú ert á með uppsetningu þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í gegnum uppsetningarnar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði fyrir sig og það helst. Þannig geturðu haft vinnusvæði 1 á dwindle fyrir vafur og vinnusvæði 2 á skrun fyrir kóða og þau munu koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunuppsetninguna sem sjálfgefna geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Hver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í dokkunni; smelltu á forrit hans til að fá hann til baka. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann á meðan efsta stikan er enn sýnileg og aftur til að fá gömlu stærðina hans til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titilstikunni og nota sinn eigin haus í staðinn; `Super + Alt + F` hámarkar þá og `Super + M` lágmarkar þá.

Fljótandi vinnusvæði sýnir líka dokku, með festu forritunum þínum, öllu sem er í gangi og rúðuneti með öllum forritum á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á rúðunetinu, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa glugga þess fram; smelltu aftur til að fara í gegnum glugga þess. Files færir aðeins til baka glugga frá vinnusvæðinu sem þú ert á og opnar annars nýjan, og Terminal og Agent ræsa alltaf annan til viðbótar, þótt lágmarkaður gluggi komi fyrst til baka. Miðsmellur opnar nýjan glugga. Dragðu tákn eftir dokkunni til að færa það; að draga forrit sem er í gangi inn á meðal hinna heldur því þar. Hægrismelltu til að halda forriti í dokkunni, taka það út eða hætta í því. Dokkan víkur fyrir glugga í fullum skjá. Hægrismelltu á forritahnappinn til að færa dokkuna á annan jaðar eða láta hana fela sig þar til bendillinn nær að jaðri hennar. Staðsetningin er líka undir _Útlit > Dokka > Staðsetning dokku_ og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja frá flugstöð. Forrit sem þú heldur í dokkunni eru dauf á meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið sína eigin uppsetningu með `Super + L`, nota sjálfgefnu uppsetninguna. Að breyta sjálfgefnu uppsetningunni endurstillir hvert vinnusvæði án glugga yfir í hana, á meðan vinnusvæði með glugga á heldur uppsetningunni sem það hefur. Gluggi sem er lágmarkaður í dokkuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu hana undir _Útlit > Uppsetning vinnusvæðis_: Flísalag, Skrun eða Fljótandi. `omarchy-hyprland-workspace-layout-default scrolling` stillir hana frá flugstöð.

### Að hópa glugga

Hægt er að hópa glugga með `Super + G`. Þegar þú ert kominn í hóp mun hver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur fært þig á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á hópaða glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur sprett glugga út úr úthlutun vinnusvæðisins hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæði

Það er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á. Þú opnar það sem er á því með `Super + S` og þú setur glugga þar með `Super + Alt + S`.

Það virkar vel fyrir stýringar eða flugstöð sem þú vilt nota hratt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á. Kveiktu og slökktu á því með `Super + Grave` og settu glugga þar með `Super + Shift + Grave`.

Það opnast með sjálfgefna agentinn þinn tilbúinn. Á meðan stjórnborðið geymir einn glugga fellur það niður sem miðjusett spjald í stað þess að teygja sig yfir skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, þannig að þau tvö hafa pláss til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdanum eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Þetta tekur smá tíma að venjast!

Það tekur smá stund að venjast því að flakka um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna upplifun á skjáborði sem er stjórnað með mús!
