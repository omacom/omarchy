# Líonrú

Bainistíonn NetworkManager an líonrú in Omarchy, agus tiomáineann tú é ón deilbhín líonra sa [barra barr](05-the-top-bar.md) nó le `Super + Ctrl + N`.

Scanann an painéal sin líonraí Wi-Fi, taispeánann sé neart an chomhartha, agus ceanglaíonn sé. Ní theastaíonn dada ar chor ar bith ó Ethernet — plugáil isteach é agus oibríonn sé. Más fearr leat fanacht sa teirminéal, tugann `nmtui` na rialuithe céanna duit, agus tá grúpa ordaithe `omarchy network` ann freisin.

## Do Wi-Fi a roinnt

In áit pasfhocal fada a léamh amach os ard, rith _Socrú > Líonra > Cód QR_ agus tú ar Wi-Fi. Cuireann sé sin cód QR ar an scáileán ar féidir le ceamara fóin ar bith é a scanadh chun dul isteach. Tá sé ar cheann de na rudaí sin a úsáidfidh tú níos mó ná mar a shílfeá nuair a bhíonn a fhios agat go bhfuil sé ann.

Más é an pasfhocal féin atá uait i ndáiríre, priontálann `omarchy network password <interface>` é.

## DNS

Úsáideann Omarchy cibé DNS a thugann do líonra amach thar DHCP. Is féidir leat é sin a shárú don mheaisín ar fad faoi _Socrú > Líonra > DNS_, áit a bhfuil Cloudflare agus Google cliceáil amháin ar shiúl. Roghnaigh _Saincheaptha_ chun do fhreastalaithe féin a chlóscríobh isteach.

Ón teirminéal, priontálann `omarchy dns` an soláthraí reatha agus socraíonn `omarchy dns Cloudflare` ceann.

## Banda Wi-Fi a phionnáil

Má chuireann do ródaire 2.4GHz, 5GHz, agus 6GHz ar an ainm líonra céanna, cloífidh do ríomhaire glúine leis an gceann mall uaireanta. Taispeánann `omarchy network band` cén banda ar a bhfuil tú, agus pionnálann `omarchy network band 5` é. Úsáid `auto` chun ligean dó roghnú arís.

Pionnálann sé seo an banda seachas pointe rochtana ar leith, mar sin leanann tú ag fánaíocht idir APs mar is gnách.

## Cé chomh tapa is atá sé?

Tomhaiseann _Truicear > Tástáil Luais > Tástáil Luais Líonra_ do luas iarbhír suas agus síos le péire diaileanna. Ón teirminéal is é `omarchy network speedtest down` nó `up` é. (Tá tástáil luais diosca ina suí in aice leis sa roghchlár sin, má tá tú ag tagarmharcáil an bhacainn eile.)

## An balla dóiteáin

Tá an balla dóiteáin ar siúl de réir réamhshocraithe agus cuireann sé bac ar gach trácht isteach, le heisceacht amháin: port 53317, ionas go n-oibríonn [LocalSend](22-guis.md) díreach as an mbosca.

Tá SSH múchta go dtí go gcuireann tú ar siúl é le _Socrú > Slándáil > SSHD_, a thosaíonn an deamhan, a osclaíonn port 22 ar ráta teoranta in aghaidh ionsaithe brúidiúla, agus a údaraíonn eochair. Tá Docker glasáilte síos freisin, ionas nach féidir le coimeádáin iad féin a nochtadh don domhan de thaisme. Féach [slándáil](48-security.md) don scéal ar fad.

## Tailscale

Is VPN mogalra é [Tailscale](https://tailscale.com/) a fhágann go bhfuil sé simplí agus slán do ríomhairí agus do fhreastalaithe go léir a bhaint amach thar an idirlíon. Suiteáil é le _Suiteáil > Seirbhís > Tailscale_.

Tugann sé sin painéal Tailscale duit sa bharra, a cheanglaíonn agus a dhícheanglaíonn an tailnet, a aistríonn cuntais, agus a roghnaíonn nód imeachta — taispeántar do mheaisíní féin agus réigiúin Mullvad araon sa liosta. Brabhsálann sé do mheaisíní freisin, agus is ann atá Taildrop: roghnaigh meaisín agus brúigh `s` chun comhaid a sheoladh chuige, nó `c`, `n`, agus `d` chun a IP, a ainm, nó a ainm iomlán DNS a chóipeáil. Is é an choibhéis teirminéil ná `omarchy tailscale send <machine> [file...]`, agus tuirlingíonn comhaid a sheoltar chugat i `~/Downloads` go huathoibríoch. Fanann an fógra a fhógraíonn teacht go dtí go gcliceálann tú oscailte é nó go ndíbheann tú é, mar sin bíonn comhad a thagann agus tú ar shiúl ón meaisín fós ann le freagairt nuair a thagann tú ar ais.

Cuireann a shuiteáil feidhmchlár gréasáin leis freisin do chonsól riaracháin Tailscale.

## Nuair a stopann sé ag obair

Sula n-atosaíonn tú, bain triail as an bpíosa ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Fuaim, agus Trackpad ag _Nuashonrú > Crua-earraí_, agus glanann athlódáil ceann díobh sin an chuid is mó de chásanna "d'oibrigh sé cúig nóiméad ó shin". Féach [fabhtcheartú](45-troubleshooting.md).
