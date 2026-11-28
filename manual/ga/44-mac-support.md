# Tacaíocht do Mac

## Omarchy le haghaidh Apple Silicon

Is réiteach oifigiúil Omacom é Omarchy le haghaidh Apple Silicon, a eisíodh den chéad uair le Omarchy 4.5. Suiteálann sé in aice le macOS, agus roghnaíonn tú idir an dá cheann nuair a thosaíonn do Mac.

Fuair tú fógra faoi Omarchy Mac? Téigh go dtí [Ag teacht ó Omarchy Mac](#coming-from-omarchy-mac).

Ritheann sé ar na Macanna seo:

| Mac | Sceallóga |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Ní thacaítear le Macanna M4 agus níos nuaí fós. Tá tacaíocht M4 á tástáil ar an gcainéal edge agus tiocfaidh sí ina dhiaidh sin. Seiceálann an suiteálaí do Mac sula n-athraíonn sé aon rud.

Ar aon Mac Apple Silicon, M4 agus níos nuaí san áireamh, is féidir leat Omarchy a rith i meaisín fíorúil le [Try Omarchy](https://github.com/omacom/try-omarchy).

### An méid a theastaíonn uait

- macOS 15 Sequoia nó níos déanaí, agus cuntas riarthóra
- Spás diosca saor le haghaidh Omarchy. Molann an suiteálaí méid agus ligeann sé duit é a athrú.
- Cúltaca de do Mac, cumhacht, agus nasc idirlín. Íoslódálann an tsuiteáil roinnt ghigibheart.

### Suiteáil

Suiteálann tú ó macOS. Suiteáil an Omarchy Installer le [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Nó íoslódáil an Omarchy Installer is nuaí óna [leathanach eisiúintí](https://github.com/omacom/omarchy-mac-installer/releases) agus oscail é.

Seiceálann an suiteálaí do Mac, taispeánann sé an plean duit, agus déanann sé spás le haghaidh Omarchy trí dheighilt macOS a chrapadh. Fanann macOS ar an diosca agus ní theastaíonn aon tiomántán USB. Nuair a bhíonn an chéad chéim déanta, treoraíonn sé tú trí chríochnú na socruithe in macOS Recovery: múch, coinnigh an cnaipe cumhachta go dtí go dtaispeántar "Loading startup options", roghnaigh Omarchy, agus lean na céimeanna.

Ar an gcéad tosú, iarrann Omarchy pasfhocal a chriptíonn a dhiosca. Níl aon eochair athshlánaithe ann: má dhéanann tú dearmad ar an bpasfhocal, ní féidir do chomhaid Omarchy a athshlánú.

Chun aistriú idir Omarchy agus macOS níos déanaí, múch, ansin coinnigh an cnaipe cumhachta go dtí go dtaispeántar na roghanna tosaithe agus roghnaigh ceann acu.

### Ag teacht ó Omarchy Mac

Tá Omarchy Mac anois mar chuid de Omarchy le haghaidh Apple Silicon, agus tacaítear le gach Mac a rith é. Leanann do shuiteáil reatha ag rith, agus nuashonraíonn a pacáistí córais fós, ach ní bhfaigheann sí aon nuashonrú Omarchy eile. Níl aon spriocdháta ann agus níl aon uasghrádú ar an láthair ann: déanann tú cúltaca, bain an seansuiteáil, suiteáil as an nua, agus athchóirigh. Tarlaíonn céimeanna 2 go 5 in macOS, mar sin oscail an leathanach seo ar do ghuthán sula n-atosaíonn tú.

1. **Déan cúltaca ó Omarchy, amach ón Mac.** Scriosann baint na seansuiteála í, agus ní féidir le macOS diosca Omarchy a léamh. Cóipeáil d'fhillteán baile chuig tiomántán seachtrach nó ríomhaire eile, lena n-áirítear eochracha SSH agus GPG, próifílí brabhsálaí agus obair nár bhrúigh tú. Sábháil do liosta pacáistí le `pacman -Qqe > ~/packages.txt`. Déan cúltaca de macOS freisin, ós rud é go n-athraíonn baint agus suiteáil araon méid a dhiosca.
2. **Tosaigh do Mac in macOS.** Múch, coinnigh an cnaipe cumhachta go dtí go dtaispeántar na roghanna tosaithe, agus roghnaigh macOS.
3. **Suiteáil an Omarchy Installer** mar a thaispeántar in [Suiteáil](#installing).
4. **Bain an seansuiteáil.** Oscail an Omarchy Installer agus roghnaigh Installation > Remove Omarchy. Taispeánann sé an méid a scriosfaidh sé agus tugann sé an spás ar ais do macOS. Mura n-aithníonn sé do shuiteáil, stopann sé gan an diosca a athrú. Iarr cabhair in [Discord](https://discord.gg/tXFUdasqhY) seachas deighiltí a scriosadh de láimh, rud a d'fhéadfadh macOS a scriosadh.
5. **Suiteáil Omarchy le haghaidh Apple Silicon** leis an suiteálaí.
6. **Athchóirigh do chomhaid.** Tabhair do shocruithe ar ais píosa ar phíosa seachas an `~/.config` ar fad a chóipeáil thar na réamhshocruithe nua, ós rud é gur féidir le seansocruithe iad a shárú.

### Maith a fhios

- Ar MacBookanna M1 agus M2, dúisigh ó chodladh tríd an gclúdach a oscailt nó an cnaipe cumhachta a bhrú.
- Ceisteanna nó fadhbanna: iarr inár [Discord](https://discord.gg/tXFUdasqhY).

Clúdaíonn [README an tsuiteálaí](https://github.com/omacom/omarchy-mac-installer#readme) cainéil eisiúna, nuashonrú an tsuiteálaí agus baint Omarchy.

## Macanna Intel

I dtástáil shimplí, bhíomar in ann gnóthachain feidhmíochta 36% a bhaint amach ar MacBook Pro 2019 díreach trí Omarchy a shuiteáil.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy a shuiteáil ar Mac

Ní thacaíonn Omarchy ach le bheith mar an t-aon OS **amháin** suiteáilte faoi láthair. Le linn na suiteála, glanfar an tiomántán agus ní bheidh MacOS intosaithe a thuilleadh.

Is féidir leat é a athchóiriú fós níos déanaí trí Internet Recovery más mian leat.

Ar mhaithe leis an gcuid seo, glacfaimid leis go ndearna tú athbhreithniú cheana ar [Ag Tosú](02-getting-started.md) agus go bhfuil do thiomántán USB réidh agat. Mura ndearna, téigh ar aghaidh agus déan é sin anois.

#### Díchumasaigh Secure Boot

Is gá Secure Boot Apple a dhíchumasú chun an USB intosaithe a thosú, chomh maith leis an OS. Chun é a dhíchumasú, déan an méid seo a leanas:

1. Múch do Mac
2. Cas air é agus brúigh agus coinnigh Command-R _láithreach_ go dtí go bhfeiceann tú an scáileán lódála le feiceáil
3. Roghnaigh d'úsáideoir agus cuir isteach do phasfhocal má iarrtar ort
4. Nuair a bhíonn tú ar an scáileán athshlánaithe, roghnaigh **Utilities > Startup Security Utility** ón mbarra roghchláir
5. Cuir isteach do phasfhocal nuair a iarrtar ort fíordheimhniú a dhéanamh
6. Roghnaigh "No Security" ó na roghanna Secure Boot
7. Roghnaigh "Allow booting from external or removable media" ó na roghanna External Boot

#### Tosaigh an tSuiteáil

1. Cuir isteach an tiomántán USB
2. Atosaigh do Mac agus brúigh agus coinnigh Option _láithreach_ go dtí go bhfeiceann tú scáileán de ghléasanna tosaithe
3. Roghnaigh an gléas EFI Boot oráiste
4. Lean ar aghaidh leis an [tsuiteáil mar is gnách](02-getting-started.md)

Aimsíonn an suiteálaí crua-earraí Mac agus cuireann sé na deisiúcháin a theastaíonn i bhfeidhm go huathoibríoch: tiománaithe agus fionware Broadcom Wi-Fi, tiománaí cheamara FaceTime HD ar mheaisíní le Broadcom 1570 (íoslódáiltear a fhionware ó Apple nuair a bhíonn an Mac ar líne, ós rud é go n-oibríonn an suiteálaí as líne), tiománaí mhéarchláir SPI ar na samhlacha MacBook a theastaíonn sé uathu, agus deisiú fionraí NVMe do na samhlacha céanna sin.

### Teorainneacha Aitheanta

Bíonn baill den phobal ag obair i gcónaí ar réitigh ar na dúshláin seo mar sin má tá siad seo ina bhfadhb duit, bí páirteach in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY) agus féach an bhfuil aon mhodhanna cothrom le dáta ann chun iad seo a réiteach.

#### Ceamara FaceTime HD

Crochtann tiománaí an cheamara an meaisín má dhéantar é a lódáil nuair a théann an Mac i gcodladh geimhridh, mar sin dílódáiltear ar dtús é. Ní féidir é a dhílódáil fad atá an ceamara ar oscailt ag aip, mar sin cealaítear codladh geimhridh le fógra a ainmníonn an aip: dún í agus téigh i gcodladh geimhridh arís. Áirítear leis sin dul i gcodladh geimhridh go huathoibríoch ar chadhnra criticiúil, agus fionraí-ansin-codladh-geimhridh, a dhiúltaítear sula gcuirtear ar fionraí é. Diúltaíonn an tiománaí féin fionraí gnáth fad atá an ceamara ar oscailt, gan fógra.

Íoslódáiltear fionware an cheamara ó Apple, mar sin ní oibríonn an ceamara ach amháin nuair a bhíonn an Mac ar líne. Tosaíonn an íoslódáil ag an tosú agus déantar iarracht arís uirthi gach 15 nóiméad fad is é an líonra an fhadhb; má tá comhad Apple athraithe, stopann sé agus fanann sé le nuashonrú Omarchy. Mura dtaispeántar an ceamara, deir `journalctl -u facetimehd-firmware-fetcher` cén fáth, déanann `sudo systemctl restart facetimehd-firmware-fetcher` iarracht arís, agus lódálann atusú an tiománaí má chríochnaigh an íoslódáil ach mura bhfuil an ceamara ann fós.

#### Gléasanna le Sceallóg T1

Tugadh sceallóg Apple T1 isteach go déanach in 2016 agus úsáideadh go heisiach í sna samhlacha MacBook Pro den chéad ghlúin le Touch Bar.
- MacBook Pro 13-orlach (2016, dhá phort Thunderbolt 3) – Samhail: A1706
- MacBook Pro 13-orlach (2016, ceithre phort Thunderbolt 3) – Samhail: A1708
- MacBook Pro 15-orlach (2016) – Samhail: A1707

#### Fadhbanna Aitheanta

- Níl Touch Bar feidhmiúil
- Níl an fhuaim ag feidhmiú

#### Gléasanna le Sceallóg T2

Tugadh Sceallóg Slándála Apple T2 isteach in 2017. Scoireadh de sceallóg T2 leis an aistriú go Apple silicon (sceallóga na sraithe M) ag tosú in 2020.

- iMac Pro (2017) – Samhail: A1862
- MacBook Pro 13-orlach (2018, ceithre phort Thunderbolt 3) – Samhail: A1989
- MacBook Pro 15-orlach (2018) – Samhail: A1990
- MacBook Air (Retina, 13-orlach, 2018) – Samhail: A1932
- Mac mini (2018) – Samhail: A1998
- MacBook Pro 13-orlach (2019, dhá phort Thunderbolt 3) – Samhail: A2159
- MacBook Pro 13-orlach (2019, ceithre phort Thunderbolt 3) – Samhail: A2178
- MacBook Pro 15-orlach (2019) – Samhail: A1990
- iMac (Retina 5K, 27-orlach, 2020) – Samhail: A2115 (iMac20,1 agus iMac20,2)
- MacBook Pro 13-orlach (2020, dhá phort Thunderbolt 3) – Samhail: A2265
- MacBook Pro 15-orlach (2020) – Samhail: A1990

Ar na samhlacha seo, socraíonn an suiteálaí go huathoibríoch an eithne `linux-t2` phaistithe, cumraíocht fuaime T2, fionware Broadcom Wi-Fi/Bluetooth Apple, agus rialú fean trí `t2fanrd`. Ritheann Touch Bar ar thacaíocht ionsuite ar stíl Boot Camp an eithne.

#### iMac Retina 5K (2017)

Níl sceallóg T2 ag iMac 27-orlach 2017, mar sin socraíonn an suiteálaí é mar a dhéanann sé leis na Macanna Intel eile.

- iMac (Retina 5K, 27-orlach, 2017) – Samhail: A1419

#### Fadhbanna Aitheanta

- Ní ritheann an taispeáint ag a réiteach dúchasach 5120×2880: is dhá thíl an painéal, agus ní lasann an tiománaí stoc ach ceann amháin
- Níl an fhuaim ag feidhmiú
- Níl aon éifeacht ag an rialú gile
- Crochtann codladh an meaisín; is timthriall cumhachta amháin a athshlánaíonn é

Deisíonn paisteálaí pobail don tsamhail seo an taispeáint, an fhuaim agus an ghile: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
