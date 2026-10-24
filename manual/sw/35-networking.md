# Mtandao

Mtandao katika Omarchy unashughulikiwa na NetworkManager, na unaudhibiti kupitia aikoni ya mtandao katika [upau wa juu](05-the-top-bar.md) au kwa `Super + Ctrl + W`.

Paneli hiyo hutafuta mitandao ya Wi-Fi, huonyesha nguvu ya mawimbi, na huunganisha. Ethernet haihitaji chochote kabisa — ichomeke tu na itafanya kazi. Ukitaka kubaki kwenye terminali, `nmtui` hukupa vidhibiti vile vile, na pia kuna kikundi cha amri cha `omarchy network`.

## Kushiriki Wi-Fi yako

Badala ya kusoma nenosiri refu kwa sauti, endesha _Sanidi > Mtandao > Msimbo wa QR_ ukiwa kwenye Wi-Fi. Hiyo huweka msimbo wa QR kwenye skrini ambao kamera yoyote ya simu inaweza kuchanganua ili kujiunga. Ni mojawapo ya mambo ambayo utaitumia zaidi kuliko unavyotarajia mara utakapojua kuwa ipo.

Kama kweli unahitaji nenosiri lenyewe, `omarchy network password <interface>` hulichapisha.

## DNS

Omarchy hutumia DNS yoyote ambayo mtandao wako hutoa kupitia DHCP. Unaweza kubadilisha hilo kwa mashine nzima chini ya _Sanidi > Mtandao > DNS_, ambapo Cloudflare na Google ziko umbali wa kubofya mara moja. Chagua _Maalum_ ili kuchapa seva zako mwenyewe.

Kutoka terminali, `omarchy dns` huchapisha mtoaji wa sasa na `omarchy dns Cloudflare` huweka mmoja.

## Kubandika bendi ya Wi-Fi

Kama kipanga njia chako huweka 2.4GHz, 5GHz, na 6GHz kwenye jina moja la mtandao, kompyuta yako mpakato wakati mwingine itang'ang'ania yenye kasi ndogo. `omarchy network band` huonyesha ni bendi gani uko, na `omarchy network band 5` huibandika. Tumia `auto` kuiruhusu ichague tena.

Hii hubandika bendi badala ya kituo maalum cha ufikiaji, kwa hivyo unaendelea kurandaranda kati ya AP kawaida.

## Ikasi gani?

_Anzisha > Jaribio la kasi > Jaribio la kasi ya mtandao_ hupima kasi yako halisi ya kupakia na kupakua kwa jozi ya vipima. Kutoka terminali ni `omarchy network speedtest down` au `up`. (Kuna jaribio la kasi ya diski lililokaa karibu nayo katika menyu hiyo, kama unapima kifundo kingine.)

## Ngome ya moto (firewall)

Ngome ya moto imewashwa kwa chaguomsingi na huzuia trafiki yote inayoingia, isipokuwa moja: porti 53317, ili [LocalSend](22-guis.md) ifanye kazi mara moja.

SSH imezimwa hadi uiwashe kwa _Sanidi > Usalama > SSHD_, ambayo huanzisha daemon, hufungua porti 22 kiwango-kinachodhibitiwa dhidi ya majaribio ya nguvu (brute force), na kuidhinisha ufunguo. Docker pia imefungwa vizuri, ili makasha (containers) yasiweze kujidhihirisha ulimwenguni kwa bahati mbaya. Tazama [usalama](48-security.md) kwa hadithi nzima.

## Tailscale

[Tailscale](https://tailscale.com/) ni VPN ya mesh ambayo hufanya kufikia kompyuta na seva zako zote kupitia intaneti kuwa rahisi na salama. Isakinishe kwa _Sakinisha > Huduma > Tailscale_.

Hiyo hukupa paneli ya Tailscale katika upau, ambayo huunganisha na kutenganisha tailnet, hubadilisha akaunti, na huchagua nodi ya kutoka — mashine zako mwenyewe na mikoa ya Mullvad zote huonekana katika orodha. Pia huvinjari mashine zako, na hapo ndipo Taildrop inapokaa: teua mashine na ubonyeze `s` kuitumia faili, au `c`, `n`, na `d` kunakili IP yake, jina lake, au jina lake kamili la DNS. Sawia ya terminali ni `omarchy tailscale send <machine> [file...]`, na faili ulizotumiwa hutua katika `~/Downloads` kiotomatiki. Arifa inayotangaza kuwasili husubiri hadi uibofye ili kuifungua au kuipuuza, kwa hivyo faili inayowasili ukiwa mbali na mashine bado ipo kujibu ukirudi.

Kuisakinisha pia huongeza programu ya wavuti kwa kiweko cha usimamizi cha Tailscale.

## Inapoacha kufanya kazi

Kabla ya kuwasha upya, jaribu kuwasha upya sehemu yenye tatizo yenyewe. _Sasisha > Vifaa_ ina Wi-Fi, Bluetooth, Sauti, na Kiguso, na kupakia upya moja ya hizo humaliza hali nyingi za "ilifanya kazi dakika tano zilizopita". Tazama [kutatua matatizo](45-troubleshooting.md).
