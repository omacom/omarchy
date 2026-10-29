# Picha za mfumo

Tunatengeneza picha kiotomatiki kila Omarchy inaposasishwa, lakini ukitaka kutengeneza yako mwenyewe, unaweza kutumia `omarchy-snapshot create`.

Ili kuwasha na kurejesha picha, unaichagua kutoka kwenye kipakiaji cha kuwasha cha Limine. (Ikiwa kwa sasa unawasha moja kwa moja hadi kwenye skrini ya kusimbua ya Omarchy, utahitaji kuchagua Limine kama chaguo la kuwasha kupitia BIOS kwanza).

Kutoka kwenye skrini hiyo, chagua picha unayotaka kuwashia kulingana na tarehe na toleo. Toleo la Omarchy wakati picha ilipochukuliwa linaonekana kwenye kona ya chini kushoto.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ukifika ndani, arifa itatokea ikikuarifu kuwa uko ndani ya picha inayoweza kuwashwa na ukiibofya, itaanzisha mchakato wa kurejesha. Vinginevyo, unaweza kutumia `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Hii itarejesha mfumo wako wa faili wa mzizi, lakini si `/home` yako. Kwa hivyo inafaa kurejesha sasisho la mfumo lililoharibika, lakini si kurejesha faili za kibinafsi zilizopotea.

Hii pia inamaanisha kuwa saraka yako ya `~/.config` inabaki kama ilivyo. Kwa hivyo ukirejea kwenye toleo la awali la maktaba au programu inayohifadhi faili za usanidi katika umbizo jipya, utalazimika kushughulikia hilo mwenyewe.

Vivyo hivyo kwa rekodi ya Omarchy yenyewe kuhusu uhamishaji ambao tayari umekwishafanyika: inaishi katika saraka yako ya nyumbani, kwa hivyo inanusurika baada ya kurejesha. Uhamishaji uliofanyika baada ya picha kuchukuliwa unabaki umealamishwa kuwa umekamilika, ingawa mabadiliko waliyoyafanya kwenye mfumo wa faili wa mzizi yamerejeshwa nyuma, na `omarchy update` ijayo haitawafanya tena. Kwa hivyo ukisasisha tena baada ya kurejesha na kitu ambacho sasisho la awali lilikuwa limekiweka bado hakipo, hiyo ndiyo sababu inayowezekana zaidi.

_Kumbuka: Kipengele hiki kinapatikana tu kwenye usakinishaji unaotumia kipakiaji cha kuwasha cha Limine, ambacho kimekuwa chaguo-msingi tangu Omarchy 2.0. Hakipatikani ikiwa unatumia GRUB au systemd-boot._

### Kuruka menyu ya kuwasha

Ikiwa kamwe huigusi menyu ya kuwasha na unataka tu mashine iende moja kwa moja kwenye skrini ya kusimbua, endesha _Setup > Direct Boot_ kwenye menyu ya Omarchy. Hiyo inaongeza ingizo la EFI linaloelekeza moja kwa moja kwenye Omarchy, kwa hivyo programu dhibiti inaiwasha bila kusimama kwenye Limine.

Hasara yake ni ile iliyotajwa mwanzoni: kuwasha moja kwa moja kukiwa kumewashwa, kufikia picha kunamaanisha kuchagua Limine kutoka kwenye menyu ya kuwasha ya BIOS yako kwanza. Endesha _Setup > Direct Boot_ tena ili kuondoa ingizo hilo na kurudi kuwasha kupitia Limine. Baadhi ya programu dhibiti haikubaliani vyema na maingizo maalum ya EFI, kwa hivyo usanidi unakataa kufanya kazi kwenye programu dhibiti ya American Megatrends na Apple.
