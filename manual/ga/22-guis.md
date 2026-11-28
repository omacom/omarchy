# GUIs

## Comhaid

Is é Files (Folio) an bainisteoir comhad grafach. Osclaíonn `Super + Shift + F` é, agus osclaíonn `Super + Shift + Alt + F` é sa chomhadlann ina bhfuil do theirminéal faoi láthair, rud a shábhálann go leor cliceála. Ligeann `Ctrl + L` duit cosán a chlóscríobh, agus réamhamharctar aon chomhad ag lánmhéid gan é a oscailt má bhrúnn tú `Space` air.

Cuir bata USB nó cárta SD isteach agus gléastar go huathoibríoch é, mar sin ní thaispeántar é ach sa bharra taoibh. Le haghaidh aon rud níos casta — tiomántán a fhormáidiú, sláinte SMART a sheiceáil, deighiltí a chruthú — seol _Disks_ ón lainseálaí feidhmchlár (`Super + Space`).

Iarrann tiomántán criptithe a phasfhocal nuair a chuirtear isteach é. Chun go ndíghlasálfaidh ceann é féin, cuir eochairchomhad leis le `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` agus cuir an eochairchomhad sin ag `~/.config/omarchy/drive-keys/<UUID>`, ainmnithe de réir an UUID a phriontálann `lsblk -dno UUID /dev/sdX1` don deighilt chriptithe, agus inléite agatsa amháin (`chmod 600`). Má tá an eochairchomhad sin ar iarraidh nó má dhiúltaítear é, iarrtar an pasfhocal ort mar is gnách.

Leanann cliceáil faoi dhó réamhshocruithe ciallmhara: osclaítear pictiúir, físeáin agus ceol in Omaview, PDFanna in Document Viewer, Markdown in Omawrite, agus gnáth-théacs i d'eagarthóir, Plain mura roghnaíonn tú ceann eile faoi _Socrú > Réamhshocruithe > Eagarthóir_.

## Disktree

