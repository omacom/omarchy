# Upau wa Juu

Ukanda wa juu wa skrini yako ndio upau wa Omarchy. Si upau wa hali uliobanwa bali ni sehemu ya shell ya Omarchy, mchakato mmoja wa muda mrefu wa Quickshell unaochora pia menyu, arifa, ibukia za OSD, na skrini ya kufunga. Ndiyo sababu huweka mandhari kikamilifu na kila kitu kingine na kwa nini paneli hufunguka mara moja badala ya kuzaa programu mpya.

Pia ndicho kipande kimoja cha eneo-kazi kinachokuwa kwenye skrini daima, kwa hiyo inafaa kujua glifu hizo ndogo zote hufanya nini.

## Kilichopo kwa chaguomsingi

Upau una sehemu tatu. Kushoto hukaa nembo ya Omarchy (kizinduzi cha menyu) na viashiria vya nafasi ya kazi. Katikati unapata viashiria vya hali, saa, Elsewhen (saa ya dunia), hali ya hewa, na beji ya sasisho la Omarchy. Kulia: umbo la kibodi (zaidi ya moja ikisanidiwa), trei ya mfumo, maajenti, bluetooth, mtandao, sauti, skrini, na nguvu.

Baadhi ya hizo huonekana tu zinapokuwa na cha kusema. Umbo la kibodi huonekana tu ikiwa umesanidi zaidi ya umbo moja. Beji ya sasisho huonekana tu kuna sasisho la Omarchy linalongoja. Na aikoni ya maajenti huonekana mara ya kwanza Omarchy inapopata matumizi ya usimbaji wa AI kwenye mashine (tazama [AI](17-ai.md)).

## Kubofya huku na huko

Karibu kila wijeti hufanya kitu kwa kubofya kushoto, kulia, na katikati, na kadhaa hujibu kusogeza. Hii ndiyo sehemu ambayo watu hupita — vitufe vya kulia na katikati ndiko mambo mazuri mengi hujificha.

| Wijeti | Kushoto | Kulia | Katikati / kusogeza |
| --- | --- | --- | --- |
| Menyu | Menyu ya Omarchy | Terminali mpya | — |
| Nafasi za kazi | Zingatia nafasi hiyo ya kazi | — | Kusogeza: nafasi ya kazi inayofuata/ilitangulia |
| Saa | Kalenda ibukia | Badilisha umbizo la lebo | Katikati: kichaguzi cha eneo la saa |
| Hali ya hewa | Utabiri ibukia | Hali ya hewa kamili kama arifa | Katikati: onyesha upya |
| Sauti | Paneli ya sauti | Nyamazisha | Katikati: paneli · kusogeza: sauti |
| Maikrofoni | Nyamazisha maikrofoni | — | Katikati: paneli ya sauti · kusogeza: sauti ya ingizo |
| Mtandao | Paneli ya mtandao | — | — |
| Bluetooth | Paneli ya Bluetooth | Badilisha redio | — |
| Skrini | Paneli ya skrini | — | Kusogeza: mwangaza |
| Nguvu | Paneli ya nguvu | Badilisha asilimia ya betri | — |
| Vyombo | Cheza/sitisha | Picha ya jalada ibukia | Katikati: inayofuata · kusogeza: ilitangulia/inayofuata |
| Maajenti | Paneli ya maajenti | Zindua ajenti wako | Katikati: usajili unaofuata |
| Trei | Elea kufungua droo | Kulia kwenye chevron kudhibiti | — |
| Sasisho la Omarchy | Endesha sasisho | — | — |

Si kila kitu katika jedwali hilo kiko kwenye upau wako mara moja. Wijeti ya vyombo (MPRIS inayocheza sasa, na wimbo na msanii vinavyosogeza) na wijeti ya maikrofoni zote mbili zimejengwa ndani lakini zimezimwa kwa chaguomsingi — ziongeze ukizitaka, kama ilivyoelezwa hapa chini.

## Paneli

Kubofya aikoni ya upau hufungua paneli, ambayo ni ibukia sahihi yenye vitelezi, orodha, na urambazaji wa kibodi badala ya kidokezo. Kila moja pia ina mkato wa kitufe, kwa hiyo huna kamwe kulenga glifu ya pikseli 16:

