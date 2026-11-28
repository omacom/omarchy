# Hraní her

Omarchy není jen na _pRoDUkTiViTu_, je taky na zábavu, a co je zábavnější než hraní her? Omarchy se dodává s celou sadou herních možností — Steam a RetroArch pro nativní a retro hraní, Battle.net, Lutris a Heroic pro obchody mimo Steam, Moonlight pro streamování z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pro cloud a k tomu nestárnoucí Minecraft.

Díky neuvěřitelné práci Valve na [vrstvě kompatibility Proton](https://en.wikipedia.org/wiki/Proton_(software)) jsou dnes na Linuxu hratelné desítky tisíc moderních her. Jo, a věděli jste, že [Steam Deck](https://store.steampowered.com/steamdeck/) ve skutečnosti běží na Archu!

Všechny herní instalátory najdete v menu Omarchy pod _Install > Gaming_ (`Super + Space`). Pokud budete chtít některý někdy zrušit, použijte _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris a Heroic jsou nabízeny pouze na počítačích s x86.

## Steam

[Steam](https://store.steampowered.com/) nainstalujete výběrem _Install > Gaming > Steam_ v menu Omarchy (`Super + Space`).

Po instalaci budete moct Steam spouštět pomocí `Super + Space`.

Mějte na paměti, že spuštění Steamu může trvat 10-20 sekund a během načítání vám neposkytne žádnou vizuální odezvu.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

[RetroArch](https://www.retroarch.com/) nainstalujete výběrem _Install > Gaming > RetroArch_ v menu Omarchy (`Super + Space`). Dodává se s kompletní sadou jader libretro, takže jsou pokryté všechny klasické systémy.

RetroArch je plně přednastavený s krásným shaderem CRT Royale pro dokonalý retro vzhled.

Jak začít:

1. Vložte soubory BIOS do `~/Games/bios` a ROMky do `~/Games/roms`.
2. Spusťte RetroArch pomocí `Super + Space` a napsání `retro`.
3. Prohledejte adresář `~/Games/roms` a jste připraveni hrát.

Své oblíbené hře můžete také dát vlastní položku ve spouštěči aplikací pomocí _Install > Gaming > RetroArch Game Launcher_, který vám umožní vybrat jádro a ROM a skočit rovnou do hry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Webovou aplikaci Xbox Cloud Gaming nainstalujete výběrem _Install > Gaming > Xbox Cloud Gaming_ v menu Omarchy (`Super + Space`). Je to „jen“ webová aplikace pro danou službu, ale spouští se rychle a skvěle běží v 1080p.

Pokud už máte Xbox Game Pass, je to solidní způsob, jak hrát Fortnite a další tituly, které na Linuxu nativně nespustíte.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Cloudovou herní službu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) nainstalujete výběrem _Install > Gaming > NVIDIA GeForce NOW_ v menu Omarchy (`Super + Space`). Další skvělý způsob, jak hrát tituly, které nejsou na Linuxu dostupné nativně.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft nainstalujete výběrem _Install > Gaming > Minecraft_ v menu Omarchy (`Super + Space`).

Stejně jako u Steamu mějte na paměti, že po přihlášení nebo spuštění může chvíli trvat, než se objeví další obrazovka, a během čekání nedostanete žádnou odezvu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Ovladače Xbox

Podporu pro Bluetooth ovladače Xbox nainstalujete výběrem _Install > Gaming > Xbox Controllers_ v menu Omarchy (`Super + Space`). Ovladače spárujte přes Bluetooth (`Super + Ctrl + B`) a budou fungovat ve všech vašich hrách. Tohle nepotřebujete, pokud ovladač připojujete natvrdo kabelem USB-C.

## Moonlight (streamování her z PC)

[Klienta Moonlight](https://github.com/moonlight-stream/moonlight-qt) nainstalujete výběrem _Install > Gaming > Moonlight_ v menu Omarchy (`Super + Space`) a můžete streamovat hry z PC s Windows, na kterém běží [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Pokud jsou jak váš počítač s Omarchy, tak vzdálené herní PC připojené kabelem, zážitek je k nerozeznání od hraní lokálně. Vyžeňte rozlišení na nativní, nastavte obnovovací frekvenci na 120Hz a bitrate na maximum — tohle je nejlepší způsob, jak na Linuxu hrát kompetitivní střílečky jako Fortnite.

Počítač s Omarchy můžete také proměnit v hostitele spuštěním `omarchy install service sunshine`, což nainstaluje Sunshine a otevře porty pro streamování přes Moonlight pro vaši LAN a Tailscale.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) nainstalujete výběrem _Install > Gaming > Battle.net_ v menu Omarchy (`Super + Space`). Získáte tak tituly jako Diablo, Starcraft a World of Warcraft jako samostatnou instalaci běžící pod GE-Proton — žádný Steam, Lutris ani Heroic nejsou potřeba.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (hry pro Windows)

[Lutris](https://lutris.net/) nainstalujete výběrem _Install > Gaming > Lutris_ v menu Omarchy (`Super + Space`). Lutris je způsob, jak hrát hry pro Windows z obchodů jako EA a Ubisoft Connect, které výše nemají vlastní instalátor.

Instalace je trochu krkolomná a občas to vypadá, že se nic neděje — buďte prostě trpěliví, na pozadí to pracuje.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) nainstalujete výběrem _Install > Gaming > Heroic (Epic Games)_ v menu Omarchy (`Super + Space`). Heroic vám umožní hrát tituly z Epic Games, jako je OddSparks, které nezávisí na anti-cheatu — plus hry z GOG a Amazon Prime Gaming. Bohužel to znamená žádný Fortnite a žádné Rocket League — dokud Tim Sweeney nepřijde na Linux, blíž se k tomu nedostanete.

Stejně jako Lutris může při instalaci her působit pomale a krkolomně. Dejte mu čas.
