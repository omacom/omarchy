# Líonrú

Is é NetworkManager a láimhseálann an líonrú in Omarchy, agus tiomáineann tú é ón deilbhín líonra sa [barra uachtarach](05-the-top-bar.md) nó le `Super + Ctrl + N`.

Scanann an painéal sin líonraí Wi-Fi, taispeánann sé neart an chomhartha, agus ceanglaíonn sé. Ní theastaíonn dada ar chor ar bith ó Ethernet — plocáil isteach é agus oibríonn sé. Más fearr leat fanacht sa teirminéal, tugann `nmtui` na rialuithe céanna duit, agus tá grúpa ordaithe `omarchy network` ann freisin.

## Ag roinnt do Wi-Fi

In ionad pasfhocal fada a léamh amach os ard, rith _Setup > Network > QR Code_ agus tú ar Wi-Fi. Cuireann sin cód QR ar an scáileán ar féidir le ceamara fóin ar bith é a scanadh chun dul isteach. Is ceann de na rudaí sin é a úsáidfidh tú níos minice ná mar a shílfeá a luaithe a bhíonn a fhios agat go bhfuil sé ann.

Más é an pasfhocal féin a theastaíonn uait i ndáiríre, priontálann `omarchy network password <interface>` é.

## DNS

Úsáideann Omarchy cibé DNS a thugann do líonra dó thar DHCP. Is féidir leat é sin a shárú don mheaisín ar fad faoi _Setup > Network > DNS_, áit a bhfuil Cloudflare agus Google cliceáil amháin ar shiúl. Roghnaigh _Custom_ chun do fhreastalaithe féin a chlóscríobh isteach.

Ón teirminéal, priontálann `omarchy dns` an soláthraí reatha agus socraíonn `omarchy dns Cloudflare` ceann.

## An banda Wi-Fi a phionnáil

Má chuireann do ródaire 2.4GHz, 5GHz, agus 6GHz ar an ainm líonra céanna, cloífidh do ríomhaire glúine leis an gceann mall uaireanta. Taispeánann `omarchy network band` cén banda ar a bhfuil tú, agus pionnálann `omarchy network band 5` é. Úsáid `auto` chun ligean dó roghnú arís.

Pionnálann sé seo an banda seachas pointe rochtana ar leith, mar sin leanann tú ag fánaíocht idir APanna mar is gnách.

## Cé chomh tapa is atá sé?

Tomhaiseann _Trigger > Speed Test > Network Speed Test_ do luas iarbhír suas agus síos le péire dhiaileanna. Ón teirminéal is é `omarchy network speedtest down` nó `up` é. Tomhaiseann sé i gcoinne sheirbhís Omarchy féin agus ní áiríonn sé ach a aistrithe tástála. Is féidir le híoslódálacha eile bheith in iomaíocht don bhandaleithead, ach ní chuirtear iad leis an toradh luasthástála. (Tá luasthástáil diosca ina suí in aice leis sa roghchlár sin, más é an bac eile atá á thagarmharcáil agat.)

## An balla dóiteáin

Bíonn an balla dóiteáin ar siúl de réir réamhshocraithe agus blocálann sé gach trácht isteach, le heisceacht amháin: port 53317, ionas go n-oibríonn [LocalSend](22-guis.md) díreach as an mbosca.

Bíonn SSH múchta go dtí go gcuireann tú ar siúl é le _Setup > Security > SSHD_, a thosaíonn an deamhan, a osclaíonn port 22 le teorannú ráta i gcoinne brute force, agus a údaraíonn eochair. Tá Docker faoi ghlas freisin, ionas nach féidir le coimeádáin iad féin a nochtadh don domhan de thaisme. Féach [slándáil](48-security.md) don scéal iomlán.

## Tailscale

Is VPN mogalra é [Tailscale](https://tailscale.com/) a fhágann go bhfuil sé simplí agus slán do ríomhairí agus do fhreastalaithe ar fad a bhaint amach thar an idirlíon. Suiteáil é le _Install > Service > Tailscale_.

Tugann sin painéal Tailscale duit sa bharra, a cheanglaíonn agus a dhícheanglaíonn an tailnet, a mhalartaíonn cuntais, agus a roghnaíonn nód fágála — tagann do mheaisíní féin agus réigiúin Mullvad araon aníos sa liosta. Brabhsálann sé do mheaisíní freisin, agus is ansin atá Taildrop: roghnaigh meaisín agus brúigh `s` chun comhaid a sheoladh chuige, nó `c`, `n`, agus `d` chun a IP, a ainm, nó a ainm DNS iomlán a chóipeáil. Is é an comhionann teirminéil ná `omarchy tailscale send <machine> [file...]`, agus tuirlingíonn comhaid a sheoltar chugat in `~/Downloads` go huathoibríoch. Fanann an fógra a fhógraíonn teacht go dtí go gcliceálann tú oscailte é nó go ndíbheann tú é, mar sin tá comhad a thagann aníos agus tú ar shiúl ón meaisín fós ann le freagairt nuair a fhilleann tú.

Cuireann a shuiteáil feidhmchlár gréasáin don chonsól riaracháin Tailscale leis freisin.

## Nuair a stopann sé ag obair

Sula n-atosaíonn tú, bain triail as an bpíosa ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Audio, agus Trackpad ag _Update > Hardware_, agus réitíonn atosaíocht ceann acu sin formhór na gcásanna “d'oibrigh sé cúig nóiméad ó shin”. Féach [fabhtcheartú](45-troubleshooting.md).
