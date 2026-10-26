# Netkerfi

Netkerfi í Omarchy er stýrt af NetworkManager og þú stjórnar því frá netkerfistákninu í [efri stikunni](05-the-top-bar.md) eða með `Super + Ctrl + N`.

Sá gluggi leitar að Wi-Fi netum, sýnir merkjastyrk og tengist. Ethernet þarf ekkert — stingdu því í samband og það virkar. Ef þú vilt frekar vera í skelinni gefur `nmtui` þér sömu stjórntæki og það er líka til `omarchy network` skipanaflokkur.

## Að deila Wi-Fi netinu þínu

Í stað þess að lesa langt lykilorð upphátt skaltu keyra _Setup > Network > QR Code_ á meðan þú ert á Wi-Fi. Það setur QR kóða á skjáinn sem hvaða síma myndavél sem er getur skannað til að tengjast. Þetta er eitt af því sem þú munt nota oftar en þú heldur þegar þú veist að það er þarna.

Ef þú þarft í raun lykilorðið sjálft prentar `omarchy network password <interface>` það út.

## DNS

Omarchy notar það DNS sem netið þitt afhendir yfir DHCP. Þú getur hnekkt því fyrir alla vélina undir _Setup > Network > DNS_, þar sem Cloudflare og Google eru í eins smellis fjarlægð. Veldu _Custom_ til að slá inn þína eigin netþjóna.

Úr skelinni prentar `omarchy dns` núverandi veitu og `omarchy dns Cloudflare` stillir eina.

## Að festa Wi-Fi bandið

Ef beinirinn þinn setur 2.4GHz, 5GHz og 6GHz undir sama netheiti mun tölvan þín stundum hanga á því hæga. `omarchy network band` sýnir hvaða bandi þú ert á og `omarchy network band 5` festir það. Notaðu `auto` til að láta það velja aftur.

Þetta festir bandið frekar en sérstakan aðgangspunkt, svo þú heldur áfram að reika á milli APs eins og venjulega.

## Hversu hratt er það?

_Trigger > Speed Test > Network Speed Test_ mælir raunverulegan hraða þinn upp og niður með pari af mælum. Úr skelinni er það `omarchy network speedtest down` eða `up`. (Það er diskahraðapróf við hliðina á því í þeirri valmynd, ef þú ert að mæla hinn flöskuhálsinn.)

## Eldveggurinn

Eldveggurinn er á sjálfgefið og blokkar alla umferð inn, með einni undantekningu: gátt 53317, svo [LocalSend](22-guis.md) virki beint úr kassanum.

SSH er slökkt þar til þú kveikir á því með _Setup > Security > SSHD_, sem ræsir þjóninn, opnar gátt 22 með hraðatakmörkun gegn brute force og heimilar lykil. Docker er líka læst niður, svo gáma geta ekki óvart opnað sig fyrir heiminum. Sjá [öryggi](48-security.md) fyrir alla söguna.

## Tailscale

[Tailscale](https://tailscale.com/) er mesh VPN sem gerir það einfalt og öruggt að ná til allra tölvanna þinna og netþjóna yfir internetið. Settu það upp með _Install > Service > Tailscale_.

Það gefur þér Tailscale glugga í stikunni, sem tengir og aftengir tailnet, skiptir um reikninga og velur exit node — bæði þínar eigin vélar og Mullvad svæði birtast í listanum. Það skoðar líka vélarnar þínar og þar býr Taildrop: veldu vél og ýttu á `s` til að senda henni skrár, eða `c`, `n` og `d` til að afrita IP tölu hennar, nafn eða fullt DNS heiti. Samsvarandi í skelinni er `omarchy tailscale send <machine> [file...]` og skrár sem þér eru sendar lenda sjálfkrafa í `~/Downloads`. Tilkynningin sem segir til um komu bíður þar til þú smellir á hana til að opna eða vísar henni frá, svo skrá sem birtist á meðan þú ert fjarri vélinni er enn til staðar til að svara þegar þú kemur aftur.

Uppsetningin bætir líka við vefforriti fyrir Tailscale stjórnborðið.

## Þegar það hættir að virka

Áður en þú endurræsir skaltu reyna að endurræsa viðkomandi hlut einan sér. _Update > Hardware_ er með Wi-Fi, Bluetooth, Audio og Trackpad og að endurhlaða einum af þeim leysir flestar "þetta virkaði fyrir fimm mínútum" aðstæður. Sjá [úrræðaleit](45-troubleshooting.md).
