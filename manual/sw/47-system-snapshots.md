# Picha za mfumo

Tunaunda picha za mfumo kiotomatiki kila wakati Omarchy inaposasishwa, lakini ukitaka kuunda yako mwenyewe, unaweza kutumia `omarchy-snapshot create`.

Ili kuwasha na kurejesha picha ya mfumo, unaichagua kutoka kwa kipakiaji cha kuwasha cha Limine. Menyu ya kuwasha hubaki imefichwa kwa chaguo-msingi, kwa hiyo bonyeza kitufe chochote mara tu Limine inapoanza ili kuionyesha.

Kutoka kwenye skrini hiyo, chagua picha ya mfumo unayotaka kuwasha kulingana na tarehe na toleo. Toleo la Omarchy wakati picha ya mfumo ilipoundwa linaweza kuonekana kwenye kona ya chini kushoto.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Unapofika ndani, arifa itatokea kukujulisha kuwa uko kwenye picha ya mfumo inayoweza kuwashwa na ukiibofya, itaanzisha mchakato wa kurejesha. Vinginevyo, unaweza kutumia `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Hii itarejesha mfumo wako wa faili wa mizizi, lakini si `/home` yako. Kwa hiyo inafaa kurejesha sasisho la mfumo lililoharibika, lakini si kurejesha faili za kibinafsi zilizopotea.

Hii pia inamaanisha kuwa saraka yako ya `~/.config` hubaki kama ilivyo. Kwa hiyo ukirudi kwenye toleo la awali la maktaba au programu inayohifadhi faili za usanidi katika umbizo jipya, itakubidi kulishughulikia hilo mwenyewe.

Vivyo hivyo kwa rekodi ya Omarchy yenyewe ya ni uhamishaji upi tayari umeendeshwa: inaishi katika saraka yako ya nyumbani, kwa hiyo inasalia baada ya kurejesha. Uhamishaji ulioendeshwa baada ya picha ya mfumo kuundwa hubaki umewekwa alama kuwa umekamilika, ingawa mabadiliko waliyofanya kwenye mfumo wa faili wa mizizi yamerudishwa nyuma, na `omarchy update` inayofuata haitauendesha tena. Kwa hiyo ukisasisha tena baada ya kurejesha na kitu ambacho sasisho la awali lilikuwa limekiweka bado hakipo, hiyo ndiyo sababu inayowezekana zaidi.

_Kumbuka: Kipengele hiki kinapatikana tu kwenye usakinishaji unaotumia kipakiaji cha kuwasha cha Limine, ambacho kimekuwa chaguo-msingi tangu Omarchy 2.0. Hakipatikani ikiwa unatumia GRUB au systemd-boot._
