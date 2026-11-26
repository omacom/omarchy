# Nakala za mfumo

Tunaunda nakala kiotomatiki kila Omarchy inaposasishwa, lakini ukitaka kuunda yako mwenyewe, unaweza kutumia `omarchy-snapshot create`.

Jinsi unavyowasha na kurejesha nakala inategemea kipakiaji cha kuwasha ambacho mashine yako huanza nacho. Usakinishaji mpya wa UEFI hutumia systemd-boot; usakinishaji wa zamani na mashine za BIOS hutumia Limine. `omarchy-boot-backend` inakuambia ulicho nacho.

## Ukiwa na systemd-boot

Chagua _System > Snapshots_ kwenye menyu ya Omarchy na uchague nakala unayotaka kuwasha ndani yake. Mashine huwasha upya ndani yake mara moja. Au shikilia Space mashine inapoanza ili kuona menyu ya kuwasha, ambapo kila nakala imeorodheshwa mpya kwanza ikiwa na toleo lake la Omarchy na tarehe.

Nakala huwashwa ikiwa na safu ya muda juu yake, kwa hivyo unaweza kuitumia kama kawaida, lakini chochote unachobadilisha hutoweka kwenye kuwasha upya kunakofuata. Ili kuihifadhi, ifanye kuwa mfumo wako: bofya arifa inayoonekana unapoingia, chagua _System > Snapshots > Restore This Snapshot_, au endesha `omarchy-snapshot restore`. Urejeshaji hutokea mashine inapowasha upya. Mfumo kama ulivyokuwa awali hubaki kwenye menyu ya kuwasha kama _Before restore_, na `omarchy-snapshot restore backup` huurejesha.

Kutoka kwenye terminal:

- `omarchy-snapshot list` huorodhesha nakala unazoweza kuwasha;
- `omarchy-snapshot boot 12` huwasha upya ndani ya nakala 12 mara moja;
- `omarchy-snapshot restore 12` huifanya nakala 12 kuwa mfumo kwenye kuwasha upya kunakofuata, na `omarchy-snapshot restore --cancel` hubadilisha uamuzi wako kabla ya kuwasha upya huko.

## Ukiwa na Limine

Ili kuwasha na kurejesha nakala, unaichagua kutoka kwenye kipakiaji cha kuwasha cha Limine. Menyu ya kuwasha hubaki imefichwa kwa chaguo-msingi, kwa hivyo bonyeza kitufe chochote Limine inapoanza tu ili kuionyesha.

Kutoka kwenye skrini hiyo, chagua nakala unayotaka kuwasha ndani yake kulingana na tarehe na toleo. Toleo la Omarchy lililokuwapo wakati nakala ilipoundwa linaweza kuonekana kwenye kona ya chini kushoto.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ukifika ndani, arifa itatokeza ikikujulisha kuwa uko ndani ya nakala inayoweza kuwashwa na ukiibofya, itaanzisha mchakato wa urejeshaji. Vinginevyo, unaweza kutumia `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Urejeshaji unahusisha nini

Urejeshaji hurejesha mfumo wako wa faili wa mzizi, lakini si `/home` yako. Kwa hivyo unafaa kurejesha sasisho la mfumo lililoharibika, lakini si kurejesha faili binafsi zilizopotea.

Hii pia inamaanisha kuwa saraka yako ya `~/.config` hubaki kama ilivyo. Kwa hivyo ukirejea kwenye toleo la awali la maktaba au programu inayohifadhi faili za usanidi katika umbizo jipya, itabidi ushughulikie hilo mwenyewe.

Vivyo hivyo kwa rekodi ya Omarchy yenyewe ya ni uhamishaji gani tayari umeendeshwa: inaishi katika saraka yako ya nyumbani, kwa hivyo inasalia baada ya urejeshaji. Uhamishaji ulioendeshwa baada ya nakala kuchukuliwa hubaki umewekwa alama kuwa umekamilika, ingawa mabadiliko uliyofanya kwenye mfumo wa faili wa mzizi yamerudishwa nyuma, na `omarchy update` inayofuata haitauendesha tena. Kwa hivyo ukisasisha tena baada ya urejeshaji na kitu ambacho sasisho la awali lilikuwa limekiweka bado hakipo, hiyo ndiyo sababu inayowezekana zaidi.