| Mkato wa kitufe | Paneli |
| --- | --- |
| `Super + Ctrl + A` | Sauti |
| `Super + Ctrl + W` | Mtandao |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skrini |
| `Super + Ctrl + P` | Nguvu |
| `Super + Ctrl + Alt + D` | Kalenda |
| `Super + Ctrl + Alt + E` | Saa ya dunia |
| `Super + Ctrl + 1-9` | Badilisha paneli ya nth katika sehemu ya kulia |

Paneli si visomo. Ndipo unapofanya jambo kweli:

- **Sauti** ina kitelezi kikuu cha sauti, kichaguzi cha kifaa cha kutoa, na kichanganya kwa kila programu, ili uweze kupunguza kichupo hicho kimoja cha kivinjari bila kugusa kila kitu kingine.
- **Mtandao** hutafuta Wi-Fi, huonyesha nguvu ya ishara, huunganisha, na hukuruhusu kuchagua mtoa huduma wa DNS.
- **Bluetooth** huorodhesha vifaa vyako na kuunganisha/kutenganisha na viwango vya betri.
- **Nguvu** huonyesha takwimu za betri, hubadilisha wasifu wa nguvu (hukumbuka chaguo tofauti kwa betri na AC), na huchapisha taarifa fulani za mfumo.
- **Skrini** hubeba kitelezi cha mwangaza, ukubwa wa maandishi, mapreseti ya upanuzi wa skrini, na — ukiwa na zaidi ya skrini moja — vidhibiti kwa kila skrini. Tazama [skrini](33-monitors.md) kwa hadithi yenye kina zaidi.
- **Saa** hufungua gridi ya mwezi yenye nambari za wiki za ISO na hatua za mwezi.

Kila paneli huchukua kibodi pamoja na kipanya: mishale husogeza, Return huamsha, Tab hupitia paneli ya jirani, na Escape hufunga.

`Super + Ctrl + 1-9` huhesabu paneli kushoto hadi kulia katika sehemu ya kulia, ikiruka trei kwa kuwa haina paneli yake mwenyewe. Kwa hiyo nambari inalingana na aikoni ambayo ungeielekezea.

### Tailscale na Dropbox

Wijeti mbili zaidi huonekana kwenye upau mara tu unaposakinisha huduma inayolingana kutoka **Sakinisha → Huduma**, na zote mbili zinafaa kujulikana kwa sababu hufanya zaidi ya kuripoti hali.

Paneli ya **Tailscale** huunganisha na kutenganisha tailnet, hubadilisha kati ya akaunti, na huchagua nodi ya kutoka (mashine zako mwenyewe na maeneo ya Mullvad yote huonekana katika orodha hiyo). Pia huvinjari mashine zako — na moja ikichaguliwa, `s` hutuma faili kwake kupitia Taildrop, ambayo ndiyo njia ya haraka zaidi ya kusogeza faili kwenda simu yako au kompyuta mpakato nyingine. `c` hunakili IP ya mashine, `n` jina lake, na `d` jina lake kamili la DNS. Kuna kitufe cha kutuma kwenye kila safu ya mashine pia, ikiwa unapendelea kubofya. Jambo hilo hilo kutoka terminali ni `omarchy tailscale send <machine> [file...]`.

Paneli ya **Dropbox** hushughulikia kuingia, huonyesha hifadhi kiasi gani umetumia, na huorodhesha faili zilizosawazishwa hivi karibuni.

Kuondoa huduma yoyote hurejesha wijeti yake kutoka kwenye upau.

## Viashiria

Kundi ndogo katikati ndilo wijeti ya viashiria. Hizi ni glifu za hali kwa namna ulizowasha: usinisumbue, taa ya usiku, [kikumbusho](09-reminders.md) kilichowekwa foleni, kurekodi skrini kunakotumika, usilale, na [imla](11-text-extraction-dictation.md). Huanga wakati hali inatumika na vinginevyo hubaki mbali — elea kushoto kwa saa (juu yake kwenye upau wima) kuchungulia visivyotumika. Kubofya kiashiria hubadilisha hali hiyo. Moja zaidi ni hali tu: kipindi cha mbali huanga nyekundu wakati mtu ameunganishwa kwenye mashine hii kupitia gliff.

Ikiwa unapendelea vionekane daima, weka `alwaysShow` kuwa `true` kwenye wijeti. Na ikiwa unajali baadhi tu, orodhesha unazotaka katika `items`: `["Dnd", "Reminder", "NightLight"]`. Unaweza kuwa na zaidi ya wijeti moja ya viashiria, hivyo sehemu tofauti zinaweza kuonyesha sehemu ndogo tofauti.

