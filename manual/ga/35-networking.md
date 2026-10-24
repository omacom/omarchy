# Líonrú

Is é NetworkManager a láimhseálann an líonrú in Omarchy, agus tiomáineann tú é ón deilbhín líonra sa [bharra barr](05-the-top-bar.md) nó le `Super + Ctrl + W`.

Scanann an painéal sin do líonraí Wi-Fi, taispeánann sé neart an chomhartha, agus nasctar é. Ní theastaíonn aon rud ar chor ar bith ó Ethernet — plugáil isteach é agus oibreoidh sé. Más fearr leat fanacht sa teirminéal, tugann `nmtui` na rialuithe céanna duit, agus tá grúpa orduithe `omarchy network` ann freisin.

## Do Wi-Fi a roinnt

In áit pasfhocal fada a léamh os ard, rith _Socrú > Líonra > Cód QR_ agus tú ar Wi-Fi. Cuirfidh sé sin cód QR ar an scáileán ar féidir le ceamara fóin ar bith é a scanadh chun dul isteach. Tá sé ar cheann de na rudaí sin a úsáidfidh tú níos mó ná mar a shílfeá nuair a thuigeann tú go bhfuil sé ann.

Má theastaíonn an pasfhocal féin uait i ndáiríre, priontálann `omarchy network password <interface>` é.

## DNS

Úsáideann Omarchy cibé DNS a thugann do líonra amach thar DHCP. Is féidir leat é sin a shárú don mheaisín ar fad faoi _Socrú > Líonra > DNS_, áit a bhfuil Cloudflare agus Google cliceáil amháin ar shiúl. Roghnaigh _Saincheaptha_ chun do fhreastalaithe féin a chlóscríobh isteach.

Ón teirminéal, priontálann `omarchy dns` an soláthróir reatha agus socraíonn `omarchy dns Cloudflare` ceann.

## Banda an Wi-Fi a phinnáil

Má chuireann do ródaire 2.4GHz, 5GHz, agus 6GHz ar an ainm líonra céanna, cloífidh do ríomhaire glúine leis an gceann mall uaireanta. Taispeánann `omarchy network band` cén banda a bhfuil tú air, agus pinníonn `omarchy network band 5` é. Úsáid `auto` chun ligean dó roghnú arís.

Pinníonn sé seo an banda seachas pointe rochtana ar leith, mar sin leanann tú ag fánaíocht idir pointí rochtana mar is gnách.

## Cé chomh tapa is atá sé?

Tomhaiseann _Spreag > Tástáil luais > Tástáil luais líonra_ do luas iarbhír suas agus síos le péire dhiaileanna. Ón teirminéal is é `omarchy network speedtest down` nó `up` é. (Tá tástáil luais diosca ina suí in aice leis sa roghchlár sin, má tá tú ag tagarmharcáil an scrogaill eile.)

## An balla dóiteáin

Tá an balla dóiteáin ar siúl de réir réamhshocraithe agus blocálann sé an trácht isteach go léir, le heisceacht amháin: port 53317, ionas go n-oibríonn [LocalSend](22-guis.md) díreach as an mbosca.

Tá SSH múchta go dtí go gcuireann tú air é le _Socrú > Security > SSHD_, a thosaíonn an deamhan, a osclaíonn port 22 le ráta teoranta in aghaidh brute force, agus a údaraíonn eochair. Tá Docker faoi ghlas freisin, mar sin ní féidir le coimeádáin iad féin a nochtadh don domhan trí thimpiste. Féach [slándáil](48-security.md) don scéal iomlán.

## Tailscale

Is VPN mogalra é [Tailscale](https://tailscale.com/) a dhéanann sé simplí agus slán do ríomhairí agus freastalaithe go léir a bhaint amach thar an idirlíon. Suiteáil é le _Suiteáil > Service > Tailscale_.

Tabharfaidh sé sin painéal Tailscale duit sa bharra, a nascann agus a dhínasctar an tailnet, a athraíonn cuntais, agus a roghnaíonn nód fágála — taispeántar do mheaisíní féin agus réigiúin Mullvad araon sa liosta. Brabhsálann sé do mheaisíní freisin, agus is ann a chónaíonn Taildrop: roghnaigh meaisín agus brúigh `s` chun comhaid a sheoladh chuige, nó `c`, `n`, agus `d` chun a IP, a ainm, nó a ainm DNS iomlán a chóipeáil. Is é an choibhéis teirminéil `omarchy tailscale send <machine> [file...]`, agus tuirlingíonn comhaid a sheoltar chugat i `~/Downloads` go huathoibríoch. Fanann an fógra a fhógraíonn teacht go dtí go gcliceálann tú oscailte nó go ndiúltaíonn tú é, mar sin tá comhad a thagann agus tú ar shiúl ón meaisín fós ann le freagairt nuair a fhilleann tú.

Cuireann é a shuiteáil feidhmchlár gréasáin leis freisin don chonsól riaracháin Tailscale.

## Nuair a stopann sé ag obair

Sula n-atosaíonn tú, bain triail as an bpíosa ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Audio, agus Trackpad ag _Nuashonraigh > Hardware_, agus réitíonn ceann díobh sin a athluchtú an chuid is mó de chásanna "d'oibrigh sé cúig nóiméad ó shin". Féach [fabhtcheartú](45-troubleshooting.md).
