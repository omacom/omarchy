# Flakk

Allt í Omarchy gerist með lyklaborðinu — _ALLT!_ Þegar kerfið ræsist í fyrsta sinn geturðu bókstaflega ekkert gert með músinni einni saman. En þú getur ýtt á `Super + Space` til að birta Omarchy-valmyndina og þaðan geturðu gert næstum allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem aðalleiðin til að stjórna kerfinu mestan tímann. Við getum verið fljótari en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir skjáherminn með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú sérð töfra flísaskipunar Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim ofan á hvorn annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` meðan þú ert á vafranum til að skipta á gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa virknivaktina. Hún birtist sem fljótandi gluggi. Þú getur flísalagt hana með `Super + T` (og ýtt aftur á það til að gera hana fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú verður með snyrtilega uppsetningu í fjórar áttir:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú ferð á milli gluggans sem þú vilt að sé virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókusi yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókusi yfir á annað vinnusvæðið án þess að skipta yfir á það).

Þegar þú ert með fleiri en einn skjá hefur sérhver skjár vinnusvæði 1 til 10 fyrir sig. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efsta stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem hann hefur þegar, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur `Super` niðri og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur `Super` niðri og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið á fullan skjá með `Super + F` eða jafnvel bara á fulla breidd (og haldið efstu stikunni) með `Super + Alt + F` eða á fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti rúllandi skipan

Sjálfgefin skipan Omarchy heitir dwindle. Hún heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum öllum stundum, jafnvel þótt hún þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í rúllandi skipan þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir einu vinnusvæði í þessa skipan með `Super + L`.

Með því að ýta aftur á `Super + L` verður vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og með þriðju ýtingunni fer það aftur í dwindle. `Super + Alt + L` fer í gegnum þær í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísaskipun. Efsta stikan merkir vinnusvæðið sem þú ert á með skipan þess: ferning fyrir dwindle, hring fyrir rúllandi og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í gegnum skipanirnar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði og það helst. Þannig geturðu haldið vinnusvæði 1 í dwindle fyrir vafur og vinnusvæði 2 í rúllandi fyrir kóða, og þau koma þannig til baka eftir endurræsingu.

Ef þú vilt nota rúllandi skipan sem sjálfgefna geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Sérhver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókusi. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forrit hans til að fá hann til baka. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann en halda efstu stikunni sýnilegri, og aftur til að fá gömlu stærðina hans til baka.

Fljótandi vinnusvæði sýnir líka bryggju, með festum forritunum þínum, öllu sem er í gangi og hnitaneti allra forrita á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á hnitanetinu, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa glugga þess fram; smelltu aftur til að fara í gegnum glugga þess. Miðjusmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það út eða hætta í því. Bryggjan víkur fyrir glugga á fullum skjá. Hægrismelltu á forritahnappinn til að færa bryggjuna á annan jaðar eða láta hana fela sig þar til bendillinn nær að jaðri hennar. Staðsetningin er líka undir _Útlit > Bryggja > Staðsetning bryggju_, og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja frá skjáhermi. Forrit sem þú heldur í bryggjunni eru dauf meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið sína eigin skipan með `Super + L`, nota sjálfgefnu skipanina. Að breyta sjálfgefinni skipan endurstillir hvert vinnusvæði án glugga á hana, en vinnusvæði með glugga á heldur skipaninni sem það hefur. Gluggi sem hefur verið lágmarkaður í bryggjuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu hana undir _Útlit > Skipan vinnusvæðis_: Flísaskipan, Rúllandi eða Fljótandi. `omarchy-hyprland-workspace-layout-default scrolling` stillir hana frá skjáhermi.

### Að hópa glugga

Hægt er að hópa glugga með `Super + G`. Þegar þú ert kominn í hóp mun sérhver gluggi sem þú ræsir meðan það er virkt tilheyra hópnum. Þú getur farið á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á hópaðan glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur sprett glugga út úr úthlutun vinnusvæðis hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæði

Til er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir vinnusvæðið sem þú ert á. Þú opnar það sem er á því með `Super + S`, og þú setur glugga þar með `Super + Alt + S`.

Það virkar vel fyrir stjórntæki eða skjáhermi sem þú vilt nota fljótt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er til Quake-stjórnborð í hálfri hæð sem fellur niður yfir vinnusvæðið sem þú ert á. Kveiktu og slökktu á því með `Super + Grave`, og settu glugga þar með `Super + Shift + Grave`.

Það opnast með sjálfgefna umboðsmanninn þinn tilbúinn. Þegar stjórnborðið geymir einn glugga fellur það niður sem miðjusett spjald í stað þess að spanna skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, þannig að þau tvö hafa pláss til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdanum eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Það tekur nokkra venju!

Það tekur smástund að venjast því að fara um skjáborðið þitt svona, en þegar þú hefur gert það verður erfitt að fara aftur í hefðbundna upplifun á skjáborði sem er stjórnað með músinni!
