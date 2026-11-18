# Tacaíocht do Mac

Tá tacaíocht ionsuite in Omarchy do **Macanna Intel**. Tá cúpla teorainn aitheanta ann faoi láthair, ach fad is atá tú ar an eolas fúthu agus sásta leo; is féidir leat beatha nua a thabhairt do do shean-Mhacanna trí Omarchy a lódáil.

Tabhair faoi deara nach dtacaítear go díreach faoi láthair le suiteáil ar Mac sraith-M. Is féidir leat tuilleadh a fháil amach faoi staid seo in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY).

I dtástáil shimplí, bhíomar in ann gnóthachain feidhmíochta 36% a bhaint amach ar MacBook Pro ó 2019 díreach trí Omarchy a shuiteáil.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy a Shuiteáil ar Mac

Ní thacaíonn Omarchy faoi láthair ach le bheith mar an t-aon OS atá suiteáilte. Le linn na suiteála, scriosfar an tiomántán agus ní bheidh MacOS in ann tosú a thuilleadh.

Is féidir leat é a athchóiriú níos déanaí fós trí Internet Recovery más mian leat.

Chun críche na coda seo, glacfaimid leis go bhfuil [Tús a Chur Leis](02-getting-started.md) athbhreithnithe agat cheana agus go bhfuil do thiomántán USB réidh agat. Mura bhfuil, téigh ar aghaidh agus déan é sin anois.

#### Secure Boot a Dhíchumasú

Is gá Secure Boot Apple a dhíchumasú chun an USB intosaithe a thosú, chomh maith leis an OS. Chun é a dhíchumasú, déan an méid seo a leanas:

1. Múch do Mac
2. Cas air é agus brúigh agus coinnigh Command-R _láithreach_ go dtí go bhfeiceann tú an scáileán lódála ag teacht chun solais
3. Roghnaigh d'úsáideoir agus cuir isteach do phasfhocal má iarrtar ort
4. Nuair a bheidh tú ar an scáileán athshlánaithe, roghnaigh **Utilities > Startup Security Utility** ón mbarra roghchláir
5. Cuir isteach do phasfhocal nuair a iarrtar ort fíordheimhniú a dhéanamh
6. Roghnaigh "No Security" ó na roghanna Secure Boot
7. Roghnaigh "Allow booting from external or removable media" ó na roghanna External Boot

#### Tosaigh an tSuiteáil

1. Cuir isteach an tiomántán USB
2. Atosaigh do Mac agus brúigh agus coinnigh Option _láithreach_ go dtí go bhfeiceann tú scáileán de ghléasanna tosaithe
3. Roghnaigh an gléas oráiste EFI Boot
4. Lean ar aghaidh leis an [suiteáil mar is gnách](02-getting-started.md)

Aimsíonn an suiteálaí crua-earraí Mac agus cuireann sé na réitigh riachtanacha i bhfeidhm go huathoibríoch: tiománaithe agus dochtearraí Wi-Fi Broadcom, an tiománaí méarchláir SPI ar na samhlacha MacBook a dteastaíonn sé uathu, agus réiteach fionraí NVMe do na samhlacha céanna sin.

### Teorainneacha Aitheanta

Bíonn baill den phobal ag obair de shíor ar réitigh do na dúshláin seo agus mar sin má bhíonn fadhbanna agat leo seo, bí páirteach in #omarchy-on-other inár [Discord](https://discord.gg/tXFUdasqhY) agus féach an bhfuil aon mhodhanna cothrom le dáta ann chun iad seo a réiteach.

#### Gléasanna le Slis T1

Tugadh slis T1 Apple isteach go déanach in 2016 agus úsáideadh í go heisiach sna samhlacha MacBook Pro den chéad ghlúin le Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Samhail: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Samhail: A1708
- MacBook Pro 15-inch (2016) – Samhail: A1707

#### Fadhbanna Aitheanta

- Níl Touch Bar ag feidhmiú
- Níl an fhuaim ag feidhmiú

#### Gléasanna le Slis T2

Tugadh Slis Slándála T2 Apple isteach in 2017. Cuireadh deireadh leis an slis T2 leis an aistriú go Apple silicon (sliseanna sraith-M) ag tosú in 2020.

- iMac Pro (2017) – Samhail: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Samhail: A1989
- MacBook Pro 15-inch (2018) – Samhail: A1990
- MacBook Air (Retina, 13-inch, 2018) – Samhail: A1932
- Mac mini (2018) – Samhail: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Samhail: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Samhail: A2178
- MacBook Pro 15-inch (2019) – Samhail: A1990
- iMac (Retina 5K, 27-inch, 2020) – Samhail: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Samhail: A2265
- MacBook Pro 15-inch (2020) – Samhail: A1990

Ar na samhlacha seo, socraíonn an suiteálaí go huathoibríoch an eithne paisteáilte `linux-t2`, cumraíocht fuaime T2, dochtearraí Wi-Fi/Bluetooth Broadcom Apple, agus rialú fean trí `t2fanrd`. Ritheann an Touch Bar ar thacaíocht ionsuite ar stíl Boot Camp de chuid na heithne.

#### iMac Retina 5K (2017)

Níl slis T2 ag an iMac 27-orlach ó 2017, mar sin socraíonn an suiteálaí é mar na Macanna Intel eile.

- iMac (Retina 5K, 27-inch, 2017) – Samhail: A1419

#### Fadhbanna Aitheanta

- Ní ritheann an taispeáint ag a réiteach dúchais 5120×2880: is dhá thíl atá sa phainéal, agus ní lasann an tiománaí stoic ach ceann amháin
- Níl an fhuaim ag feidhmiú
- Níl aon éifeacht ag rialú na gile
- Cuireann codladh an meaisín i bhfostú; ní thagann sé chuige féin ach le timthriall cumhachta

Socraíonn paisteálaí pobail don tsamhail seo an taispeáint, an fhuaim agus an ghile: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
