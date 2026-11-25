# Usakinishaji wa Dual Boot

Unaweza kusakinisha Omarchy kwenye kizigeu kimoja pamoja na Windows au usakinishaji mwingine.

Mbinu hii ya usakinishaji bado huja na usimbaji fiche wa LUKS kwa kizigeu kwa chaguo-msingi, kwa hivyo kwa ufanisi haina tofauti na diski kamili na huhitaji tu nafasi wazi kupatikana kwenye diski.

## Kutengeneza Nafasi kwenye Windows

Ili kusakinisha pamoja na Windows, andika `disk management` kwenye menyu ya kuanza na uchague chaguo la **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tafuta kizigeu kinachofaa, bofya kulia, na uchague **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Weka kiasi unachotaka kupunguza ujazo. Kumbuka kuwa huu utakuwa ukubwa wa usakinishaji wako wa baadaye wa Omarchy ukiwemo kizigeu cha kuwasha.

 ![dual-boot-3](images/dual-boot-3.webp)

Ukimaliza, unapaswa kuona kitu kama hiki ambapo sehemu ya 50GB ndipo tutakaposakinisha Omarchy katika mfano huu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Kusakinisha Omarchy

Mchakato wa kusakinisha Omarchy kwa ufanisi ni sawa na wa kawaida. Baada ya kuchagua diski yako, utapewa chaguo la **Free space install**. Chagua chaguo hilo ili kuzuia kufuta diski kamili.

 ![dual-boot-5](images/dual-boot-5.webp)

Thibitisha kuwa kila kitu kinaonekana sawa na usubiri usakinishaji ukamilike kama kawaida. Hapa ndipo pia unaweza kuchagua kusakinisha bila usimbaji fiche (haipendekezwi) kama ilivyo kwenye usakinishaji wa diski kamili.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kuongeza Usakinishaji Mwingine kwenye Bootloader

Ukimaliza usakinishaji wako wa Omarchy, utaona kuwa bootloader ya Limine ndiyo chaguo-msingi sasa. Kwa hii, unaweza pia kuongeza chaguo kwenye Limine kwa usakinishaji wako mwingine kama vile Windows.

Ili kuongeza mifumo mingine ya uendeshaji, endesha `limine-scan` na ufuate maelekezo ya kuongeza maingizo unayotaka kwenye usanidi wako wa Limine. Menyu ya kuwasha hukaa imefichwa kwa chaguo-msingi na huanzisha Omarchy baada ya sekunde moja. Ili kuchagua Windows au ingizo lingine, bonyeza kitufe chochote mara tu Limine inapoanza; menyu inapotokea, tumia vitufe vya mishale kuchagua ingizo na ubonyeze Enter. Ikiwa Omarchy itaanza kabla hujabonyeza kitufe, anzisha upya na ujaribu tena.

## Bitlocker

Ni muhimu kutambua kuwa mbinu hii ya usakinishaji haioani na Bitlocker kwani husimba fiche diski nzima, si kizigeu tu. Ukikumbana na hitilafu inayosema kuwa Bitlocker imewashwa, washa kwenye Windows, nenda **Settings -> Privacy & Security -> Device encryption** na uzime Bitlocker. Huenda ikachukua muda kusimbua diski.

 ![dual-boot-7](images/dual-boot-7.webp)

## Kusakinisha Tena Windows

Ikiwa kompyuta hii ilikuja na Windows, ufunguo wake wa bidhaa umehifadhiwa kwenye firmware. Endesha `omarchy windows key` ili kuuchapisha, ili uweze kuwasha Windows tena ukiisakinisha tena kwenye mashine hii.
