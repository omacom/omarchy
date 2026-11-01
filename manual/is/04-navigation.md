# Flakk

Allt í Omarchy gerist í gegnum lyklaborðið — _ALLT!_ Þegar kerfið ræsist í fyrsta skipti geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að birta Omarchy-valmyndina og þaðan geturðu gert nánast allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem helsta leiðin til að stjórna kerfinu mestan tímann. Við getum verið fljótari en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir útstöðina með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú munt sjá töfra flísaskipulags Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim hverjum ofan á annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að koma þeim aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta á gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa virkniskjáinn. Hann birtist sem fljótandi gluggi. Þú getur sett hann í flísaskipulag með `Super + T` (og ýtt aftur á það til að gera hann fljótandi á ný). Ýttu nú á `Super + Shift + F` til að opna skráarstjórann. Þú munt hafa snyrtilega uppsetningu með fjórum gluggum:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú ferð á milli glugganna og velur hver þeirra er virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við brún skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Þegar þú ert með fleiri en einn skjá hefur hver skjár vinnusvæði 1 til 10 út af fyrir sig. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efri stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir núna. `Super + Tab` fer í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau bætast við vinnusvæði annars skjás, númeruð á eftir þeim sem hann hefur þegar, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur `Super` inni og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur `Super` inni og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið á allan skjáinn með `Super + F`, eða jafnvel bara á fulla breidd (og haldið efri stikunni) með `Super + Alt + F`, eða á allan skjáinn inni í glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunskipulagi

Sjálfgefið skipulag Omarchy heitir dwindle. Það heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum á öllum tímum, jafnvel þótt það þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunskipulagið þar sem gluggar raðast hlið við hlið, út fyrir sýnilega brún skjásins. Þú breytir einu vinnusvæði í þetta skipulag með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðji smellurinn kemur því aftur í dwindle. `Super + Alt + L` fer í gegnum þau í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísaskipulag. Efri stikan merkir vinnusvæðið sem þú ert á með skipulagi þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í gegnum skipulögin eitt af öðru.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði fyrir sig og það helst. Svo þú getur haft vinnusvæði 1 á dwindle til að vafra og vinnusvæði 2 á skrun fyrir kóða, og þau munu koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunskipulagið sem sjálfgefið geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Hver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forritið hans til að koma honum til baka. Smelltu á glugga til að koma honum fram fyrir. Breyttu stærð hans frá hvaða brún eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann en halda efri stikunni sýnilegri, og aftur til að fá gömlu stærðina hans til baka.

Fljótandi vinnusvæði sýnir líka bryggju, með föstu forritunum þínum, öllu sem er í gangi og yfirliti með öllum forritum í rist á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit í ristinni, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að koma glugganum þess fram fyrir; smelltu aftur til að fara í gegnum gluggana þess einn af öðrum. Miðsmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það þaðan út eða loka því. Bryggjan víkur fyrir glugga á öllum skjánum. Hægrismelltu á forritahnappinn til að færa bryggjuna á aðra brún eða láta hana fela sig þar til bendillinn nær að brún hennar. Staðsetningin er líka undir _Útlit > Bryggja > Staðsetning bryggju_, og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja úr útstöð. Forrit sem þú geymir í bryggjunni eru dauf á meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið eigið skipulag með `Super + L`, nota sjálfgefið skipulag. Að breyta sjálfgefna skipulaginu endurstillir hvert vinnusvæði án glugga á það, á meðan vinnusvæði með glugga á sér heldur skipulaginu sem það hefur. Gluggi sem lágmarkaður er í bryggjuna telst enn sem gluggi á vinnusvæðinu sem hann fór af. Veldu það undir _Útlit > Skipulag vinnusvæðis_: Flísaskipulag, Skrunskipulag eða Fljótandi. `omarchy-hyprland-workspace-layout-default scrolling` stillir það úr útstöð.

### Að hópa saman glugga

Hægt er að hópa glugga saman með `Super + G`. Þegar þú ert kominn í hóp mun hver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur farið á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á hópaða glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur sprett glugga út úr úthlutun vinnusvæðisins hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilarar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæðið

Það er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á núna. Þú nálgast það sem er á því með `Super + S`, og þú setur glugga þar með `Super + Alt + S`.

Það hentar vel fyrir stjórntæki eða útstöð sem þú vilt nota hratt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborðið

Að lokum er Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á núna. Kveiktu og slökktu á því með `Super + Grave`, og settu glugga þar með `Super + Shift + Grave`.

Það opnast með sjálfgefna umboðsaðilann þinn tilbúinn til notkunar. Á meðan stjórnborðið geymir einn glugga fellur það niður sem miðjusett spjald í stað þess að teygja sig yfir skjáinn. Settu annað forrit á það og það fer aftur á fulla breidd, svo þau tvö hafi pláss til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdavinnusvæðinu eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Þetta tekur smá tíma að venjast!

Það tekur smá tíma að venjast því að fara um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara til baka í hefðbundna upplifun á skjáborði sem stjórnað er með músinni!
