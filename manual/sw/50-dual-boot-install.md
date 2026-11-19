# Usakinishaji wa Dual Boot

Unaweza kusakinisha Omarchy kwenye kizigeu kimoja pamoja na Windows au usakinishaji mwingine.

Njia hii ya usakinishaji bado huja na usimbaji fiche wa LUKS kwa kizigeu kwa chaguo-msingi kwa hivyo kwa vitendo haina tofauti na diski nzima na inahitaji tu nafasi tupu ipatikane kwenye diski.

## Kutengeneza Nafasi kwenye Windows

Ili kusakinisha pamoja na Windows, andika `disk management` kwenye menyu ya kuanza na uchague chaguo la **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tafuta kizigeu kinachofaa, bofya kulia, na uchague **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Weka kiasi ambacho ungependa kupunguza ujazo huo. Kumbuka kuwa hii itakuwa saizi ya usakinishaji wako wa Omarchy wa baadaye ikijumuisha kizigeu cha kuwasha.

 ![dual-boot-3](images/dual-boot-3.webp)

Ukimaliza, unapaswa kuona kitu kama hiki ambapo sehemu ya 50GB ndipo tutasakinisha Omarchy katika mfano huu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Kusakinisha Omarchy

Mchakato wa usakinishaji wa Omarchy kwa vitendo ni sawa na wa kawaida. Baada ya kuchagua diski yako, utapewa chaguo la **Free space install**. Chagua chaguo hilo ili kuzuia kufuta diski nzima.

 ![dual-boot-5](images/dual-boot-5.webp)

Thibitisha kuwa kila kitu kinaonekana vizuri na usubiri usakinishaji umalizike kama kawaida. Hapa pia ndipo unaweza kuchagua kusakinisha bila usimbaji fiche (haipendekezwi) kama tu kwenye usakinishaji wa diski nzima.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kuongeza Usakinishaji Mwingine kwenye Bootloader

Unapomaliza usakinishaji wako wa Omarchy, utaona kuwa bootloader ya Limine ndiyo chaguo-msingi sasa. Kwa hili, unaweza pia kuongeza chaguo kwenye Limine kwa ajili ya usakinishaji wako mwingine kama vile Windows.

Ili kuongeza mifumo mingine ya uendeshaji, endesha `limine-scan` na ufuate maelekezo ili kuongeza maingizo unayotaka kwenye usanidi wako wa Limine. Menyu ya kuwasha hubaki imefichwa kwa chaguo-msingi na huanzisha Omarchy baada ya sekunde moja. Ili kuchagua Windows au ingizo lingine, bonyeza kitufe chochote mara tu Limine inapoanza; menyu inapoonekana, tumia vitufe vya mishale kuchagua ingizo na ubonyeze Enter. Ikiwa Omarchy itaanza kabla hujabonyeza kitufe, anzisha upya na ujaribu tena.

## Bitlocker

Ni muhimu kutambua kuwa njia hii ya usakinishaji haioani na Bitlocker kwa kuwa husimba fiche diski nzima, si kizigeu tu. Ukikumbana na hitilafu inayosema kuwa Bitlocker imewashwa, washa hadi Windows, nenda kwenye **Settings -> Privacy & Security -> Device encryption** na uzime Bitlocker. Huenda ikachukua muda kusimbua diski.

 ![dual-boot-7](images/dual-boot-7.webp)
