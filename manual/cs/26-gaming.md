# Hraní her

Omarchy není jen na _pRoDUkTiViTu_, je taky na zábavu, a co je zábavnější než hraní her? Omarchy obsahuje celou sadu herních možností — Steam a RetroArch pro nativní a retro hraní, Battle.net, Lutris a Heroic pro obchody mimo Steam, Moonlight pro streamování z PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pro cloud a k tomu nestárnoucí Minecraft.

Díky neuvěřitelné práci Valve na [protonové vrstvě kompatibility](https://en.wikipedia.org/wiki/Proton_(software)) je dnes na Linuxu hratelných desítky tisíc moderních her. Jo, a věděli jste, že [Steam Deck](https://store.steampowered.com/steamdeck/) ve skutečnosti běží na Archu!

Všechny instalační programy her najdete v nabídce Omarchy (`Super + Space`) v části _Install > Gaming_. Pokud budete chtít některý z nich někdy odebrat, použijte _Remove > Gaming_.

## Steam

Nainstalujte [Steam](https://store.steampowered.com/) tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Steam_.

Po instalaci budete moct Steam spouštět pomocí `Super + Space`.

Počítejte s tím, že spuštění Steam může trvat 10-20 sekund a že vám během načítání nebude poskytovat žádnou vizuální odezvu.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Nainstalujte [RetroArch](https://www.retroarch.com/) tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > RetroArch_. Obsahuje kompletní sadu jader libretro, takže jsou pokryté všechny klasické systémy.

RetroArch je plně předkonfigurovaný s nádherným shaderem CRT Royale pro dokonalý retro vzhled.

Jak začít:

1. Vložte soubory BIOSu do `~/Games/bios` a své ROMky do `~/Games/roms`.
2. Spusťte RetroArch pomocí `Super + Space` a napsáním `retro`.
3. Prohledejte adresář `~/Games/roms` a můžete hrát.

Oblíbené hře můžete také vytvořit vlastní položku ve spouštěči aplikací pomocí _Install > Gaming > RetroArch Game Launcher_, kde si vyberete jádro a ROMku a skočíte rovnou do hry z `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Webovou aplikaci Xbox Cloud Gaming nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Xbox Cloud Gaming_. Je to „jen“ webová aplikace pro tuto službu, ale rychle se spouští a skvěle běží v rozlišení 1080p.

Pokud už máte Xbox Game Pass, je to spolehlivý způsob, jak hrát Fortnite a další tituly, které na Linuxu nativně nespustíte.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Cloudovou herní službu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > NVIDIA GeForce NOW_. Další skvělý způsob, jak hrát tituly, které na Linuxu nejsou nativně dostupné.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Minecraft_.

Stejně jako u Steam počítejte s tím, že po přihlášení nebo spuštění může chvíli trvat, než se objeví další obrazovka, a že během čekání nedostanete žádnou odezvu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Podporu pro Bluetooth ovladače Xbox nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Xbox Controllers_. Ovladače spárujte přes Bluetooth (`Super + Ctrl + B`) a budou fungovat ve všech vašich hrách. Toto nepotřebujete, pokud ovladač připojujete jen kabelem USB-C.

## Moonlight (streamování her z PC)

[Klienta Moonlight](https://github.com/moonlight-stream/moonlight-qt) nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Moonlight_, a můžete streamovat hry z PC s Windows, na kterém běží [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Pokud jsou vaše zařízení s Omarchy i vzdálené herní PC připojené kabelem, zážitek je k nerozeznání od hraní lokálně. Nastavte rozlišení na nativní, obnovovací frekvenci na 120Hz a bitrate na maximum — je to nejlepší způsob, jak na Linuxu hrát kompetitivní střílečky jako Fortnite.

Zařízení s Omarchy můžete také proměnit v hostitele spuštěním `omarchy install service sunshine`, což nainstaluje Sunshine a otevře porty pro streamování přes Moonlight pro vaši LAN a Tailscale.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Battle.net_. Získáte tak tituly jako Diablo, Starcraft a World of Warcraft jako samostatnou instalaci běžící pod GE-Proton — není potřeba Steam, Lutris ani Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (hry pro Windows)

[Lutris](https://lutris.net/) nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Lutris_. Lutris je způsob, jak hrát hry pro Windows z obchodů jako EA a Ubisoft Connect, které výše nemají vlastní instalační program.

Instalace je trochu kostrbatá a občas to vypadá, že se nic neděje — buďte trpěliví, na pozadí to pracuje.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) nainstalujete tak, že v nabídce Omarchy (`Super + Space`) vyberete _Install > Gaming > Heroic (Epic Games)_. Heroic vám umožní hrát tituly z Epic Games, jako je OddSparks, které nespoléhají na anti-cheat — a k tomu hry z GOG a Amazon Prime Gaming. Bohužel to znamená žádný Fortnite a žádné Rocket League — dokud Tim Sweeney nedorazí na Linux, blíže se k tomu nedostanete.

Stejně jako Lutris může při instalaci her působit pomale a kostrbatě. Dejte mu čas.
