# Leikir

Omarchy er ekki bara fyrir _pRoDUcTiVItY_, það er líka til að hafa gaman, og hvað er skemmtilegra en leikir? Omarchy kemur með heilt úrval leikjavalkosta — Steam og RetroArch fyrir innfædda og retro spilun, Battle.net, Lutris og Heroic fyrir verslanir utan Steam, Moonlight fyrir PC-streymi, Xbox Cloud Gaming + NVIDIA GeForce NOW fyrir ský, auk hins sígræna Minecraft.

Þökk sé ótrúlegu starfi Valve við [proton-samhæfilagið](https://en.wikipedia.org/wiki/Proton_(software)) eru nú tugir þúsunda spilanlegra nútímaleikja á Linux. Já, og vissir þú að [Steam Deck](https://store.steampowered.com/steamdeck/) keyrir í raun Arch!

Allir leikjauppsetningar búa undir _Setja upp > Leikir_ í Omarchy-valmyndinni (`Super + Space`). Ef þú vilt einhvern tímann afturkalla einn skaltu nota _Fjarlægja > Leikir_.

## Steam

Settu upp [Steam](https://store.steampowered.com/) með því að velja _Setja upp > Leikir > Steam_ úr Omarchy-valmyndinni (`Super + Space`).

Eftir að þú hefur sett það upp munt þú geta ræst Steam með `Super + Space`.

Athugaðu að það getur tekið Steam 10-20 sekúndur að ræsast, og það mun ekki gefa neina sjónræna endurgjöf um að það sé að hlaða.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Settu upp [RetroArch](https://www.retroarch.com/) með því að velja _Setja upp > Leikir > RetroArch_ úr Omarchy-valmyndinni (`Super + Space`). Það kemur með fullu settinu af libretro-kjörnum, þannig að öll klassísku kerfin eru þakin.

RetroArch er fullkomlega forstillt með fallega CRT Royale-shadernum fyrir þetta fullkomna retro-útlit.

Til að komast í gang:

1. Settu BIOS-skrárnar þínar í `~/Games/bios` og ROM-in þín í `~/Games/roms`.
2. Ræstu RetroArch með `Super + Space` og skrifaðu `retro`.
3. Skannaðu möppuna `~/Games/roms` og þú ert tilbúinn að spila.

Þú getur líka gefið uppáhaldsleik sína eigin færslu í forritaræsinum með _Setja upp > Leikir > RetroArch-leikjaræsi_, sem leyfir þér að velja kjarna og ROM, og stökkva beint inn í leikinn úr `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Settu upp Xbox Cloud Gaming vefforritið með því að velja _Setja upp > Leikir > Xbox Cloud Gaming_ úr Omarchy-valmyndinni (`Super + Space`). Það er „bara“ vefforrit fyrir þjónustuna, en það er fljótlegt að ræsa og keyrir frábærlega í 1080p.

Ef þú ert nú þegar með Xbox Game Pass er þetta traust leið til að spila Fortnite og aðra titla sem þú getur ekki keyrt innfætt á Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Settu upp skýjaleikjaþjónustuna [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) með því að velja _Setja upp > Leikir > NVIDIA GeForce NOW_ úr Omarchy-valmyndinni (`Super + Space`). Önnur frábær leið til að spila titla sem eru ekki fáanlegir innfætt á Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Settu upp Minecraft með því að velja _Setja upp > Leikir > Minecraft_ úr Omarchy-valmyndinni (`Super + Space`).

Eins og Steam skaltu athuga að það getur tekið smá tíma eftir innskráningu eða ræsingu þar til næsti skjár birtist, og þú munt ekki fá neina endurgjöf á meðan þú bíður.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-stýringar

Settu upp stuðning við Bluetooth Xbox-stýringar með því að velja _Setja upp > Leikir > Xbox-stýringar_ úr Omarchy-valmyndinni (`Super + Space`). Paraðu stýringarnar í gegnum Bluetooth (`Super + Ctrl + B`) og þær munu virka í öllum leikjum þínum. Þú þarft þetta ekki ef þú ert bara að tengja stýringuna þína með snúru með USB-C snúru.

## Moonlight (Leikjastreymi frá PC)

[Moonlight-viðskiptavinurinn](https://github.com/moonlight-stream/moonlight-qt) kemur foruppsettur með Omarchy, þannig að þú getur streymt leikjum frá Windows-PC sem keyrir [Sunshine](https://app.lizardbyte.dev/Sunshine/) strax. Ræstu Moonlight í gegnum `Super + Space`.

Ef bæði Omarchy-vélin þín og fjarlæga leikja-PC-ið eru tengd með snúru er upplifunin óaðgreinanleg frá því að spila staðbundið. Hækkaðu upplausnina upp í innfædda, stilltu endurnýjunina á 120Hz og hámarkaðu bitahraðann — þetta er besta leiðin til að spila samkeppnisskotleiki eins og Fortnite á Linux.

Þú getur líka breytt Omarchy-vél í hýsilinn með því að keyra `omarchy install service sunshine`, sem setur upp Sunshine og opnar Moonlight-streymisportin fyrir LAN-ið þitt og Tailscale.

## Battle.net

Settu upp [Battle.net](https://eu.shop.battle.net/en-us) með því að velja _Setja upp > Leikir > Battle.net_ úr Omarchy-valmyndinni (`Super + Space`). Þetta gefur þér titla eins og Diablo, Starcraft og World of Warcraft sem sjálfstæða uppsetningu sem keyrir undir GE-Proton — engin þörf fyrir Steam, Lutris eða Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-leikir)

Settu upp [Lutris](https://lutris.net/) með því að velja _Setja upp > Leikir > Lutris_ úr Omarchy-valmyndinni (`Super + Space`). Lutris er leiðin til að spila Windows-leiki frá verslunum eins og EA og Ubisoft Connect sem hafa ekki sinn eigin uppsetningaraðila hér að ofan.

Uppsetningin er svolítið hrufótt og lítur stundum út eins og ekkert sé að gerast — vertu bara þolinmóður, hún vinnur í bakgrunni.

## Heroic Launcher (Epic Games)

Settu upp [Heroic Launcher](https://heroicgameslauncher.com/) með því að velja _Setja upp > Leikir > Heroic (Epic Games)_ úr Omarchy-valmyndinni (`Super + Space`). Heroic leyfir þér að keyra Epic Games-titla, eins og OddSparks, sem treysta ekki á svindlvörn — auk leikja frá GOG og Amazon Prime Gaming. Því miður þýðir það enginn Fortnite og enginn Rocket League — þar til Tim Sweeney kemur til Linux er þetta það næsta sem fæst.

Eins og Lutris getur þetta fundist hægfara og hrufótt á meðan verið er að setja upp leiki. Gefðu því tíma.
