# Leiðsögn

Allt í Omarchy gerist í gegnum lyklaborðið — _ALLT!_ Þegar kerfið ræsist fyrst getur þú bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að birta Omarchy-valmyndina og héðan getur þú gert nánast allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem helsta leiðin til að stjórna kerfinu mestan tímann. Við getum verið hraðari en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir skjáherminn með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú munt sjá töfra flísaskipunar Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim ofan á hvorn annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að skila þeim í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta um glugga.

Prófaðu nú `Super + Shift + T` til að ræsa Activity-vaktann. Hann birtist sem fljótandi gluggi. Þú getur flísalagt hann með `Super + T` (og ýtt aftur á það til að gera hann fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú verður með snyrtilega uppsetningu með fjórum gluggum:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú ferð á milli gluggans sem þú vilt að sé virkur með `Super + Arrow`. Þetta skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færir þú forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Með fleiri en einum skjá hefur hver skjár vinnusvæði 1 til 10 fyrir sig. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efri stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það tekur sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem hann hefur fyrir, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur niðri `Super` og notar músina til að smella á glugga getur þú endurraðað því hvar hann situr. Ef þú heldur niðri `Super` og notar hægri hnappinn á músinni getur þú breytt stærð gluggans frjálst.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (á meðan efri stikan helst) með `Super + Alt + F` eða í fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrúnskipan

Sjálfgefin skipan Omarchy heitir dwindle. Hún heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum á öllum tímum, jafnvel þótt hún þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrúnskipan þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir einu vinnusvæði í þessa skipan með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðja ýting skilar því aftur í dwindle. `Super + Alt + L` fer í gegnum þær í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísaskipan. Efri stikan merkir vinnusvæðið sem þú ert á með skipan þess: ferning fyrir dwindle, hring fyrir skrún og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í gegnum skipanirnar og það gerir skjáalykillinn á fartölvum sem hafa slíkan lykil líka.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði og það helst. Svo þú getur haft vinnusvæði 1 á dwindle fyrir vafur og vinnusvæði 2 á skrún fyrir kóða og þau munu koma aftur þannig eftir endurræsingu.

Ef þú vilt nota skrúnskipanina sem sjálfgefna getur þú stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir og stærðir þá sjálfur. Hver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forrit hans til að koma honum aftur. Smelltu á glugga til að koma honum fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann á meðan efri stikan helst sýnileg og aftur til að fá gömlu stærðina hans til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titlistikunni og nota eigin haus í staðinn; `Super + Alt + F` hámarkar þá og `Super + M` lágmarkar þá.

Fljótandi vinnusvæði sýnir líka bryggju, með föstum forritum þínum, öllu sem er í gangi og hnitaneti allra forrita á bak við forritahnappinn, sem `Super + Alt + Space` og _Apps_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á hnitanetinu, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að koma glugga þess fram; smelltu aftur til að fara í gegnum glugga þess. Files kemur aðeins með glugga til baka frá vinnusvæðinu sem þú ert á og opnar annars nýjan og Terminal og Agent ræsa alltaf annan til viðbótar, þótt lágmarkaður gluggi komi fyrst til baka. Miðjusmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það út eða hætta í því. Bryggjan víkur fyrir glugga í fullum skjá. Hægrismelltu á forritahnappinn til að færa bryggjuna á annan jaðar eða láta hana fela sig þar til bendillinn nær jaðri hennar. Staðsetningin er líka undir _Appearance > Dock > Dock Position_ og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja úr skjáhermi. Forrit sem þú heldur í bryggjunni eru dauf meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið eigin skipan með `Super + L`, nota sjálfgefnu skipanina. Að breyta sjálfgefnu skipaninni endurstillir hvert vinnusvæði án glugga á hana, en vinnusvæði með glugga á heldur skipaninni sem það hefur. Gluggi sem lágmarkaður er í bryggjuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu hana undir _Appearance > Workspace Layout_: Tiling, Scrolling eða Floating. `omarchy hyprland workspace layout default scrolling` stillir hana úr skjáhermi.

### Að hópa glugga

Glugga er hægt að hópa með `Super + G`. Þegar þú ert í hópi mun hver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur farið á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint að hópuðum gluggum í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum getur þú fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur sprett glugga út úr úthlutun vinnusvæðis hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæði

Það er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á. Þú nálgast það sem er á því með `Super + S` og þú setur glugga þar með `Super + Alt + S`.

Það hentar vel fyrir stjórntæki eða skjáhermi sem þú vilt nota hratt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á. Kveiktu og slökktu á því með `Super + the key above Tab` (grave á bandarískum lyklaborðum) og settu glugga þar með `Super + Shift + the key above Tab`.

Í fyrsta skipti sem það opnast ræsir það sjálfgefna agentinn þinn, eða biður þig að velja einn ef þú hefur ekki valið einn enn. Á meðan stjórnborðið heldur einum glugga fellur það niður sem miðjusett spjald frekar en að spanna skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, svo þau tvö hafi pláss til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdavinnusvæðinu eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Það tekur tíma að venjast þessu!

Það tekur smá tíma að venjast því að fara um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna upplifun á skjáborði sem stjórnað er með mús!
