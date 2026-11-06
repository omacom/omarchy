# Mtandao

Mtandao katika Omarchy unashughulikiwa na NetworkManager, na unaudhibiti kutoka kwenye aikoni ya mtandao iliyo kwenye [upau wa juu](05-the-top-bar.md) au kwa kutumia `Super + Ctrl + N`.

Paneli hiyo hutafuta mitandao ya Wi-Fi, huonyesha nguvu ya mawimbi, na huunganisha. Ethernet haihitaji chochote kabisa — ichomeke tu na inafanya kazi. Ikiwa unapendelea kubaki kwenye terminal, `nmtui` inakupa vidhibiti hivyo hivyo, na pia kuna kikundi cha amri cha `omarchy network`.

## Kushiriki Wi-Fi yako

Badala ya kusoma nenosiri refu kwa sauti kubwa, endesha _Setup > Network > QR Code_ ukiwa umeunganishwa kwenye Wi-Fi. Hiyo huweka msimbo wa QR kwenye skrini ambao kamera yoyote ya simu inaweza kuuskani ili kujiunga. Ni mojawapo ya vitu ambavyo utavitumia mara nyingi zaidi kuliko unavyotarajia baada ya kujua kuwa vipo.

Ikiwa unahitaji nenosiri lenyewe hasa, `omarchy network password <interface>` hulichapisha.

## DNS

Omarchy hutumia DNS yoyote ambayo mtandao wako unaitoa kupitia DHCP. Unaweza kubatilisha hiyo kwa mashine nzima chini ya _Setup > Network > DNS_, ambapo Cloudflare na Google ziko umbali wa mbofyo mmoja tu. Chagua _Custom_ ili kuandika seva zako mwenyewe.

Kutoka kwenye terminal, `omarchy dns` huchapisha mtoa huduma wa sasa na `omarchy dns Cloudflare` huweka mmoja.

## Kupini bendi ya Wi-Fi

Ikiwa kipanga njia chako kinaweka 2.4GHz, 5GHz, na 6GHz kwenye jina moja la mtandao, laptop yako wakati mwingine itang'ang'ania ile yenye kasi ndogo. `omarchy network band` huonyesha uko kwenye bendi gani, na `omarchy network band 5` huipini. Tumia `auto` kuiruhusu ichague tena.

Hii hupini bendi badala ya sehemu maalum ya kufikia mtandao, kwa hivyo unaendelea kuzurura kati ya APs kama kawaida.

## Ina kasi kiasi gani?

_Trigger > Speed Test > Network Speed Test_ hupima kasi yako halisi ya kupakia juu na kupakua kwa kutumia jozi ya diali. Kutoka kwenye terminal ni `omarchy network speedtest down` au `up`. Hupima dhidi ya huduma ya Omarchy yenyewe na huhesabu tu uhamishaji wake wa majaribio. Upakuaji mwingine unaweza kushindania kipimo data, lakini hauongezwi kwenye matokeo ya jaribio la kasi. (Kuna jaribio la kasi ya diski lililo karibu nayo kwenye menyu hiyo, ikiwa unapima kizuizi kingine.)

## Ngome

Ngome imewashwa kwa chaguo-msingi na huzuia trafiki yote inayoingia, isipokuwa moja tu: mlango 53317, ili [LocalSend](22-guis.md) ifanye kazi mara moja bila usanidi wa ziada.

SSH imezimwa hadi utakapo iwasha kwa kutumia _Setup > Security > SSHD_, ambayo huwasha daemon, hufungua mlango 22 kwa kiwango kilichopunguzwa dhidi ya mashambulizi ya kubahatisha, na huidhinisha ufunguo. Docker pia imefungwa, ili kontena zisiweze kujianika kwa ulimwengu kwa bahati mbaya. Tazama [usalama](48-security.md) kwa hadithi nzima.

## Tailscale

[Tailscale](https://tailscale.com/) ni VPN ya mesh inayorahisisha na kuimarisha usalama wa kufikia kompyuta na seva zako zote kupitia intaneti. Isakinishe kwa kutumia _Install > Service > Tailscale_.

Hiyo inakupa paneli ya Tailscale kwenye upau, ambayo huunganisha na kutenganisha tailnet, hubadilisha akaunti, na huchagua nodi ya kutoka — mashine zako mwenyewe na maeneo ya Mullvad yote huonekana kwenye orodha. Pia huvinjari mashine zako, na hapo ndipo Taildrop inapopatikana: chagua mashine na ubonyeze `s` kuitumia faili, au `c`, `n`, na `d` kunakili IP yake, jina lake, au jina lake kamili la DNS. Sawa yake kwenye terminal ni `omarchy tailscale send <machine> [file...]`, na faili zinazotumwa kwako hutua kwenye `~/Downloads` kiotomatiki. Arifa inayotangaza kuwasili husubiri hadi utakapoibofya kuifungua au kuiondoa, kwa hivyo faili inayofika ukiwa mbali na mashine bado ipo ya kujibiwa unaporudi.

Kuisakinisha pia huongeza programu ya wavuti kwa ajili ya dashibodi ya usimamizi ya Tailscale.

## Inapoacha kufanya kazi

Kabla ya kuwasha upya, jaribu kuwasha upya kipande kinachosumbua peke yake. _Update > Hardware_ ina Wi-Fi, Bluetooth, Audio, na Trackpad, na kupakia upya mojawapo ya hizo huondoa matatizo mengi ya "ilifanya kazi dakika tano zilizopita". Tazama [utatuzi wa matatizo](45-troubleshooting.md).
