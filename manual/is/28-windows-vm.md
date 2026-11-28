# Windows VM

Omarchy býður upp á einfalda leið til að keyra Windows í gegnum Docker VM á x86_64-vélum. Þú getur sett það upp með _Install > Windows_ í Omarchy-valmyndinni (`Super + Space`).

Vélin þín þarf KVM-sýndarvæðingu til þess, sem flestar styðja — en stundum er slökkt á henni í BIOS og uppsetningarforritið lætur þig vita ef svo er. Þú vilt líka hafa diskaplássið: það sem þú gefur Windows, auk um 10GB fyrir ímyndina sjálfa.

Uppsetningarforritið spyr hversu mikið RAM, hversu marga CPU-kjarna og hversu mikinn disk þú vilt afhenda (64GB eða meira er skynsamlegt lágmark), síðan um Windows-notandanafn og lykilorð. Skildu þau eftir auð og þú færð `docker` / `admin`. Niðurhalið tekur drjúgan tíma — 10-15 mínútur eru eðlilegar — og þú getur fylgst með framvindunni í vafranum á `http://127.0.0.1:8006`. Vafrinn biður um sama notandanafn og lykilorð áður en hann opnar stjórnborðið.

 ![windows-vm](images/windows-vm.webp)

## Að nota það

Þegar það er sett upp skaltu ræsa _Windows_ úr forritavalmyndinni. Það ræsir VM-ið ef það er ekki þegar í gangi og tengir þig yfir RDP, á fullum skjá. Gefðu því 15-30 sekúndur við kaldræsingu.

RDP-lotan flytur hljóð, hljóðnemann þinn og sameiginlegt klippiborð, svo það að afrita texta á milli Linux og Windows virkar bara. Upplausnin fylgir glugganum þínum og Omarchy sendir skjákvörðunina þína í gegn, svo þetta er ekki óskýrt drasl á HiDPI-skjá.

Þegar þú lokar RDP-glugganum slekkur VM-ið sjálfkrafa á sér. Ef þú vilt frekar láta það halda áfram að keyra — segjum að eitthvað sé að vinna þar inni — skaltu ræsa það með `omarchy windows vm launch --keep-alive` í staðinn.

Hin stjórntækin eru á sömu skipun:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Að deila skrám

Mappan `~/Windows` í heimamöppunni þinni er sjálfkrafa deilt með VM-inu. Settu skrár þar ef þú vilt að Windows hafi aðgang að þeim. VM-ið hefur engan aðgang að neinum öðrum hluta skráarkerfisins þíns, svo þú ert öruggur fyrir öllu óþægilegu frá Windows-hliðinni. Eiginn sýndardiskur þess er aðgengilegur á `~/.windows`.

Þessar kunnuglegu heimaleiðir eru áfram á sínum eigin skráarkerfum. Þær geta líka verið tákntenglar í möppur sem þú átt, sem er gagnlegt þegar sýndardiskurinn er á stærra drifi. Uppsetningarforritið mælir laust pláss á skráarkerfinu sem í raun inniheldur `~/.windows`, ekki endilega skráarkerfinu sem inniheldur heimamöppuna þína.

Haltu diskaleiðinni og deildu leiðinni sem aðskildum möppum sem skarast ekki. Fjarlæging tæmir vísvitandi diskamöppuna en varðveitir deildu möppuna. Rétt fyrir eyðingu framkvæmir Omarchy takmarkaða innilokunarathugun og neitar að fjarlægja nokkuð ef sú athugun rennur út á tíma eða getur ekki sannað að möppurnar tvær séu aðskildar.

Áður en VM-ið ræsist opnar og festir Omarchy þessar tvær möppur, bind-tengir síðan nákvæm inode möppanna á einkaakkeri fyrir hvern notanda undir `/var/lib/omarchy/windows/mounts`. Docker sér aðeins þessi akkeri sem root verndar. Þetta varðveitir sérsniðnar diskastaðsetningar en kemur í veg fyrir að annað ferli sem keyrir sem þú geti skipt út athugaðri leið áður en forréttindagáminn notar hana. Núverandi diskamöppur og deildar möppur eru hertar í haminn `0700` við flutninginn svo aðrir staðbundnir reikningar geti ekki skoðað innihald þeirra.

Gáttir VM-sins eru aðeins bundnar við localhost, svo ekkert á netinu þínu nær til Windows-vélarinnar. Vefstjórnborðið krefst líka stillta Windows-notandanafnsins og lykilorðsins, sem kemur í veg fyrir að annar staðbundinn reikningur stjórni VM-inu í gegnum gátt 8006.

## Takmarkanir og leyfi

Það er engin GPU gegnumleiðsla með þessari uppsetningu, svo hún hentar ekki fyrir tölvuleiki eða myndbandsklippingu. Hún er frábær leið til að keyra Microsoft Office eða hvað annað sem þú þarft algjörlega að hafa.

Útgáfan sem er sett upp er Windows 11 Pro, óvirkjuð. Þú þarft þinn eigin leyfislykil til að nota eiginleikana sem eru læstir á bak við virkjun.

Ef þessi tölva kom með Windows er OEM-lykillinn enn í fastbúnaðinum jafnvel eftir að Omarchy hefur verið sett upp. Prentaðu hann með `omarchy windows key`. Sá lykill er bundinn við þessa vél — hann virkjar Windows sem er sett aftur upp á þessum vélbúnaði, en hann virkjar venjulega ekki VM-ið.

Þú getur breytt úthlutun auðlinda síðar með því að keyra `omarchy windows vm install` í skjáhermi, sem endurskrifar stillingar VM-sins út frá svörunum þínum. Compose-skráin sjálf er nú á `/var/lib/omarchy/windows/docker-compose.yml` og er í eigu root — það er viljandi, svo ferli sem keyrir sem þú geti ekki endurskrifað hana og látið forréttindaræsingu tengja allan diskinn þinn inn í gáminn. Ef þú þarft að breyta henni handvirkt (til dæmis til að tengja USB-tæki) skaltu breyta henni með `sudo` og sjá alla valkostina á [Dockur Windows-verkefninu](https://github.com/dockur/windows).

Til að losa þig við allt saman skaltu nota _Remove > Windows_ í Omarchy-valmyndinni. Það eyðir diski VM-sins í `~/.windows` og öllu sem er sett upp inni í Windows, svo afritaðu allt sem þú þarft út úr VM-inu fyrst. Sameiginlegu `~/Windows` möppunni þinni er sleppt í friði.
