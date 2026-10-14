# Net

NetworkManager sér um netið í Omarchy og þú stýrir því með nettákninu á [valmyndastikunni](05-the-top-bar.md) eða með `Super + Ctrl + W`.

Spjaldið leitar að Wi-Fi netum, sýnir merkisstyrk og tengist. Ethernet þarf ekkert — stingdu því í samband og það virkar. Ef þú vilt heldur vera áfram í terminal gefur `nmtui` þér sömu stýringar, og það er líka til `omarchy network` skipanahópur.

## Að deila Wi-Fi netinu þínu

Í stað þess að lesa langt lykilorð upphátt skaltu keyra _Uppsetning > Net > QR-kóði_ á meðan þú ert á Wi-Fi. Það setur QR-kóða á skjáinn sem sérhver símamyndavél getur skannað til að tengjast. Þetta er eitt af því sem þú munt nota oftar en þig órar fyrir þegar þú veist af því.

Ef þú þarft lykilorðið sjálft prentar `omarchy network password <interface>` það út.

## DNS

Omarchy notar það DNS sem netið þitt afhendir um DHCP. Þú getur farið fram hjá því fyrir alla vélina undir _Uppsetning > Net > DNS_, þar sem Cloudflare og Google eru í einum smelli. Veldu _Sérsniðið_ til að slá inn þína eigin þjóna.

Úr terminal prentar `omarchy dns` núverandi veitu og `omarchy dns Cloudflare` stillir eina.

## Að festa Wi-Fi tíðnisviðið

Ef beinirinn þinn setur 2.4GHz, 5GHz og 6GHz undir sama netnafnið mun fartölvan þín stundum hanga á hæga sviðinu. `omarchy network band` sýnir á hvaða sviði þú ert og `omarchy network band 5` festir það. Notaðu `auto` til að láta það velja aftur.

Þetta festir tíðnisviðið frekar en ákveðinn aðgangspunkt, svo þú heldur áfram að vafra eðlilega á milli aðgangspunkta.

## Hversu hratt er það?

_Kveikja > Hraðapróf > Nethraðapróf_ mælir raunverulegan upp- og niðurhraða þinn með tveimur vísiskífum. Úr terminal er það `omarchy network speedtest down` eða `up`. (Það er diskahraðapróf við hlið þess í þeirri valmynd, ef þú ert að mæla hinn flöskuhálsinn.)

## Eldveggurinn

Eldveggurinn er sjálfgefið á og lokar allri umferð inn, með einni undantekningu: tengi 53317, svo [LocalSend](22-guis.md) virki strax úr kassanum.

SSH er slökkt þar til þú kveikir á því með _Uppsetning > Öryggi > SSHD_, sem ræsir þjónustuna, opnar tengi 22 með hraðatakmörkun gegn brute force árásum og heimilar lykil. Docker er líka læst, svo gámar geti ekki óviljandi opnað sig fyrir heiminum. Sjá [öryggi](48-security.md) fyrir alla söguna.

## Tailscale

[Tailscale](https://tailscale.com/) er mesh VPN sem gerir það einfalt og öruggt að ná til allra tölva þinna og þjóna yfir internetið. Settu það upp með _Setja upp > Þjónusta > Tailscale_.

Það gefur þér Tailscale-spjald á stikunni, sem tengir og aftengir tailnetið, skiptir um reikninga og velur útgönguhnúða — bæði þínar eigin vélar og Mullvad-svæði birtast á listanum. Það vafrar líka um vélarnar þínar, og þar býr Taildrop: veldu vél og ýttu á `s` til að senda henni skrár, eða `c`, `n` og `d` til að afrita IP-tölu hennar, nafn eða fullt DNS-nafn. Samsvarandi í terminal er `omarchy tailscale send <machine> [file...]` og skrár sem sendar eru til þín lenda sjálfkrafa í `~/Downloads`. Tilkynningin um komu bíður þar til þú smellir henni opinni eða vísar henni frá, svo skrá sem berst á meðan þú ert fjarri vélinni er enn til staðar til að svara þegar þú kemur til baka.

Uppsetningin bætir líka við vefforriti fyrir Tailscale-stjórnborðið.

## Þegar það hættir að virka

Áður en þú endurræsir skaltu prófa að endurræsa sökudólginn einan. _Uppfæra > Vélbúnaður_ er með Wi-Fi, Bluetooth, hljóð og snertiflötu, og að endurhlaða einum þeirra hreinsar flestar „það virkaði fyrir fimm mínútum“ aðstæður. Sjá [úrræðaleit](45-troubleshooting.md).
