# Netkerfi

Netkerfi í Omarchy er í höndum NetworkManager, og þú stjórnar því frá nettákninu í [efstu stikunni](05-the-top-bar.md) eða með `Super + Ctrl + N`.

Það spjald skannar eftir Wi-Fi netum, sýnir merkjastyrk og tengist. Ethernet þarf alls ekkert — stinga því bara í samband og það virkar. Ef þú vilt frekar vera í skelinni gefur `nmtui` þér sömu stjórntæki, og það er líka til `omarchy network` skipanahópur.

## Að deila Wi-Fi netinu þínu

Í stað þess að lesa langt lykilorð upphátt skaltu keyra _Setup > Network > QR Code_ á meðan þú ert á Wi-Fi. Það setur QR-kóða á skjáinn sem hvaða myndavél síma sem er getur skannað til að tengjast. Þetta er eitt af því sem þú notar oftar en þú áttar þig á þegar þú veist að það er til staðar.

Ef þú þarft í raun lykilorðið sjálft prentar `omarchy network password <interface>` það.

## DNS

Omarchy notar það DNS sem netið þitt afhendir yfir DHCP. Þú getur hnekkt því fyrir alla vélina undir _Setup > Network > DNS_, þar sem Cloudflare og Google eru í eins smellis fjarlægð. Veldu _Custom_ til að slá inn eigin netþjóna.

Frá skelinni prentar `omarchy dns` núverandi veitu og `omarchy dns Cloudflare` stillir eina.

## Að festa Wi-Fi bandið

Ef beinirinn þinn setur 2.4GHz, 5GHz og 6GHz á sama nafn netsins mun fartölvan þín stundum halda fast í það hæga. `omarchy network band` sýnir hvaða bandi þú ert á, og `omarchy network band 5` festir það. Notaðu `auto` til að láta hana velja aftur.

Þetta festir bandið frekar en ákveðinn aðgangspunkt, svo þú heldur áfram að flakka á milli AP-a á venjulegan hátt.

## Hversu hratt er það?

_Trigger > Speed Test > Network Speed Test_ mælir raunverulegan hraða þinn upp og niður með tveimur skífum. Frá skelinni er það `omarchy network speedtest down` eða `up`. Það mælir gagnvart eigin þjónustu Omarchy og telur aðeins prófunarflutninga hennar. Önnur niðurhöl geta keppt um bandvídd, en þeim er ekki bætt við niðurstöðu hraðaprófsins. (Það er diskahraðapróf við hliðina á því í þeirri valmynd, ef þú ert að mæla hinn flöskuhálsinn.)

## Eldveggurinn

Eldveggurinn er kveiktur sjálfgefið og blokkar alla umferð inn, með einni undantekningu: port 53317, svo [LocalSend](22-guis.md) virki beint úr kassanum.

SSH er slökkt þangað til þú kveikir á því með _Setup > Security > SSHD_, sem ræsir þjóninn, opnar port 22 með hraðatakmörkun gegn þrjóskuárásum og heimilar lykil. Docker er líka læst niður, svo gáma geta ekki óvart afhjúpað sig fyrir heiminum. Sjá [öryggi](48-security.md) fyrir alla söguna.

## Tailscale

[Tailscale](https://tailscale.com/) er möskva-VPN sem gerir það einfalt og öruggt að ná til allra tölvanna þinna og netþjóna yfir internetið. Settu það upp með _Install > Service > Tailscale_.

Það gefur þér Tailscale spjald í stikunni, sem tengir við tailnet-ið og aftengir það, skiptir um reikninga og velur útgangsstað — bæði þínar eigin vélar og Mullvad svæði birtast á listanum. Það skoðar líka vélarnar þínar, og þar býr Taildrop: veldu vél og ýttu á `s` til að senda henni skrár, eða `c`, `n` og `d` til að afrita IP-töluna, nafnið eða fullt DNS-nafn hennar. Samsvörun í skelinni er `omarchy tailscale send <machine> [file...]`, og skrár sem þér eru sendar lenda sjálfkrafa í `~/Downloads`. Tilkynningin sem tilkynnir komu bíður þangað til þú smellir á hana til að opna eða hunsar hana, svo skrá sem birtist á meðan þú ert í burtu frá vélinni er enn þar til að svara þegar þú kemur til baka.

Uppsetning þess bætir líka við vefforriti fyrir Tailscale admin console.

## Þegar það hættir að virka

Áður en þú endurræsir skaltu reyna að endurræsa þann hluta sem veldur vandræðum einan og sér. _Update > Hardware_ hefur Wi-Fi, Bluetooth, Audio og Trackpad, og að endurhlaða einum þeirra leysir flest „þetta virkaði fyrir fimm mínútum" ástand. Sjá [úrræðaleit](45-troubleshooting.md).