## Kupanga upya upau

Upau hujisanidi wenyewe. Huhitaji kufungua faili ya usanidi kusogeza vitu.

Shika kipande tupu cha upau karibu na katikati na kuiburuta kuelekea ukingo mwingine wa skrini, na upau huenda huko — kushoto, kulia, juu, au chini yote hufanya kazi, na kila wijeti hujibadilisha (mipau wima hurudi kwenye umbo finyu la aikoni tu). Kubofya-na-kushikilia huanzisha uburutaji huo huo. Bofya mara mbili kushoto nafasi hiyo hiyo tupu kubadilisha mandhari ya upau kutoka wazi kwenda kioo kwenda isiyoangavu. Na buruta wijeti yoyote kuipanga upya au kuitupa katika sehemu nyingine.

Wijeti unayoitaka iwepo karibu lakini isiwe inaonekana kila wakati inaweza kwenda katika droo ya trei: iburute juu ya trei, na droo itafunguka kuipokea. Hukaa hapo baada ya aikoni za programu, huonekana kila droo inapoonekana, na huifanya droo ibaki wazi wakati paneli yake imefunguliwa. Iburute nje tena kuirudisha kwenye upau.

Ikiwa unapendelea kuchagua kutoka menyu, **Anzisha → Muonekano → Upau wa menyu** ina nafasi, na **Mandhari ya Upau** huchagua jinsi upau unavyochorwa: **Upau Usioangavu**, **Upau wa Kioo** (unaona nyuma, na kilicho nyuma kimefumbwa), au **Upau Wazi**.

Mambo hayo hayo yana amri, ambayo ndiyo unayoitaka kwa usanidi wa [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Kuongeza au kuondoa wijeti kabisa, tumia amri za programu-jalizi. `omarchy plugin list` huchapisha kila wijeti ambayo shell inajua na kitambulisho chake, na kisha:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Kuficha upau

`Super + Shift + Space` hubadilisha upau kuzimwa na kuwashwa tena bila kuua shell — paneli na mikato ya vitufe huendelea kufanya kazi, unarudishiwa tu pikseli. Iko pia katika menyu chini ya **Anzisha → Muonekano → Upau wa menyu → Ficha upau**.

## Faili ya usanidi

Yote huhifadhiwa katika `~/.config/omarchy/shell.json`, chini ya ufunguo `bar`. Hapa kuna toleo lililopunguzwa:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Kila wijeti ni ingizo moja katika moja ya safu tatu za mpangilio, na mipangilio yake hukaa ndani ya mstari kwenye ingizo hilo — hakuna faili tofauti ya mipangilio na hakuna kitu kidogo cha `config`. `format` ya saa, `formatAlt` (kile ambacho kubofya kulia hubadilisha kwenda), na `verticalFormat` yote huishi pale pale kwenye `{ "id": "omarchy.clock" }`.

`centerAnchor` hutaja wijeti moja ya katikati inayobanwa kwenye katikati kamili ya skrini, na nyingine kuizunguka. Hivyo ndivyo saa inavyobaki katikati kabisa hata hali ya hewa na beji ya sasisho vinapokuja na kuondoka. Iweke kuwa mfuatano tupu na orodha ya katikati huwekwa katikati tu kama kundi badala yake.

Kanuni moja inayofaa kuingiza ndani: **ukishakuwa na `shell.json` yako mwenyewe, ni rasmi**. Hadi ubinafsishe chochote, shell husoma faili chaguomsingi ya Omarchy. Wakati unapoburuta wijeti, kuendesha `omarchy bar`, au kuhariri faili mwenyewe, unakuwa mmiliki wake — hakuna uunganishaji wa kina, hivyo wijeti mpya chaguomsingi katika matoleo ya baadaye ya Omarchy hazitaonekana kwenye upau wako kiotomatiki. `omarchy bar defaults` hurejesha mpangilio uliotumwa wakati wowote unapotaka ukurasa safi.

Faili hiyo hiyo pia huhifadhi nyakati zako za uvivu katika kiwango cha juu, nje ya ufunguo `bar`: `idle.screensaver` na `idle.lock`, zote katika sekunde tangu ulipokuwa mvivu. Kwa hiyo kiokozi cha skrini chaguomsingi huanza katika sekunde 150 na kufunga katika 300.
