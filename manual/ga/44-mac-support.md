# Tacaíocht Mac

Tá tacaíocht ionsuite ag Omarchy do **Intel Macs**. Tá cúpla teorainn aitheanta ann faoi láthair, ach fad is atá tú ar an eolas agus sásta leo sin; is féidir leat saol nua a thabhairt isteach i do shean-Mhacs trí Omarchy a lódáil.

Tabhair faoi deara le do thoil nach dtacaítear go díreach le suiteáil ar Mac den tsraith M faoi láthair. Is féidir leat tuilleadh a fháil amach faoi staid seo in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY).

I dtástáil shimplí, bhíomar in ann gnóthachain feidhmíochta 36% a bhaint amach ar MacBook Pro 2019 díreach trí Omarchy a shuiteáil.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy a shuiteáil ar Mac

Ní thacaíonn Omarchy ach le bheith mar an t-aon OS suiteáilte faoi láthair. Le linn na suiteála, glanfar an tiomáint agus ní bheidh MacOS intosaithe a thuilleadh.

Is féidir leat é a chur ar ais fós níos déanaí trí Internet Recovery más mian leat.

Ar mhaithe leis an gcuid seo, glacfaimid leis go bhfuil athbhreithniú déanta agat cheana ar [Getting Started](02-getting-started.md) agus go bhfuil do thiomáint USB réidh agat. Mura bhfuil, téigh ar aghaidh agus déan é sin anois.

#### Secure Boot a dhíchumasú

Is gá Secure Boot Apple a dhíchumasú chun an USB intosaithe a thosú, chomh maith leis an OS. Chun é a dhíchumasú, déan na rudaí seo a leanas:

1. Múch do Mac
2. Cas air é agus brúigh agus coinnigh Command-R _láithreach_ go dtí go bhfeiceann tú an scáileán lódála le feiceáil
3. Roghnaigh d'úsáideoir agus cuir isteach do phasfhocal má iarrtar ort
4. A luaithe a bhíonn tú sa scáileán aisghabhála, roghnaigh **Utilities > Startup Security Utility** ón mbarra roghchláir
5. Cuir isteach do phasfhocal nuair a iarrtar ort fíordheimhniú a dhéanamh
6. Roghnaigh "No Security" ó na roghanna Secure Boot
7. Roghnaigh "Allow booting from external or removable media" ó na roghanna External Boot

#### Tosaigh an tSuiteáil

1. Cuir isteach an tiomáint USB
2. Atosaigh do Mac agus brúigh agus coinnigh Option _láithreach_ go dtí go bhfeiceann tú scáileán de ghléasanna tosaithe
3. Roghnaigh an gléas oráiste EFI Boot
4. Lean ar aghaidh leis an [suiteáil mar is gnách](02-getting-started.md)

Aimsíonn an suiteálaí crua-earraí Mac agus cuireann sé na socruithe is gá i bhfeidhm go huathoibríoch: tiománaithe agus dochteanna Wi-Fi Broadcom, an tiománaí méarchláir SPI ar na samhlacha MacBook a bhfuil sé ag teastáil uathu, agus socrú fionraí NVMe do na samhlacha céanna sin.

### Teorainneacha Aitheanta

Tá baill den phobal ag obair i gcónaí ar réitigh do na dúshláin seo mar sin má tá siad seo ina bhfadhb duitse, bí páirteach in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY) agus feic an bhfuil modhanna cothrom le dáta ar bith ann chun iad seo a réiteach.

#### Gléasanna le Sceall T1

Tugadh isteach an sceall Apple T1 go déanach in 2016 agus úsáideadh go heisiach é sna samhlacha MacBook Pro den chéad ghlúin le Touch Bar.
- MacBook Pro 13-orlach (2016, dhá phort Thunderbolt 3) – Samhail: A1706
- MacBook Pro 13-orlach (2016, ceithre phort Thunderbolt 3) – Samhail: A1708
- MacBook Pro 15-orlach (2016) – Samhail: A1707

#### Saincheisteanna Aitheanta

- Níl an Touch Bar feidhmiúil
- Níl an fhuaim ag feidhmiú

#### Gléasanna le Sceall T2

Tugadh isteach an Sceall Slándála Apple T2 in 2017. Scoireadh an sceall T2 leis an aistriú go Apple silicon (sceallóga den tsraith M) ag tosú in 2020.

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

Ar na samhlacha seo, socraíonn an suiteálaí go huathoibríoch an eithne phaisteáilte `linux-t2`, cumraíocht fuaime T2, dochteanna Wi-Fi/Bluetooth Broadcom Apple, agus rialú fean trí `t2fanrd`. Ritheadh an Touch Bar ar thacaíocht ionsuite stíl Boot Camp na heithne.
