# Flakk

Allt í Omarchy gerist með lyklaborðinu — _ALLT!_ Þegar kerfið ræsir sig í fyrsta sinn geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að birta Omarchy-valmyndina og þaðan geturðu gert svo til allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem helsta leiðin til að stjórna kerfinu mestan tímann. Við getum gert þetta hraðar en það! Öll mikilvægustu forritin eru bundin beint við staka flýtilykla. Þú ræsir skjáherminn með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú sérð töfra flísaröðunar Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim hvort ofan á annað í stað þess að hafa þau hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þau aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta á gluggunum.

Prófaðu nú `Super + Ctrl + T` til að ræsa Virknivaktina. Hún birtist sem fljótandi gluggi. Þú getur flísaröðað honum með `Super + T` (og ýtt aftur á það til að gera hann fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú færð snyrtilega fjögurra glugga uppsetningu:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú ferð á milli glugganna sem þú vilt að sé virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Ef þú heldur `Super` niðri og smellir á glugga með músinni geturðu endurraðað hvar hann situr. Ef þú heldur `Super` niðri og notar hægri músarhnappinn geturðu frjálst breytt stærð gluggans.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (og haldið efstu slánni) með `Super + Alt + F` eða í fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunuppröðun

Sjálfgefna uppröðunin í Omarchy kallast dwindle. Hún heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum öllum stundum, jafnvel þótt hún þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunuppröðunina þar sem gluggar raðast hlið við hlið, út fyrir sýnilega brún skjásins. Þú breytir einu vinnusvæði í þessa uppröðun með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðja ýtingin færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þær í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — helst fljótandi þegar vinnusvæðið fer aftur í flísaröðun. Efsta sláin merkir vinnusvæðið sem þú ert á með uppröðun þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki skiptir líka um uppröðun.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið er fyrir hvert vinnusvæði fyrir sig, og það helst. Svo þú getur haft vinnusvæði 1 í dwindle fyrir vafur og vinnusvæði 2 í skrun fyrir kóða, og þau koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunuppröðunina sem sjálfgefna geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast, og þú færir þá og breytir stærð þeirra sjálfur. Hver gluggi fær titilslá í litunum í þemanu þínu, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forritið hans til að ná honum aftur. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða brún eða horni sem er. Tvísmelltu á titilslá til að hámarka gluggann en halda efstu slánni sýnilegri, og aftur til að fá gömlu stærðina hans til baka.

Fljótandi vinnusvæði sýnir líka bryggju, með föstu forritunum þínum, öllu sem er í gangi, og hnitaneti með öllum forritum á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit í hnitanetinu, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa gluggann þess fram; smelltu aftur til að fara í gegnum glugga þess. Miðjusmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það út, eða hætta í því. Bryggjan víkur fyrir glugga í fullum skjá. Hægrismelltu á forritahnappinn til að færa bryggjuna að annarri brún eða láta hana fela sig þangað til bendillinn nær að brún hennar. Staðsetningin er líka undir _Trigger > Útlit > Bryggja > Staðsetning bryggju_, og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja úr skjáhermi. Forrit sem þú heldur í bryggjunni eru dofnuð á meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið þeirra eigin uppröðun með `Super + L`, nota sjálfgefnu uppröðunina. Að breyta sjálfgefinni uppröðun endurstillir hvert vinnusvæði án glugga í hana, á meðan vinnusvæði með glugga á því heldur uppröðuninni sem það hefur. Gluggi sem er lágmarkaður í bryggjuna telst áfram sem gluggi á vinnusvæðinu sem hann fór frá. Veldu hana undir _Trigger > Útlit > Uppröðun vinnusvæðis_: Flísaröðun, Skrun, eða Fljótandi. `omarchy-hyprland-workspace-layout-default scrolling` stillir hana úr skjáhermi.

### Að hópa glugga

Hægt er að hópa glugga með `Super + G`. Þegar þú ert kominn í hóp mun hver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur farið á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint í hópaðan glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur spretti glugga út úr úthlutun vinnusvæðisins hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Krotblaðsvinnusvæði

Að lokum er sérstakt krotblaðsvinnusvæði sem fellur niður yfir hvaða vinnusvæði sem þú ert á hverju sinni, svipað og Quake-stjórnborð. Kveiktu og slökktu á því með `Super + Grave` eða `Super + S`, og settu glugga þar með `Super + Shift + Grave` eða `Super + Alt + S`.

Það virkar sérstaklega vel fyrir skjáhermi sem keyrir umboðsmann, eða fyrir stýringar sem þú vilt eiga samskipti við fljótt án þess að yfirgefa núverandi vinnusvæði. Til að færa glugga af krotblaðinu skaltu senda hann beint á annað vinnusvæði með einhverju á borð við `Super + Shift + 1`.

Á meðan krotblaðið geymir einn glugga fellur það niður sem miðjusett spjald frekar en að teygja sig yfir skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, svo þau tvö hafi rými til að sitja hlið við hlið.

### Það tekur smá tíma að venjast þessu!

Það tekur smávegis að venjast því að flakka um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna músknúna skjáborðsupplifun!
