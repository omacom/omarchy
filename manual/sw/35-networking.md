# Mitandao

Mitandao katika Omarchy inashughulikiwa na NetworkManager, na unaidhibiti kutoka kwenye aikoni ya mtandao iliyo kwenye [upau wa juu](05-the-top-bar.md) au kwa `Super + Ctrl + N`.

Paneli hiyo hutafuta mitandao ya Wi-Fi, huonyesha nguvu ya mawimbi, na huunganisha. Ethernet haihitaji chochote kabisa — ichomeke tu na inafanya kazi. Ikiwa unapendelea kubaki kwenye terminal, `nmtui` inakupa vidhibiti hivyo hivyo, na pia kuna kikundi cha amri cha `omarchy network`.

## Kushiriki Wi-Fi yako

Badala ya kusoma nenosiri refu kwa sauti, endesha _Setup > Network > QR Code_ ukiwa kwenye Wi-Fi. Hiyo huweka msimbo wa QR kwenye skrini ambao kamera yoyote ya simu inaweza kuuchanganua ili kujiunga. Ni mojawapo ya vitu utakavyotumia zaidi ya unavyotarajia mara tu unapojua kipo.

Ikiwa unahitaji nenosiri lenyewe, `omarchy network password <interface>` hulichapisha.

## DNS

Omarchy hutumia DNS yoyote ambayo mtandao wako hutoa kupitia DHCP. Unaweza kubatilisha hilo kwa mashine nzima chini ya _Setup > Network > DNS_, ambapo Cloudflare na Google ziko umbali wa kubofya mara moja. Chagua _Custom_ kuandika seva zako mwenyewe.

Kutoka kwenye terminal, `omarchy dns` huchapisha mtoa huduma wa sasa na `omarchy dns Cloudflare` huweka mmoja.

## Kubandika bendi ya Wi-Fi

Ikiwa kipanga njia chako kinaweka 2.4GHz, 5GHz, na 6GHz kwenye jina moja la mtandao, laptop yako wakati mwingine itang'ang'ania ile ya polepole. `omarchy network band` huonyesha uko kwenye bendi gani, na `omarchy network band 5` huibandika. Tumia `auto` kuiruhusu ichague tena.

Hii hubandika bendi badala ya kituo maalum cha ufikiaji, kwa hivyo unaendelea kuzurura kati ya APs kama kawaida.

## Ina kasi kiasi gani?

_Trigger > Speed Test > Network Speed Test_ hupima kasi yako halisi ya kupakia na kupakua kwa kutumia jozi ya vielelezo. Kutoka kwenye terminal ni `omarchy network speedtest down` au `up`. (Kuna jaribio la kasi ya diski lililo karibu nayo kwenye menyu hiyo, ikiwa unapima kizuizi kingine.)

## Ngome

Ngome imewashwa kwa chaguo-msingi na huzuia trafiki yote inayoingia, isipokuwa moja: mlango 53317, ili [LocalSend](22-guis.md) ifanye kazi mara moja bila usanidi wa ziada.

SSH imezimwa hadi utakapo iwasha kwa _Setup > Security > SSHD_, ambayo huanzisha daemon, hufungua mlango 22 uliowekewa kikomo cha kiwango dhidi ya mashambulizi ya brute force, na kuidhinisha ufunguo. Docker pia imefungwa, kwa hivyo kontena haziwezi kujifichua kwa bahati mbaya kwa ulimwengu. Tazama [usalama](48-security.md) kwa hadithi kamili.

## Tailscale

[Tailscale](https://tailscale.com/) ni VPN ya mesh inayofanya kufikia kompyuta na seva zako zote kupitia intaneti kuwa rahisi na salama. Isakinishe kwa _Install > Service > Tailscale_.

Hiyo inakupa paneli ya Tailscale kwenye upau, ambayo huunganisha na kutenganisha tailnet, hubadilisha akaunti, na huchagua exit node — mashine zako mwenyewe na maeneo ya Mullvad yote huonekana kwenye orodha. Pia huvinjari mashine zako, na hapo ndipo Taildrop inapopatikana: chagua mashine na ubonyeze `s` kuitumia faili, au `c`, `n`, na `d` kunakili IP yake, jina lake, au jina lake kamili la DNS. Sawa yake kwenye terminal ni `omarchy tailscale send <machine> [file...]`, na faili zinazotumwa kwako hutua kwenye `~/Downloads` kiotomatiki. Arifa inayotangaza kuwasili husubiri hadi utakapoibofya kuifungua au kuiondoa, kwa hivyo faili inayojitokeza ukiwa mbali na mashine bado ipo kujibiwa utakaporudi.

Kuisakinisha pia huongeza programu ya wavuti kwa ajili ya dashibodi ya usimamizi ya Tailscale.

## Inapoacha kufanya kazi

Kabla ya kuwasha upya, jaribu kuwasha upya kipande kinachosumbua peke yake. _Update > Hardware_ ina Wi-Fi, Bluetooth, Audio, na Trackpad, na kupakia upya mojawapo ya hizo husuluhisha hali nyingi za "ilifanya kazi dakika tano zilizopita". Tazama [utatuzi wa matatizo](45-troubleshooting.md).
