# Leikir

Omarchy er ekki bara fyrir _fRaMlEiÐnI_, það er líka til að hafa gaman, og hvað er skemmtilegra en að spila tölvuleiki? Omarchy kemur með heila föruneyti af leikjamöguleikum — Steam og RetroArch fyrir innfædda og retro-leiki, Battle.net, Lutris og Heroic fyrir verslanir utan Steam, Moonlight fyrir tölvustraumun, Xbox Cloud Gaming + NVIDIA GeForce NOW fyrir skýjaleiki, auk hins sígilda Minecraft.

Þökk sé ótrúlegri vinnu Valve við [Proton-samhæfnislagið](https://en.wikipedia.org/wiki/Proton_(software)) eru nú tugþúsundir nútíma leikja spilanlegir á Linux. Ó, og vissir þú að [Steam Deck](https://store.steampowered.com/steamdeck/) keyrir í raun Arch!

Allir leikjauppsetningarvalkostir eru undir _Setja upp > Leikir_ í Omarchy-valmyndinni (`Super + Space`). Ef þú vilt nokkurn tíma afturkalla einhvern þeirra skaltu nota _Fjarlægja > Leikir_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris og Heroic eru aðeins í boði á x86-vélum.

## Steam

Settu upp [Steam](https://store.steampowered.com/) með því að velja _Setja upp > Leikir > Steam_ í Omarchy-valmyndinni (`Super + Space`).

Eftir að þú hefur sett það upp geturðu ræst Steam með `Super + Space`.

Athugaðu að Steam getur tekið 10-20 sekúndur að ræsa sig og það gefur engin sjónræn merki um að það sé að hlaðast inn.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Settu upp [RetroArch](https://www.retroarch.com/) með því að velja _Setja upp > Leikir > RetroArch_ í Omarchy-valmyndinni (`Super + Space`). Það kemur með öllu safninu af libretro-kjörnum, svo öll klassísku kerfin eru studd.

RetroArch er að fullu forstillt með hinum fallega CRT Royale-shader fyrir þetta fullkomna retro-útlit.

Til að byrja:

1. Settu BIOS-skrárnar þínar í `~/Games/bios` og ROM-in þín í `~/Games/roms`.
2. Ræstu RetroArch með `Super + Space` og sláðu inn `retro`.
3. Skannaðu `~/Games/roms` möppuna og þú ert tilbúinn að spila.

Þú getur líka gefið uppáhaldsleiknum þínum sína eigin færslu í forritaræsinum með _Setja upp > Leikir > RetroArch Game Launcher_, sem gerir þér kleift að velja kjarna og ROM og hoppa beint inn í leikinn frá `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Settu upp Xbox Cloud Gaming vefforritið með því að velja _Setja upp > Leikir > Xbox Cloud Gaming_ í Omarchy-valmyndinni (`Super + Space`). Þetta er „bara“ vefforrit fyrir þjónustuna, en það ræsist fljótt og keyrir frábærlega í 1080p.

Ef þú ert nú þegar með Xbox Game Pass er þetta traust leið til að spila Fortnite og aðra titla sem þú getur ekki keyrt innfætt á Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Settu upp skýjaleikjaþjónustuna [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) með því að velja _Setja upp > Leikir > NVIDIA GeForce NOW_ í Omarchy-valmyndinni (`Super + Space`). Önnur frábær leið til að spila titla sem eru ekki fáanlegir innfætt á Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Settu upp Minecraft með því að velja _Setja upp > Leikir > Minecraft_ í Omarchy-valmyndinni (`Super + Space`).

Eins og með Steam skaltu athuga að það getur tekið smá tíma eftir innskráningu eða ræsingu þar til næsti skjár birtist, og þú færð engin merki á meðan þú bíður.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Settu upp stuðning fyrir Bluetooth Xbox-stýringar með því að velja _Setja upp > Leikir > Xbox Controllers_ í Omarchy-valmyndinni (`Super + Space`). Paraðu stýringarnar í gegnum Bluetooth (`Super + Ctrl + B`) og þær munu virka í öllum leikjunum þínum. Þú þarft þetta ekki ef þú ert bara að tengja stýringuna þína með snúru með USB-C kapli.

## Moonlight (Game streaming from a PC)

Settu upp [Moonlight-forritið](https://github.com/moonlight-stream/moonlight-qt) með því að velja _Setja upp > Leikir > Moonlight_ í Omarchy-valmyndinni (`Super + Space`), og þú getur streymt leikjum frá Windows-tölvu sem keyrir [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ef bæði Omarchy-vélin þín og fjarlæga leikjatölvan eru tengdar með snúru er upplifunin óaðgreinanleg frá því að spila staðbundið. Skrúfaðu upplausnina upp í innfædda upplausn, stilltu endurnýjunartíðnina á 120Hz og hámarkaðu bitahraðann — þetta er besta leiðin til að spila keppnisskotleiki eins og Fortnite á Linux.

Þú getur líka breytt Omarchy-vél í gestgjafann með því að keyra `omarchy install service sunshine`, sem setur upp Sunshine og opnar Moonlight-straumunarportin fyrir LAN-ið þitt og Tailscale.

## Battle.net

Settu upp [Battle.net](https://eu.shop.battle.net/en-us) með því að velja _Setja upp > Leikir > Battle.net_ í Omarchy-valmyndinni (`Super + Space`). Þetta gefur þér titla eins og Diablo, Starcraft og World of Warcraft sem sjálfstæða uppsetningu sem keyrir undir GE-Proton — engin þörf á Steam, Lutris eða Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

Settu upp [Lutris](https://lutris.net/) með því að velja _Setja upp > Leikir > Lutris_ í Omarchy-valmyndinni (`Super + Space`). Lutris er leiðin til að spila Windows-leiki frá verslunum eins og EA og Ubisoft Connect sem eru ekki með sinn eigin uppsetningarvalkost hér að ofan.

Uppsetningin er svolítið klaufaleg og lítur stundum út eins og ekkert sé að gerast — vertu bara þolinmóður, hún er að vinna í bakgrunni.

## Heroic Launcher (Epic Games)

Settu upp [Heroic Launcher](https://heroicgameslauncher.com/) með því að velja _Setja upp > Leikir > Heroic (Epic Games)_ í Omarchy-valmyndinni (`Super + Space`). Heroic gerir þér kleift að keyra Epic Games-titla, eins og OddSparks, sem treysta ekki á svindlvörn — auk leikja frá GOG og Amazon Prime Gaming. Því miður þýðir það engan Fortnite og engan Rocket League — þangað til Tim Sweeney kemur til Linux er þetta það næsta sem þú kemst.

Eins og Lutris getur það virst hægt og klaufalegt á meðan það setur upp leiki. Gefðu því tíma.
