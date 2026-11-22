# Tacaíocht Mac

## Omarchy do Apple Silicon

Is réiteach oifigiúil de chuid Omacom é Omarchy do Apple Silicon, a eisíodh den chéad uair le Omarchy 4.5. Suiteálann sé in aice le macOS, agus roghnaíonn tú idir an dá cheann nuair a thosaíonn do Mac.

An bhfuair tú fógra faoi Omarchy Mac? Téigh go [Ag teacht ó Omarchy Mac](#coming-from-omarchy-mac).

Ritheann sé ar na Macanna seo:

| Mac | Sliseanna |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Ní thacaítear le Macanna M4 agus níos nuaí go fóill. Tá tacaíocht M4 á tástáil ar an gcainéal edge agus tiocfaidh sí ina dhiaidh sin. Seiceálann an suiteálaí do Mac sula n-athraíonn sé aon rud.

Ar aon Mac Apple Silicon, M4 agus níos nuaí san áireamh, is féidir leat Omarchy a rith i meaisín fíorúil le [Try Omarchy](https://github.com/omacom/try-omarchy).

### A bhfuil uait

- macOS 15 Sequoia nó níos déanaí, agus cuntas riarthóra
- Spás diosca saor do Omarchy. Molann an suiteálaí méid agus ligeann sé duit é a athrú.
- Cúltaca de do Mac, cumhacht, agus nasc idirlín. Íoslódálann an tsuiteáil roinnt ghigibheart.

### Suiteáil

Suiteálann tú ó macOS. Suiteáil an Omarchy Installer le [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Nó íoslódáil an Omarchy Installer is nuaí óna [leathanach eisiúintí](https://github.com/omacom/omarchy-mac-installer/releases) agus oscail é.

Seiceálann an suiteálaí do Mac, taispeánann sé an plean duit, agus déanann sé spás do Omarchy trí dheighilt macOS a chrapadh. Fanann macOS ar an diosca agus ní gá tiomántán USB. Nuair a bhíonn an chéad chéim déanta, treoraíonn sé tú tríd an socrú a chríochnú i macOS Recovery: múch, coinnigh an cnaipe cumhachta síos go dtí go bhfeictear "Loading startup options", roghnaigh Omarchy, agus lean na céimeanna.

Ar an gcéad tosú, iarrann Omarchy pasfhocal a chriptíonn a dhiosca. Níl aon eochair aisghabhála ann: má dhéanann tú dearmad ar an bpasfhocal, ní féidir do chomhaid Omarchy a aisghabháil.

Chun aistriú idir Omarchy agus macOS níos déanaí, múch, ansin coinnigh an cnaipe cumhachta síos go dtí go bhfeictear na roghanna tosaithe agus roghnaigh ceann acu.

### Ag teacht ó Omarchy Mac

Tá Omarchy Mac anois ina chuid de Omarchy do Apple Silicon, agus tacaítear le gach Mac a rith é. Leanann do shuiteáil reatha ag rith, agus nuashonraíonn a pacáistí córais fós, ach ní fhaigheann sí nuashonruithe Omarchy níos mó. Níl aon spriocdháta ann agus níl aon uasghrádú in-áit ann: déanann tú cúltaca, baineann tú an sean-suiteáil, suiteálann tú as an nua, agus athchóiríonn tú. Tarlaíonn céimeanna 2 go 5 i macOS, mar sin oscail an leathanach seo ar do ghuthán sula n-atosaíonn tú.

1. **Déan cúltaca ó Omarchy, amach ón Mac.** Scriosann baint na sean-suiteála í, agus ní féidir le macOS diosca Omarchy a léamh. Cóipeáil d'fhillteán baile chuig tiomántán seachtrach nó ríomhaire eile, eochracha SSH agus GPG, próifílí brabhsálaí agus obair neamhbhrúite san áireamh. Sábháil do liosta pacáistí le `pacman -Qqe > ~/packages.txt`. Déan cúltaca de macOS freisin, ós rud é go n-athraíonn baint agus suiteáil araon méid a dhiosca.
2. **Tosaigh do Mac i macOS.** Múch, coinnigh an cnaipe cumhachta síos go dtí go bhfeictear na roghanna tosaithe, agus roghnaigh macOS.
3. **Suiteáil an Omarchy Installer** mar a thaispeántar in [Suiteáil](#installing).
4. **Bain an sean-suiteáil.** Oscail an Omarchy Installer agus roghnaigh Installation > Remove Omarchy. Taispeánann sé a bhfuil sé chun a scriosadh agus tugann sé an spás ar ais do macOS. Mura n-aithníonn sé do shuiteáil, stopann sé gan an diosca a athrú. Iarr cabhair in [Discord](https://discord.gg/tXFUdasqhY) seachas deighiltí a scriosadh de láimh, rud a fhéadann macOS a scriosadh.
5. **Suiteáil Omarchy do Apple Silicon** leis an suiteálaí.
6. **Athchóirigh do chomhaid.** Tabhair do shocruithe ar ais píosa ar phíosa seachas an `~/.config` ar fad a chóipeáil thar na réamhshocruithe nua, ós rud é gur féidir le seansocruithe iad a shárú.

### Maith a fhios

- Ar MacBookanna M1 agus M2, dúisigh ó chodladh tríd an gclúdach a oscailt nó an cnaipe cumhachta a bhrú.
- Ceisteanna nó fadhbanna: fiafraigh inár [Discord](https://discord.gg/tXFUdasqhY).

Clúdaíonn [README an tsuiteálaí](https://github.com/omacom/omarchy-mac-installer#readme) cainéil eisiúna, an suiteálaí a nuashonrú agus Omarchy a bhaint.

## Macanna Intel

I dtástáil shimplí, bhíomar in ann gnóthachain feidhmíochta 36% a bhaint amach ar MacBook Pro 2019 díreach trí Omarchy a shuiteáil.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy a shuiteáil ar Mac

Ní thacaíonn Omarchy ach le bheith mar an t-aon OS suiteáilte faoi láthair. Le linn na suiteála, glanfar an tiomántán agus ní bheidh MacOS intosaithe a thuilleadh.

Is féidir leat é a athchóiriú níos déanaí fós trí Internet Recovery más mian leat.

Ar mhaithe leis an gcuid seo, glacfaimid leis go bhfuil [Ag Tosú](02-getting-started.md) athbhreithnithe agat cheana agus go bhfuil do thiomántán USB réidh agat. Mura bhfuil, téigh ar aghaidh agus déan é sin anois.

#### Díchumasaigh Secure Boot

Is gá Secure Boot Apple a dhíchumasú chun an USB intosaithe a thosú, chomh maith leis an OS. Chun é a dhíchumasú, déan an méid seo a leanas:

1. Múch do Mac
2. Cas air é agus brúigh agus coinnigh Command-R _láithreach_ go dtí go bhfeiceann tú an scáileán lódála
3. Roghnaigh d'úsáideoir agus cuir isteach do phasfhocal má iarrtar ort
4. Nuair a bhíonn tú sa scáileán aisghabhála, roghnaigh **Utilities > Startup Security Utility** ón mbarra roghchláir
5. Cuir isteach do phasfhocal nuair a iarrtar ort fíordheimhniú a dhéanamh
6. Roghnaigh "No Security" ó na roghanna Secure Boot
7. Roghnaigh "Allow booting from external or removable media" ó na roghanna External Boot

#### Tosaigh an Suiteáil

1. Cuir isteach an tiomántán USB
2. Atosaigh do Mac agus brúigh agus coinnigh Option _láithreach_ go dtí go bhfeiceann tú scáileán gléasanna tosaithe
3. Roghnaigh an gléas oráiste EFI Boot
4. Lean ar aghaidh leis an [suiteáil mar is gnách](02-getting-started.md)

Aimsíonn an suiteálaí crua-earraí Mac agus cuireann sé na ceartúcháin is gá i bhfeidhm go huathoibríoch: tiománaithe agus firmware Broadcom Wi-Fi, tiománaí méarchláir SPI ar na samhlacha MacBook a dteastaíonn sé uathu, agus ceartúchán fionraí NVMe do na samhlacha céanna sin.

### Teorainneacha Aitheanta

Bíonn baill den phobal ag obair i gcónaí ar réitigh do na dúshláin seo, mar sin má chruthaíonn siad seo fadhbanna duit, bí páirteach in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY) agus féach an bhfuil aon mhodhanna cothrom le dáta ann chun iad seo a réiteach.

#### Gléasanna le Slis T1

Tugadh slis Apple T1 isteach go déanach in 2016 agus úsáideadh go heisiach sna samhlacha MacBook Pro den chéad ghlúin le Touch Bar.
- MacBook Pro 13-orlach (2016, dhá phort Thunderbolt 3) – Samhail: A1706
- MacBook Pro 13-orlach (2016, ceithre phort Thunderbolt 3) – Samhail: A1708
- MacBook Pro 15-orlach (2016) – Samhail: A1707

#### Fadhbanna Aitheanta

- Ní fheidhmíonn an Touch Bar
- Ní fheidhmíonn an fhuaim

#### Gléasanna le Slis T2

Tugadh Slis Slándála Apple T2 isteach in 2017. Scoireadh den tslis T2 leis an aistriú go Apple silicon (sliseanna sraith M) ag tosú in 2020.

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

Ar na samhlacha seo, bunaíonn an suiteálaí go huathoibríoch an eithne `linux-t2` paisteáilte, cumraíocht fuaime T2, firmware Broadcom Wi-Fi/Bluetooth Apple, agus rialú fean trí `t2fanrd`. Ritheann an Touch Bar ar thacaíocht ionsuite stíl Boot Camp an eithne.

#### iMac Retina 5K (2017)

Níl aon tslis T2 ag iMac 27-orlach 2017, mar sin bunaíonn an suiteálaí é mar a dhéanann sé leis na Macanna Intel eile.

- iMac (Retina 5K, 27-orlach, 2017) – Samhail: A1419

#### Fadhbanna Aitheanta

- Ní ritheann an taispeáint ag a 5120×2880 dúchasach: tá dhá thíl sa phainéal, agus ní lasann an tiománaí stoc ach ceann amháin
- Ní fheidhmíonn an fhuaim
- Níl aon éifeacht ag an rialú gile
- Cuireann codladh an meaisín ar stad; ní aisghabhann ach timthriall cumhachta é

Deisíonn paisteálaí pobail don tsamhail seo an taispeáint, an fhuaim agus an gile: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
