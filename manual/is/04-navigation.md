# Flakk

Allt í Omarchy gerist í gegnum lyklaborðið — _ALLT!_ Þegar kerfið ræsist í fyrsta sinn geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að opna Omarchy-valmyndina og þaðan geturðu gert nánast allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem aðalleiðin til að stjórna kerfinu mestan tímann. Við getum gert þetta hraðar! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir skjáhermi með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú sérð töfra flísalagningar Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim hverjum ofan á annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta á gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa Activity monitor. Hann birtist sem fljótandi gluggi. Þú getur flísalagt hann með `Super + T` (og ýtt aftur á það til að gera hann fljótandi á ný). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú færð snyrtilega uppsetningu með fjórum gluggum:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú færir þig á milli glugga og velur þann sem þú vilt að sé virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Með fleiri en einum skjá hefur hver skjár sín eigin vinnusvæði 1 til 10. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efsta stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í hring í gegnum vinnusvæði skjásins sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, inn á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau bætast við vinnusvæði annars skjás, númeruð á eftir þeim sem þar eru fyrir, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur inni `Super` og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur inni `Super` og notar hægri músarhnappinn geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (með efstu stikuna áfram sýnilega) með `Super + Alt + F` eða í fullan skjá innan glugga með `Super + Ctrl + F` (handhægt fyrir YouTube!).

### Dwindle á móti skrunskipulagi

Sjálfgefið skipulag Omarchy heitir dwindle. Það heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum öllum stundum, jafnvel þótt það þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunskipulagið þar sem gluggum er raðað hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir stöku vinnusvæði í þetta skipulag með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast að vild og þú staðsetur þá sjálfur, og þriðji smellurinn færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þau í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú smelltir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísalagningu. Efsta stikan merkir vinnusvæðið sem þú ert á með skipulagi þess: ferningur fyrir dwindle, hringur fyrir skrun og þríhyrningur fyrir fljótandi. Að smella á það merki fer líka í hring í gegnum skipulögin.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði fyrir sig og það helst. Þannig geturðu haft vinnusvæði 1 í dwindle fyrir vafur og vinnusvæði 2 í skruni fyrir kóða, og þau koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunskipulagið sem sjálfgefið geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Hver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forrit hans til að sækja hann aftur. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann en halda efstu stikunni sýnilegri, og aftur til að fá gömlu stærðina til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titilstikunni og nota sinn eigin haus í staðinn; `Super + Alt + F` hámarkar þá og `Super + M` lágmarkar þá.

Fljótandi vinnusvæði sýnir líka bryggju, með föstum forritunum þínum, öllu sem er í gangi og rist með öllum forritum á bak við forritahnappinn, sem `Super + Alt + Space` og _Apps_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á ristinni, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa glugga þess fram; smelltu aftur til að fara í hring í gegnum glugga þess. Miðsmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það út eða hætta í því. Bryggjan víkur fyrir glugga í fullum skjá. Hægrismelltu á forritahnappinn til að færa bryggjuna á annan jaðar eða láta hana felast þar til bendillinn nær að jaðri hennar. Staðsetningin er líka undir _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja úr skjáhermi. Forrit sem þú heldur í bryggjunni eru dauf meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið sitt eigið skipulag með `Super + L`, nota sjálfgefna skipulagið. Að breyta sjálfgefna skipulaginu endurstillir hvert vinnusvæði án glugga yfir í það, en vinnusvæði með glugga á heldur skipulaginu sem það hefur. Gluggi sem er lágmarkaður í bryggjuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu það undir _Appearance > Workspace Layout_: Tiling, Scrolling eða Floating. `omarchy-hyprland-workspace-layout-default scrolling` stillir það úr skjáhermi.

### Að flokka glugga í hópa

Hægt er að flokka glugga í hóp með `Super + G`. Þegar þú ert kominn í hóp mun hver gluggi sem þú ræsir á meðan hann er virkur tilheyra hópnum. Þú getur fært þig á milli þessara hópaðra glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á hópaða glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða leyst allan hópinn upp með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að smella gluggum út

Þú getur smellt glugga út úr úthlutun vinnusvæðis hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilarar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæði

Til er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á hverju sinni. Þú nálgast það sem er á því með `Super + S` og þú setur glugga þar með `Super + Alt + S`.

Það hentar vel fyrir stjórntæki eða skjáhermi sem þú vilt nota fljótt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er til Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á hverju sinni. Kveiktu og slökktu á því með `Super + Grave` og settu glugga þar með `Super + Shift + Grave`.

Það opnast með sjálfgefna agentinn þinn tilbúinn. Á meðan stjórnborðið geymir einn glugga fellur það niður sem miðjusett spjald í stað þess að teygja sig yfir skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, svo þau tvö hafi rými til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdanum eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju á borð við `Super + Shift + 1`.

### Þetta tekur smátíma að venjast!

Það tekur smástund að venjast því að flakka um skjáborðið þitt svona, en þegar þú hefur gert það verður erfitt að fara aftur í hefðbundna upplifun á skjáborði sem er stjórnað með mús!
