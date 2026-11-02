# Usakinishaji wa Dual Boot

Unaweza kusakinisha Omarchy kwenye kizigeu kimoja pamoja na Windows au usakinishaji mwingine.

Mbinu hii ya usakinishaji bado inakuja na usimbaji fiche wa LUKS kwa kizigeu kwa chaguo-msingi, kwa hivyo kwa vitendo haina tofauti na usakinishaji kwenye diski nzima na inahitaji tu nafasi tupu ipatikane kwenye diski.

## Kuandaa Nafasi kwenye Windows

Ili kusakinisha pamoja na Windows, andika `disk management` kwenye menyu ya mwanzo na uchague chaguo la **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tafuta kizigeu kinachofaa, bofya kulia, na uchague **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Weka kiasi unachotaka kupunguza ujazo. Kumbuka kwamba hiki ndicho kitakuwa ukubwa wa usakinishaji wako wa baadaye wa Omarchy ikijumuisha kizigeu cha kuwasha.

 ![dual-boot-3](images/dual-boot-3.webp)

Ukimaliza, unapaswa kuona kitu kama hiki ambapo sehemu ya 50GB ndipo tutakaposakinisha Omarchy katika mfano huu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Kusakinisha Omarchy

Mchakato wa kusakinisha Omarchy kwa vitendo ni sawa na wa kawaida. Baada ya kuchagua diski yako, utapewa chaguo la **Free space install**. Chagua chaguo hilo ili kuzuia kufuta diski nzima.

 ![dual-boot-5](images/dual-boot-5.webp)

Thibitisha kwamba kila kitu kinaonekana sawa na usubiri usakinishaji ukamilike kama kawaida. Hapa ndipo pia unaweza kuchagua kusakinisha bila usimbaji fiche (haipendekezwi) kama ilivyo kwenye usakinishaji wa diski nzima.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kuongeza Usakinishaji Mwingine kwenye Bootloader

Ukimaliza usakinishaji wako wa Omarchy, utaona kwamba Limine bootloader sasa ndiyo chaguo-msingi. Kwa hii, unaweza pia kuongeza chaguo kwenye Limine kwa ajili ya usakinishaji wako mwingine kama vile Windows.

Ili kuongeza mifumo mingine ya uendeshaji, endesha `limine-scan` na ufuate maagizo ili kuongeza maingizo unayotaka kwenye usanidi wako wa Limine. Menyu ya kuwasha hubaki imefichwa kwa chaguo-msingi na huwasha Omarchy baada ya sekunde moja. Ili kuchagua Windows au ingizo lingine, bonyeza kitufe chochote mara tu Limine inapoanza; menyu itakapoonekana, tumia vitufe vya mishale kuchagua ingizo na ubonyeze Enter. Ikiwa Omarchy itawaka kabla hujabonyeza kitufe, anzisha upya na ujaribu tena. Ikiwa uliwasha _Setup > Direct Boot_, programu dhibiti huruka Limine kabisa, kwa hivyo chagua Limine kutoka kwenye menyu ya kuwasha ya BIOS yako au endesha _Setup > Direct Boot_ tena ili kuondoa ingizo hilo.

## Bitlocker

Ni muhimu kutambua kwamba mbinu hii ya usakinishaji haiendani na Bitlocker kwani husimba fiche diski nzima, si kizigeu tu. Ukikumbana na hitilafu inayosema kuwa Bitlocker imewashwa, washa Windows, nenda kwenye **Settings -> Privacy & Security -> Device encryption** na uzime Bitlocker. Huenda ikachukua muda kusimbua diski.

 ![dual-boot-7](images/dual-boot-7.webp)
