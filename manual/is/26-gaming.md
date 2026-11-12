# Leikir

Omarchy er ekki bara fyrir _fRaMlEiÐnI_, það er líka til að skemmta sér, og hvað er skemmtilegra en að spila leiki? Með Omarchy fylgir heill pakki leikjavalkosta — Steam og RetroArch fyrir innfædda og retro-leiki, Battle.net, Lutris og Heroic fyrir verslanir utan Steam, Moonlight fyrir PC-streymi, Xbox Cloud Gaming + NVIDIA GeForce NOW fyrir skýið, auk hins sígræna Minecraft.

Þökk sé ótrúlegu starfi Valve við [Proton-samhæfingarlagið](https://en.wikipedia.org/wiki/Proton_(software)) eru nú tugþúsundir nútímaleikja spilanlegir á Linux. Ó, og vissir þú að [Steam Deck](https://store.steampowered.com/steamdeck/) keyrir í raun og veru Arch!

Öll uppsetningarforrit fyrir leiki eru undir _Setja upp > Leikir_ í Omarchy-valmyndinni (`Super + Space`). Ef þú vilt einhvern tímann afturkalla eina uppsetningu skaltu nota _Fjarlægja > Leikir_.

## Steam

Settu upp [Steam](https://store.steampowered.com/) með því að velja _Setja upp > Leikir > Steam_ úr Omarchy-valmyndinni (`Super + Space`).

Þegar þú hefur sett það upp geturðu ræst Steam með `Super + Space`.

Athugaðu að Steam getur tekið 10-20 sekúndur að ræsa og gefur engin sjónræn merki um að það sé að hlaðast inn.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Settu upp [RetroArch](https://www.retroarch.com/) með því að velja _Setja upp > Leikir > RetroArch_ úr Omarchy-valmyndinni (`Super + Space`). Með því fylgir allt safn libretro-kjarna, svo öll klassísku kerfin eru með í spilinu.

RetroArch er að fullu forstillt með hinum fallega CRT Royale-shader fyrir fullkomið retro-útlit.

Til að komast af stað:

1. Settu BIOS-skrárnar þínar í `~/Games/bios` og ROM-in þín í `~/Games/roms`.
2. Ræstu RetroArch með `Super + Space` og skrifaðu `retro`.
3. Skannaðu möppuna `~/Games/roms` og þú ert tilbúinn að spila.

Þú getur líka gefið uppáhaldsleiknum þínum eigin færslu í forritaræsinum með _Setja upp > Leikir > RetroArch Game Launcher_, sem gerir þér kleift að velja kjarna og ROM og hoppa beint inn í leikinn úr `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Settu upp vefforritið Xbox Cloud Gaming með því að velja _Setja upp > Leikir > Xbox Cloud Gaming_ úr Omarchy-valmyndinni (`Super + Space`). Það er „bara“ vefforrit fyrir þjónustuna, en það ræsist hratt og keyrir frábærlega í 1080p.

Ef þú ert nú þegar með Xbox Game Pass er þetta traust leið til að spila Fortnite og aðra titla sem þú getur ekki keyrt innfætt á Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Settu upp skýjaleikjaþjónustuna [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) með því að velja _Setja upp > Leikir > NVIDIA GeForce NOW_ úr Omarchy-valmyndinni (`Super + Space`). Önnur frábær leið til að spila titla sem ekki fást innfætt fyrir Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Settu upp Minecraft með því að velja _Setja upp > Leikir > Minecraft_ úr Omarchy-valmyndinni (`Super + Space`).

Eins og með Steam skaltu athuga að það getur tekið smá tíma eftir innskráningu eða við ræsingu þar til næsti skjár birtist, og þú færð engin merki á meðan þú bíður.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-stýringar

Settu upp stuðning við Xbox-stýringar í gegnum Bluetooth með því að velja _Setja upp > Leikir > Xbox Controllers_ úr Omarchy-valmyndinni (`Super + Space`). Paraðu stýringarnar í gegnum Bluetooth (`Super + Ctrl + B`) og þær virka í öllum leikjunum þínum. Þú þarft þetta ekki ef þú tengir stýringuna þína bara með USB-C-snúru.

## Moonlight (leikjastreymi frá PC)

Settu upp [Moonlight-biðlarann](https://github.com/moonlight-stream/moonlight-qt) með því að velja _Setja upp > Leikir > Moonlight_ úr Omarchy-valmyndinni (`Super + Space`), og þú getur streymt leikjum frá Windows-PC sem keyrir [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ef bæði Omarchy-vélin þín og fjarleikja-PC-vélin eru tengdar með snúru er upplifunin óaðgreinanleg frá því að spila á staðnum. Skrúfaðu upplausnina upp í innfædda upplausn, stilltu endurnýjunartíðnina á 120Hz og hámarkaðu bitahraðann — þetta er besta leiðin til að spila keppnisskotleiki á borð við Fortnite á Linux.

Þú getur líka breytt Omarchy-vél í gestgjafa með því að keyra `omarchy install service sunshine`, sem setur upp Sunshine og opnar Moonlight-streymisportin fyrir LAN-net þitt og Tailscale.

## Battle.net

Settu upp [Battle.net](https://eu.shop.battle.net/en-us) með því að velja _Setja upp > Leikir > Battle.net_ úr Omarchy-valmyndinni (`Super + Space`). Þetta gefur þér titla á borð við Diablo, Starcraft og World of Warcraft sem sjálfstæða uppsetningu sem keyrir undir GE-Proton — engin þörf á Steam, Lutris eða Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-leikir)

Settu upp [Lutris](https://lutris.net/) með því að velja _Setja upp > Leikir > Lutris_ úr Omarchy-valmyndinni (`Super + Space`). Lutris er leiðin til að spila Windows-leiki frá verslunum á borð við EA og Ubisoft Connect sem eru ekki með sitt eigið uppsetningarforrit hér að ofan.

Uppsetningin er dálítið óþjál og lítur stundum út eins og ekkert sé að gerast — vertu bara þolinmóður, hún er að vinna í bakgrunni.

## Heroic Launcher (Epic Games)

Settu upp [Heroic Launcher](https://heroicgameslauncher.com/) með því að velja _Setja upp > Leikir > Heroic (Epic Games)_ úr Omarchy-valmyndinni (`Super + Space`). Heroic gerir þér kleift að keyra Epic Games-titla, á borð við OddSparks, sem treysta ekki á anti-cheat — auk leikja frá GOG og Amazon Prime Gaming. Því miður þýðir það engan Fortnite og engan Rocket League — þar til Tim Sweeney kemur yfir á Linux er þetta það næsta sem þú kemst.

Eins og Lutris getur það virst hægt og óþjált á meðan leikir eru settir upp. Gefðu því tíma.
