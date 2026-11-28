# Flakk

Allt í Omarchy gerist í gegnum lyklaborðið — _ALLT!_ Þegar kerfið ræsist fyrst geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að birta Omarchy Menu og héðan geturðu gert nánast allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem aðalleiðin til að stjórna kerfinu mestan tímann. Við getum verið hraðari en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir terminal með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu, og þú munt sjá töfra flísalögnar Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim ofan á hvorn annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að víxla gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa virknimonitorinn. Hann birtist sem fljótandi gluggi, með titilslá til að draga hann í og hnöppum til að lágmarka, hámarka og loka honum. Sérhver fljótandi gluggi fær eina slíka, hvar sem hann er. Þú getur flísalagt hann með `Super + T` (og ýtt aftur á það til að gera hann fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú verður með snyrtilega fjórskipta uppsetningu:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú flakkar á milli gluggans sem þú vilt að sé virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Með fleiri en einum skjá hefur sérhver skjár vinnusvæði 1 til 10 út af fyrir sig. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á, og efsta slá sérhvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í hring í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það tekur sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem hann hefur fyrir, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur inni `Super` og notar músina til að smella á glugga geturðu endurraðað hvar hann situr. Ef þú heldur inni `Super` og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (og haldið efstu slánni) með `Super + Alt + F` eða í fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunuppsetningu

Sjálfgefin uppsetning Omarchy kallast dwindle. Hún heldur öllum gluggum sem þú opnar á einu vinnusvæði sýnilegum öllum stundum, jafnvel þótt hún þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunuppsetninguna þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir einu vinnusvæði í þessa uppsetningu með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðja ýting færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þær í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísalögn. Efsta sláin merkir vinnusvæðið sem þú ert á með uppsetningu þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í hring í gegnum uppsetninguna, og það gerir skjáhnappurinn á fartölvum sem hafa slíkan líka.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði fyrir sig, og það helst. Þannig geturðu haft vinnusvæði 1 í dwindle fyrir vafur og vinnusvæði 2 í skrun fyrir kóða, og þau munu koma þannig aftur eftir endurræsingu.

Ef þú vilt nota skrunuppsetninguna sem sjálfgefna geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast, og þú færir og stærðarstillir þá sjálfur. Sérhver gluggi fær titilslá í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í dokkunni; smelltu á forrit hans til að fá hann til baka. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilslá til að hámarka gluggann en halda efstu slánni sýnilegri, og aftur til að fá gömlu stærðina hans til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titilslánni og nota sinn eigin haus í staðinn; `Super + Alt + F` hámarkar þá, og `Super + M` lágmarkar þá.

Sérhvert vinnusvæði hefur dokku, með festum forritunum þínum, öllu sem er í gangi, og hnitaneti með sérhverju forriti á bak við forritahnappinn, sem `Super + Alt + Space` og _Apps_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á hnitanetinu, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa glugga þess fram; smelltu aftur til að fara í hring í gegnum glugga þess. Files færir aðeins glugga til baka af vinnusvæðinu sem þú ert á og opnar annars nýjan, og Terminal og Agent ræsa alltaf annan til viðbótar, þótt lágmarkaður gluggi komi fyrst til baka. Miðsmellur opnar nýjan glugga. Dragðu tákn eftir dokkunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í dokkunni, taka það út eða hætta í því. Dokkan helst úti á meðan vinnusvæði er tómt, og um leið og vinnusvæðið hefur glugga felur hún sig þar til bendillinn nær að jaðri hennar. Gluggi í fullum skjá felur hana alveg. Dragðu forritahnappinn í átt að öðrum jaðri skjásins til að færa dokkuna þangað. Hægrismelltu á hann fyrir _Position_, til að velja jaðar, og _Layout_, til að stilla sjálfgefnu uppsetninguna eins og _Appearance > Workspace Layout_ gerir. Staðsetningin er líka undir _Appearance > Dock > Dock Position_, og `omarchy dock position left` stillir hana úr terminal. Forrit sem þú heldur í dokkunni eru dauf á meðan þau eru ekki í gangi. Til að halda dokkunni við fljótandi vinnusvæði skaltu nota _Appearance > Dock > Dock Only on Floating_ eða `omarchy dock tiling off`.

Ný vinnusvæði, og öll sem þú hefur ekki gefið eigin uppsetningu með `Super + L`, nota sjálfgefnu uppsetninguna. Að breyta sjálfgefnu uppsetningunni endurstillir sérhvert vinnusvæði án glugga á hana, á meðan vinnusvæði með glugga á heldur uppsetningunni sem það hefur. Gluggi sem er lágmarkaður í dokkuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu hana undir _Appearance > Workspace Layout_: Tiling, Scrolling eða Floating. `omarchy hyprland workspace layout default scrolling` stillir hana úr terminal.

### Að hópa glugga

Hægt er að hópa glugga með `Super + G`. Þegar þú ert kominn í hóp mun sérhver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur flakkað á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á hópaða glugga í röð.

Þú getur fært glugga út úr hópnum með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta út gluggum

Þú getur sprett glugga út úr úthlutun vinnusvæðis hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-vinnusvæði

Það er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á. Þú nálgast það sem er á því með `Super + S`, og þú setur glugga þar með `Super + Alt + S`.

Það virkar vel fyrir stjórntæki eða terminal sem þú vilt nota fljótt án þess að yfirgefa núverandi vinnusvæði.

### Quake-konsóll

Að lokum er hálfhár Quake-konsóll sem fellur niður yfir hvaða vinnusvæði sem þú ert á. Kveiktu og slökktu á honum með `Super + the key above Tab` (grave á bandarískum lyklaborðsuppsetningum), og settu glugga þar með `Super + Shift + the key above Tab`.

Fyrsta skiptið sem hann opnast ræsir hann sjálfgefna agentinn þinn, eða biður þig um að velja einn ef þú hefur ekki valið einn enn. Á meðan konsóllinn heldur einum glugga fellur hann niður sem miðjusett spjald í stað þess að spanna skjáinn. Settu annað forrit á hann og hann fer aftur í fulla breidd, svo þau tvö hafi pláss til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdavinnusvæðinu eða konsólnum skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Þetta tekur smá tíma að venjast!

Það tekur smá tíma að venjast því að flakka um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna músdrifna skjáborðsupplifun!