Nuair a líonann an tiomántán agus gan aon tuairim agat cad atá á ithe, seol [Disktree](https://github.com/tobi/disktree) ón lainseálaí feidhmchlár (`Super + Space`). Taispeánann sé treemap grafach de do chomhadlann baile. Tógann bloic níos mó níos mó spáis; siúil isteach i gcomhadlanna leis an méarchlár nó leis an luch, marcáil cad ba chóir imeacht, agus déan athbhreithniú ar do roghanna sula mbaintear aon rud. Rith `disktree --disk` chun an diosca ar fad a scanadh.

## Obsidian

Is feidhmchlár nótaí saor in aisce agus an-insínte é [Obsidian](https://obsidian.md/) a úsáideann comhaid shimplí Markdown le haghaidh stórála.

Tá Obsidian saor in aisce chun gach críche, lena n-áirítear úsáid phearsanta, tráchtála agus neamhbhrabúis.

Cuireann Obsidian [breiseán tráchtála ar fáil freisin le haghaidh sioncronaithe](https://obsidian.md/sync) le haipeanna soghluaiste ar iOS agus Android. (https://obsidian.md/pricing).

Tosaíonn tú Obsidian le `Super + Shift + O`. Chun sioncronú téama a úsáid, ní mór duit an téama `Omarchy` a roghnú faoi na socruithe.

## Omawrite

Is é [Omawrite](https://github.com/omacom-io/omawrite) aip scríbhneoireachta Markdown féin Omarchy atá fíorshimplí. Gan bhoghtaí, gan bhreiseáin, tusa agus na focail amháin.

Tosaíonn tú Omawrite le `Super + Shift + W`.

## Pinta

Uirlis bhunúsach eagarthóireachta íomhánna é [Pinta](https://www.pinta-project.com/) atá iontach le haghaidh bearradh, athrú méide, agus bun-ionramhálacha eile. Ná bí ag súil le rogha eile ar Photoshop. Ach tá Magic Wand agus sraitheanna aige fós!

Tosaíonn tú Pinta tríd an lainseálaí feidhmchlár (`Super + Space`).

## Aether

Feidhmchlár téamúcháin é [Aether](https://github.com/bjarneo/aether) ar féidir leis dathanna a bhaint as íomhá chúlra agus téama iomlán comhtháite a dhéanamh astu. Is é an bealach is éasca é chun [do théama féin a dhéanamh](43-making-your-own-theme.md).

Tosaíonn tú Aether tríd an lainseálaí feidhmchlár (`Super + Space`).

## LocalSend

Ligeann [LocalSend](https://localsend.org/) duit comhaid a sheoladh chuig gléasanna eile ar an líonra céanna a bhfuil an aip ar siúl orthu, cosúil le AirDrop de chuid Apple. Tá sé tras-ardán, áfach, mar sin is féidir leat comhaid a sheoladh chuig Windows, macOS, Android, iOS, agus ar ndóigh Linux, agus uathu.

Is féidir leat an roghchlár Comhroinn a oscailt ar `Super + Ctrl + S` nó faoi _Truicear > Comhroinn_ i roghchlár Omarchy. Tugann sé ceithre rogha duit:

- Seolann **Clipboard** cibé rud a chóipeáil tú mar chomhad téacs. Iontach chun nasc nó giota a chur ar do ghuthán gan ríomhphost a sheoladh chugat féin.
- Osclaíonn **File** roghnóir comhad inar féidir leat roinnt a roghnú ag an am céanna.
- Seolann **Folder** comhadlann iomlán.
- Osclaíonn **Receive** LocalSend féin ionas gur féidir le gléas eile rud éigin a sheoladh chugat.

Oibríonn an rud céanna ón teirminéal le `omarchy share clipboard`, `omarchy share file [path]`, agus `omarchy share folder [path]`. Fág an cosán ar lár agus gheobhaidh tú an roghnóir.

Is féidir leat seoladh díreach ón mbainisteoir comhad freisin: deaschliceáil aon rogha in Files agus comhroinn le LocalSend é.

Tá balla dóiteáin Omarchy dúnta de réir réamhshocraithe ach amháin i gcás phort LocalSend, mar sin oibríonn sé seo as an mbosca ar shuiteáil úr. Féach [slándáil](48-security.md).

## LibreOffice

Pacáiste oifige iomlán é [LibreOffice](https://www.libreoffice.org/) le próiseálaí focal, scarbhileog, cur i láthair, feidhmchlár líníochta, agus tuilleadh. Tá sé comhoiriúnach le comhaid ó Microsoft Office, mar sin is bealach iontach é seo chun bheith in ann na doiciméid Word sin a oscailt.

Tosaíonn tú LibreOffice tríd an lainseálaí feidhmchlár (`Super + Space`).

## Hype

Is é [Hype](https://github.com/omacom/hype) aip cur i láthair féin Omarchy atá fíorshimplí. Is comhad aonair Markdown é do dheic agus a íomhánna agus a fhíseáin in aice leis: scríobh gach sleamhnán faoi réamhamharc beo, tarraing sleamhnáin in ord, ansin cuir i láthair ar lánscáileán nó easpórtáil chuig PDF agus PowerPoint é. Piocann sé suas do théama Omarchy fiú.

Tosaíonn tú Hype tríd an lainseálaí feidhmchlár (`Super + Space`). Brúigh `?` istigh ann chun gach aicearra a fheiceáil.

## Signed

Is é [Signed](https://github.com/omacom/signed) bealach féin Omarchy atá fíorshimplí chun PDFanna a shíniú agus a líonadh isteach. Cuir do shíniú sábháilte, téacs, agus dáta an lae inniu áit ar bith ar leathanach, ansin sábháil cóip shínithe in aice leis an mbunleagan. Féach [PDFanna a líonadh](27-filling-out-pdfs.md) chun a fháil amach conas.

Tosaíonn tú Signed tríd an lainseálaí feidhmchlár (`Super + Space`), nó osclaíonn tú PDF leis ón mbainisteoir comhad.

## Game Vibes

Is in Game Vibes, sa lainseálaí feidhmchlár (`Super + Space`), a chónaíonn cluichí beaga Omarchy: Checkmate, cluiche fichille 3D i gcoinne cara nó an fhreasúra ionsuite; Cards, Klondike solitaire; Death Wish, platformer picteilín-beacht de dheich seomra lán de spící agus sábha; agus Neon Swarm, cluiche lámhaigh stuara. Is leathanach gréasáin aonair é gach ceann acu a leanann do théama. Roghnaigh ceann leis na saigheada agus `Enter`, agus tar ar ais chuig an liosta le `Esc` ó scáileán teidil cluiche nó le `Q` agus é ar sos. Osclaíonn sé ar lánscáileán: déanann `Super + F` fuinneog de, agus dúnann `Super + W` é.

Taispeántar na cluichí a dhéanann tú le gníomhaire anseo freisin: roghnaigh _Déan rud éigin fionnuar → Game_ sa phainéal gníomhairí agus déan cur síos ar cheann, nó ainmnigh cluiche atá in Game Vibes cheana chun leanúint ar aghaidh ag obair air. Cóipeálann an gníomhaire isteach in `~/Games/vibes` é, áit a bhfuil sé leat le hathrú, agus osclaíonn sé é nuair atá sé déanta. Is féidir leat an chóip sin a dhéanamh tú féin le `omarchy games vibes copy <game>`. Suiteálann cluiche a chomhroinneann duine eile cosúil le téama: roghnaigh _Suiteáil > Cluichíocht > Game Vibes_ agus greamaigh a sheoladh git, nó rith `omarchy games vibes install <git-repo-url>`. Tógann _Bain > Cluichíocht_ ceann amach arís, agus faigheann _Nuashonraigh > Game Vibes Games_ leaganacha nua. Luchtaíonn cluichí three.js ón ngréasán, mar sin teastaíonn nasc uathu chun tosú.

## Omacalc

Is é [Omacalc](https://github.com/omacom-io/omacalc) áireamhán féin Omarchy atá fíorshimplí, a osclaíonn i bhfuinneog ar foluain.

Tosaíonn tú Omacalc le `Super + Shift + Q` (nó an eochair áireamháin, má tá ceann ag do mhéarchlár).

## Signal

Is é [Signal](https://signal.org/) ceannródaí na teachtaireachtaí criptithe E2E, agus is rogha cumarsáide iontach é d'aon duine ar fearr leis gan dul trí cheann de na comhlachtaí móra teicneolaíochta.

Tosaíonn tú Signal le `Super + Shift + G`. Níl sé mar chuid den bhunsuiteáil, mar sin an chéad uair a bhuaileann tú é sin, tairgfidh Omarchy é a shuiteáil duit (tá sé faoi _Suiteáil > Seirbhís_ i roghchlár Omarchy freisin).

## Omaview

Is é [Omaview](https://github.com/omacom/omaview) breathnóir pictiúr agus seinnteoir meán féin Omarchy atá fíorshimplí: fuinneog amháin do do ghrianghraif, físeáin agus ceol. Oscail grianghraf agus céimníonn na heochracha saighde tríd an gcuid eile dá fhillteán, déanann `N` agus `P` é d'aon rud, agus taispeánann `Ctrl + M` an fillteán ar fad mar ghreille. Taispeánann sé grianghraif HEIC, AVIF, agus JPEG XL freisin, agus leanann sé ar aghaidh ón áit ar fhág tú aon rud fada.

Brúigh `F` le haghaidh lánscáileáin, `E` chun pictiúr a chur in eagar in Omasnap nó físeán a bhearradh in Omacut, `Ctrl + P` chun pictiúr a phriontáil, agus `Delete` chun comhad a bhogadh chuig an mBruscar (`Ctrl + Z` a thugann ar ais é). Brúigh `?` istigh ann chun gach aicearra a fheiceáil.

Tosaíonn tú Omaview mar _Media Viewer_ tríd an lainseálaí feidhmchlár (`Super + Space`), nó ní gá ach cliceáil faoi dhó ar phictiúr, físeán, nó amhrán sa bhainisteoir comhad.

## Omacut

Is é [Omacut](https://github.com/omacom-io/omacut) bearrthóir físeán féin Omarchy atá fíorshimplí. Nuair nach gá duit ach an tús agus an deireadh a ghearradh de ghearrthóg, is fearr é ná eagarthóir físeán iomlán a thosú.

Tosaíonn tú Omacut tríd an lainseálaí feidhmchlár (`Super + Space`).

## Monologue

Is é [Monologue](https://github.com/omacom/monologue) taifeadán ceamara gréasáin féin Omarchy atá fíorshimplí. Roghnaigh do cheamara agus do mhicreafón uair amháin, ansin brúigh `Space` chun taifeadadh, agus arís chun an seat céanna a chur ar sos agus a atosú. Taifeadann sé i gcónaí ag taifeach is airde do cheamara, le méadar micreafóin beo ionas gur féidir leat do leibhéil a sheiceáil sula dtosaíonn tú.

Stop an seat agus osclaíonn sé láithreach in eagarthóir ionsuite. Déan cliceáil faoi dhó ar ghearrthóg chun é a scoilt, tarraing na hanlaí chun gach píosa a bhearradh, agus bain na codanna nach dteastaíonn uait. Ansin sábháil mar MP4 é. Coinnítear do thaifeadadh bunaidh go dtí go gcaitheann tú amach é, mar sin is féidir leat teacht ar ais i gcónaí agus é a ghearradh ar bhealach eile.

Tosaíonn tú Monologue tríd an lainseálaí feidhmchlár (`Super + Space`).
