# Usakinishaji wa Dual Boot

Unaweza kusakinisha Omarchy kwenye kizigeu kimoja karibu na Windows au usakinishaji mwingine.

Mbinu hii ya usakinishaji bado huja na usimbaji wa LUKS kwa kizigeu kwa chaguomsingi kwa hivyo ni sawa kabisa na kiendeshaji kamili na ni muhimu tu nafasi ya bure ipatikane kwenye diski.

## Kufanya Nafasi kwenye Windows

Kusakinisha karibu na Windows, chapa `disk management` katika menyu ya kuanza na uchague chaguo la **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Pata kizigeu kinachofaa, bofya kulia, na uchague **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Weka kiasi unachotaka kupunguza volume nacho. Kumbuka kuwa hii itakuwa ukubwa wa usakinishaji wako wa baadaye wa Omarchy ikiwa ni pamoja na kizigeu cha kuwasha.

 ![dual-boot-3](images/dual-boot-3.webp)

Ukimaliza, unapaswa kuona kitu kama hiki ambapo sehemu ya 50GB ndiyo ambapo tutasakinisha Omarchy katika mfano huu.

 ![dual-boot-4](images/dual-boot-4.webp)

## Kusakinisha Omarchy

Mchakato wa kusakinisha Omarchy ni sawa kabisa na wa kawaida. Baada ya kuchagua diski yako, utapewa chaguo la **Free space install**. Chagua chaguo hilo ili kuzuia kufuta diski nzima.

 ![dual-boot-5](images/dual-boot-5.webp)

Thibitisha kuwa kila kitu kinaonekana vizuri na usubiri usakinishaji umalizike kama kawaida. Hapa pia ndipo unaweza kuchagua kusakinisha bila usimbaji (haipendekezwi) kama tu kwenye usakinishaji wa kiendeshaji kamili.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kuongeza Usakinishaji Mwingine kwenye Bootloader

Ukimaliza usakinishaji wako wa Omarchy, utaona kuwa bootloader ya Limine ndiyo chaguomsingi sasa. Kwa hii, unaweza pia kuongeza chaguo kwenye Limine kwa usakinishaji wako mwingine kama Windows.

Ili kufanya hivyo, endesha `limine-scan` na ufuate madokezo ili kuongeza vitu vyovyote unavyovitaka kwenye usanidi wako wa limine. Kisha unapowasha, utaona chaguo zako za kawaida za Omarchy, pamoja na Windows Boot Manager au nyinginezo.

## Bitlocker

Ni muhimu kutambua kuwa mbinu hii ya usakinishaji haiendani na Bitlocker kwani husimba kiendeshaji kizima, si kizigeu tu. Kama unakutana na hitilafu inayosema kuwa Bitlocker imewezeshwa, washa Windows, nenda **Settings -> Privacy & Security -> Device encryption** na uzime Bitlocker. Inaweza kuchukua muda kusimbua kiendeshaji.

 ![dual-boot-7](images/dual-boot-7.webp)
