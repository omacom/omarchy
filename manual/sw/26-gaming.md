# Michezo

Omarchy si kwa ajili ya _uZaLiShAjI_ tu, ni kwa ajili ya kufurahia pia, na kuna furaha gani kubwa zaidi kuliko michezo? Omarchy inakuja na mkusanyiko kamili wa chaguo za michezo — Steam na RetroArch kwa ajili ya michezo ya asili na ya zamani, Battle.net, Lutris, na Heroic kwa ajili ya maduka yasiyo ya Steam, Moonlight kwa ajili ya utiririshaji kutoka PC, Xbox Cloud Gaming + NVIDIA GeForce NOW kwa ajili ya wingu, pamoja na Minecraft ya kudumu.

Shukrani kwa kazi ya ajabu ya Valve kwenye [tabaka la uoanifu la proton](https://en.wikipedia.org/wiki/Proton_(software)), sasa kuna makumi ya maelfu ya michezo ya kisasa inayochezeka kwenye Linux. Oh, na je, ulijua kwamba [Steam Deck](https://store.steampowered.com/steamdeck/) kweli huendesha Arch!

Visakinishi vyote vya michezo vinapatikana chini ya _Install > Gaming_ katika menyu ya Omarchy (`Super + Space`). Ukitaka kuondoa kimoja, tumia _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris, na Heroic hutolewa kwenye mashine za x86 pekee.

## Steam

Sakinisha [Steam](https://store.steampowered.com/) kwa kuchagua _Install > Gaming > Steam_ kutoka kwenye menyu ya Omarchy (`Super + Space`).

Baada ya kuisakinisha, utaweza kuzindua Steam kwa `Super + Space`.

Kumbuka kwamba Steam inaweza kuchukua sekunde 10-20 kuanza, na haitatoa mrejesho wowote wa kuona kwamba inapakia.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Sakinisha [RetroArch](https://www.retroarch.com/) kwa kuchagua _Install > Gaming > RetroArch_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Inakuja na seti kamili ya libretro cores, hivyo mifumo yote ya kawaida imejumuishwa.

RetroArch imepangiliwa awali kikamilifu na shader nzuri ya CRT Royale kwa ajili ya muonekano huo kamili wa zamani.

Kuanza:

1. Weka faili zako za BIOS kwenye `~/Games/bios` na ROMs zako kwenye `~/Games/roms`.
2. Zindua RetroArch kwa `Super + Space` na kuandika `retro`.
3. Chunguza saraka ya `~/Games/roms` na uko tayari kucheza.

Unaweza pia kuupa mchezo unaoupenda ingizo lake lenyewe katika kizindua programu kwa _Install > Gaming > RetroArch Game Launcher_, ambacho hukuwezesha kuchagua core na ROM, na kuruka moja kwa moja kwenye mchezo kutoka `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Sakinisha programu ya wavuti ya Xbox Cloud Gaming kwa kuchagua _Install > Gaming > Xbox Cloud Gaming_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Ni programu ya wavuti "tu" kwa ajili ya huduma hiyo, lakini inaanza haraka na inafanya kazi vizuri sana kwa 1080p.

Ikiwa tayari una Xbox Game Pass, hii ni njia thabiti ya kucheza Fortnite na michezo mingine ambayo huwezi kuiendesha asilia kwenye Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Sakinisha huduma ya michezo ya wingu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) kwa kuchagua _Install > Gaming > NVIDIA GeForce NOW_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Njia nyingine nzuri ya kucheza michezo ambayo haipatikani asilia kwenye Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Sakinisha Minecraft kwa kuchagua _Install > Gaming > Minecraft_ kutoka kwenye menyu ya Omarchy (`Super + Space`).

Kama Steam, kumbuka kwamba inaweza kuchukua muda baada ya kuingia au kuanza kwa skrini inayofuata kuonekana, na hutapata mrejesho wowote unaposubiri.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Vidhibiti vya Xbox

Sakinisha usaidizi wa vidhibiti vya Xbox vya Bluetooth kwa kuchagua _Install > Gaming > Xbox Controllers_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Oanisha vidhibiti kupitia Bluetooth (`Super + Ctrl + B`) navyo vitafanya kazi katika michezo yako yote. Huhitaji hii ikiwa unaunganisha tu kidhibiti chako kwa kebo ya USB-C.

## Moonlight (Utiririshaji wa michezo kutoka PC)

Sakinisha [kiteja cha Moonlight](https://github.com/moonlight-stream/moonlight-qt) kwa kuchagua _Install > Gaming > Moonlight_ kutoka kwenye menyu ya Omarchy (`Super + Space`), na unaweza kutiririsha michezo kutoka PC ya Windows inayoendesha [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ikiwa mashine yako ya Omarchy na PC ya mbali ya michezo zote zimeunganishwa kwa waya, uzoefu hautatofautiana na kucheza ndani ya mashine yenyewe. Pandisha azimio hadi la asilia, weka kiwango cha uonyeshaji upya kuwa 120Hz, na ongeza bitrate hadi kiwango cha juu zaidi — hii ndiyo njia bora ya kucheza michezo ya upigaji risasi ya ushindani kama Fortnite kwenye Linux.

Unaweza pia kubadilisha mashine ya Omarchy kuwa mwenyeji kwa kuendesha `omarchy install service sunshine`, ambayo husakinisha Sunshine na kufungua milango ya utiririshaji ya Moonlight kwa ajili ya LAN yako na Tailscale.

## Battle.net

Sakinisha [Battle.net](https://eu.shop.battle.net/en-us) kwa kuchagua _Install > Gaming > Battle.net_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Hii hukupa michezo kama Diablo, Starcraft, na World of Warcraft kama usakinishaji unaojitegemea unaoendeshwa chini ya GE-Proton — Steam, Lutris, au Heroic haihitajiki.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Michezo ya Windows)

Sakinisha [Lutris](https://lutris.net/) kwa kuchagua _Install > Gaming > Lutris_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Lutris ndiyo njia ya kucheza michezo ya Windows kutoka maduka kama EA na Ubisoft Connect ambayo hayana kisakinishi chake yenyewe hapo juu.

Usakinishaji si laini sana na inaonekana kama hakuna kinachoendelea wakati mwingine — kuwa na subira tu, unafanya kazi chinichini.

## Heroic Launcher (Epic Games)

Sakinisha [Heroic Launcher](https://heroicgameslauncher.com/) kwa kuchagua _Install > Gaming > Heroic (Epic Games)_ kutoka kwenye menyu ya Omarchy (`Super + Space`). Heroic hukuwezesha kuendesha michezo ya Epic Games, kama OddSparks, ambayo haitegemei anti-cheat — pamoja na michezo kutoka GOG na Amazon Prime Gaming. Kwa kusikitisha, hiyo inamaanisha hakuna Fortnite na hakuna Rocket League — hadi Tim Sweeney aje Linux, hii ndiyo iliyo karibu zaidi unayoweza kupata.

Kama Lutris, inaweza kuhisi polepole na isiyo laini wakati wa kusakinisha michezo. Ipe muda.
