# Windows-sýndarvél

Omarchy býður upp á auðvelda leið til að keyra Windows í gegnum Docker-sýndarvél. Þú getur sett hana upp með _Setja upp > Windows_ úr Omarchy-valmyndinni (`Super + Space`).

Vélin þín þarf KVM-sýndarvæðingu fyrir þetta, sem flestar hafa — en það er stundum slökkt á því í BIOS, og uppsetningarforritið mun segja þér ef það er raunin. Þú vilt líka hafa diskaplássið: hvað sem þú gefur Windows, auk um 10GB fyrir myndina sjálfa.

Uppsetningarforritið spyr hversu mikið RAM, hversu marga CPU-kjarna og hversu mikinn disk eigi að afhenda (64GB eða meira er skynsamlega lágmarkið), síðan eftir Windows-notandanafni og lykilorði. Skildu þau eftir auð og þú færð `docker` / `admin`. Niðurhalið tekur nokkurn tíma — 10-15 mínútur eru eðlilegar — og þú getur fylgst með framvindunni í vafranum á `http://127.0.0.1:8006`. Vafrinn biður um sama notandanafn og lykilorð áður en stjórnborðið opnast.

 ![windows-vm](images/windows-vm.webp)

## Að nota hana

Þegar hún er uppsett skaltu ræsa _Windows_ úr forritaræsinum. Það ræsir sýndarvélina ef hún er ekki þegar í gangi og tengir þig yfir RDP, á fullum skjá. Gefðu henni 15-30 sekúndur við kaldræsingu.

RDP-lotan ber hljóð, hljóðnemann þinn og sameiginlegt klippiborð, þannig að það að afrita texta á milli Linux og Windows virkar bara. Upplausnin fylgir glugganum þínum, og Omarchy sendir skjákvörðunina þína í gegn, þannig að það er ekki óskýrt drasl á HiDPI-skjá.

Þegar þú lokar RDP-glugganum slekkur sýndarvélin sjálfkrafa á sér. Ef þú vilt frekar láta hana vera í gangi — segjum að þú hafir eitthvað í vinnslu þar inni — skaltu ræsa hana með `omarchy windows vm launch --keep-alive` í staðinn.

Restin af stjórntækjunum er á sömu skipun:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Að deila skrám

Mappan `~/Windows` í heimamöppunni þinni er sjálfkrafa deild með sýndarvélinni. Settu skrár þangað ef þú vilt að þær séu aðgengilegar fyrir Windows. Sýndarvélin hefur engan aðgang að neinnum öðrum hluta skráakerfisins þíns, þannig að þú ert öruggur fyrir öllu illu af Windows-hliðinni. Hennar eiginn sýndardiskur er tiltækur á `~/.windows`.

Þær kunnuglegu heimaslóðir eru á sínum eigin skráakerfum. Þær geta líka verið tákntenglar á möppur sem þú átt, sem er gagnlegt þegar sýndardiskurinn býr á stærra drifi. Uppsetningarforritið mælir laust pláss á skráakerfinu sem raunverulega inniheldur `~/.windows`, ekki endilega skráakerfinu sem inniheldur heimamöppuna þína.

Haltu diska- og deildum slóðum sem aðskildum, ekki skarandi möppum. Fjarlæging tæmir vísvitandi diskamöppuna en varðveitir deildu möppuna. Rétt fyrir eyðingu framkvæmir Omarchy afmarkaða innilokunarkönnun og neitar að fjarlægja nokkuð ef sú könnun rennur út á tíma eða getur ekki sannað að trén tvö séu aðskilin.

Áður en sýndarvélin ræsist opnar Omarchy og festir þessar tvær möppur, binditengir síðan nákvæmlega möppu-inode-in á einkarekna notenda-ankera fyrir neðan `/var/lib/omarchy/windows/mounts`. Docker sér aðeins þessi rótarvörðu ankeri. Þetta varðveitir sérsniðnar diskastaðsetningar á meðan það kemur í veg fyrir að annað ferli sem keyrir sem þú geti skipt út yfirfarenni slóð áður en forréttindagámurinn notar hana. Núverandi diska- og deildar möppur eru hertar í ham `0700` við flutning þannig að aðrir staðbundnir reikningar geti ekki skoðað innihald þeirra.

Port sýndarvélarinnar eru bundin aðeins við localhost, þannig að ekkert á netinu þínu getur náð til Windows-vélarinnar. Vefstjórnborðið krefst líka stillts Windows-notandanafns og lykilorðs, sem kemur í veg fyrir að annar staðbundinn reikningur keyri sýndarvélina í gegnum port 8006.

## Takmarkanir og leyfi

Það er engin GPU-gegnumleiðsla með þessari uppsetningu, þannig að hún hentar ekki fyrir leiki eða myndbandsvinnslu. Hún er frábær leið til að keyra Microsoft Office eða hvað annað sem þú verður algerlega að hafa.

Útgáfan sem sett er upp er Windows 11 Pro, óvirkjuð. Þú þarft þinn eigin leyfislykil til að nota læstu eiginleikana.

Ef þessi tölva var send með Windows er OEM-lykillinn enn í fastbúnaði jafnvel eftir að Omarchy hefur verið sett upp. Prentaðu hann með `omarchy windows key`. Sá lykill er bundinn við þessa vél — hann mun virkja Windows sem sett er upp aftur á þessum vélbúnaði, en hann mun venjulega ekki virkja sýndarvélina.

Þú getur breytt auðlindaúthlutuninni síðar með því að keyra `omarchy-windows-vm install` aftur, sem endurskrifar stillingar sýndarvélarinnar út frá svörum þínum. Compose-skráin sjálf býr nú á `/var/lib/omarchy/windows/docker-compose.yml` og er í eigu root — það er vísvitandi, þannig að ferli sem keyrir sem þú getur ekki endurskrifað hana og látið forréttindauppræsinguna tengja allan diskinn þinn í gáminn. Ef þú þarft að breyta henni handvirkt (til dæmis til að tengja USB-tæki) skaltu breyta henni með `sudo` og sjá alla valkosti á [Dockur Windows-verkefninu](https://github.com/dockur/windows).

Til að losa þig við allt saman skaltu nota _Fjarlægja > Windows_ úr Omarchy-valmyndinni. Það eyðir diski sýndarvélarinnar og öllum gögnum hennar, þannig að vertu viss um að allt sem þér þykir vænt um sé komið út úr `~/Windows` fyrst.
