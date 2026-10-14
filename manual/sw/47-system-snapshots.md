# Picha za mfumo (snapshots)

Huunda picha kiotomatiki kwenye kila sasisho la Omarchy, lakini kama unataka kuunda yako mwenyewe, unaweza kutumia `omarchy-snapshot create`.

Kuwasha na kurejesha picha, unaichagua kutoka kipakiaji cha kuwasha cha Limine. (Kama kwa sasa unawasha moja kwa moja kwenye skrini ya usimbuaji wa Omarchy, utahitaji kuchagua Limine kama chaguo la kuwasha kupitia BIOS kwanza).

Kutoka skrini hiyo, chagua picha unayoitaka kuwashia kulingana na tarehe na toleo. Toleo la Omarchy wakati wa picha linaweza kuonekana kona ya chini kushoto.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Unapofika ndani, arifa itajitokeza kukujulisha kuwa uko katika picha inayoweza kuwashwa na kama utaibofya, utaanza mchakato wa urejesho. Vinginevyo, unaweza kutumia `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Hii itarejesha mfumo wako wa faili wa mizizi, lakini si `/home` yako. Kwa hivyo hufanya kazi kwa kubatilisha sasisho la mfumo lililovunjika, lakini si kwa kurejesha faili za kibinafsi zilizopotea.

Hii pia inamaanisha kuwa saraka yako ya `~/.config` hutunzwa kama ilivyo. Kwa hivyo kama unarudi kwenye toleo la awali la maktaba au programu ambayo huhifadhi faili za usanidi katika umbizo jipya, itabidi ulitatue hilo mwenyewe.

_Kumbuka: Kipengele hiki kinapatikana tu kwenye usakinishaji unaotumia kipakiaji cha kuwasha cha Limine, ambacho kimekuwa chaguomsingi tangu Omarchy 2.0. Haikupatikani kama uko kwenye GRUB au systemd-boot._

### Kuruka menyu ya kuwasha

Kama kamwe hugusi menyu ya kuwasha na unataka tu mashine iende moja kwa moja kwenye skrini ya usimbuaji, endesha _Sanidi > Direct Boot_ katika menyu ya Omarchy. Hiyo huongeza ingizo la EFI linaloashiria moja kwa moja kwa Omarchy, kwa hivyo firmware huiwasha bila kusimama kwenye Limine.

Kubadilishana ni ile iliyotajwa juu: na kuwasha moja kwa moja kumewashwa, kufikia picha kunamaanisha kuchagua Limine kutoka menyu yako ya kuwasha ya BIOS kwanza. Endesha _Sanidi > Direct Boot_ tena kuondoa ingizo na kurudi kwenye kuwasha kupitia Limine. Firmware nyingine haipendi maingizo ya EFI maalum, kwa hivyo usanidi unakataa kuendesha kwenye firmware ya American Megatrends na Apple.
