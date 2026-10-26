# Hraní her

Omarchy není jen pro _pRoDUkTiViTu_, je také pro zábavu, a co je zábavnější než hraní her? Omarchy je dodávána s celou sadou herních možností — Steam a RetroArch pro nativní a retro hraní, Battle.net, Lutris a Heroic pro obchody mimo Steam, Moonlight pro streamování z počítače, Xbox Cloud Gaming + NVIDIA GeForce NOW pro cloud, plus věčně zelený Minecraft.

Díky neuvěřitelné práci společnosti Valve na [vrstvě kompatibility proton](https://en.wikipedia.org/wiki/Proton_(software)) nyní existuje v Linuxu desítky tisíc hratelných moderních her. A víte, že [Steam Deck](https://store.steampowered.com/steamdeck/) ve skutečnosti používá Arch!

Všechny instalační programy pro hraní her žijí v části _Instalovat > Hry_ v nabídce Omarchy (`Super + Space`). Pokud vůbec někdy budete chtít jeden vrátit zpět, použijte část _Odebrat > Hry_.

## Steam

Nainstalujte [Steam](https://store.steampowered.com/) výběrem položky _Instalovat > Hry > Steam_ z nabídky Omarchy (`Super + Space`).

Po instalaci budete moci Steam spustit pomocí klávesové zkratky `Super + Space`.

Pamatujte, že Steam se může spouštět 10–20 sekund a neposkytne žádnou vizuální zpětnou vazbu o tom, že se načítá.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Nainstalujte [RetroArch](https://www.retroarch.com/) výběrem položky _Instalovat > Hry > RetroArch_ z nabídky Omarchy (`Super + Space`). Je dodáván s úplnou sadou jader libretro, takže jsou pokryty všechny klasické systémy.

RetroArch je plně předkonfigurovaný s krásným shaderem CRT Royale pro dokonalý retro vzhled.

Jak začít:

1. Vložte své soubory BIOS do adresáře `~/Games/bios` a své ROM do adresáře `~/Games/roms`.
2. Spusťte RetroArch pomocí klávesové zkratky `Super + Space` a zadáním příkazu `retro`.
3. Prohledejte adresář `~/Games/roms` a můžete hrát.

Svou oblíbenou hru si můžete přidat jako vlastní položku ve spouštěči aplikací pomocí části _Instalovat > Hry > Spouštěč her RetroArch_, která vám umožní vybrat jádro a ROM a přejít přímo do hry z klávesové zkratky `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Nainstalujte webovou aplikaci Xbox Cloud Gaming výběrem položky _Instalovat > Hry > Xbox Cloud Gaming_ z nabídky Omarchy (`Super + Space`). Je to „jen“ webová aplikace pro tuto službu, ale spouští se rychle a v rozlišení 1080p běží skvěle.

Pokud již máte Xbox Game Pass, je to solidní způsob, jak hrát Fortnite a další tituly, které nemůžete provozovat nativně v Linuxu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Nainstalujte cloudovou herní službu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) výběrem položky _Instalovat > Hry > NVIDIA GeForce NOW_ z nabídky Omarchy (`Super + Space`). Další skvělý způsob, jak hrát tituly, které nejsou v Linuxu dostupné nativně.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Nainstalujte Minecraft výběrem položky _Instalovat > Hry > Minecraft_ z nabídky Omarchy (`Super + Space`).

Stejně jako u Steamu mějte na paměti, že po přihlášení nebo spuštění může zobrazení další obrazovky chvíli trvat a po dobu čekání nedostanete žádnou zpětnou vazbu.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Ovladače Xbox

Nainstalujte podporu pro ovladače Xbox přes Bluetooth výběrem položky _Instalovat > Hry > Ovladače Xbox_ z nabídky Omarchy (`Super + Space`). Spárujte ovladače prostřednictvím Bluetooth (`Super + Ctrl + B`) a budou fungovat ve všech vašich hrách. Toto nepotřebujete, pokud ovladač připojujete jen pevně kabelem USB-C.

## Moonlight (streamování her z počítače)

[klient Moonlight](https://github.com/moonlight-stream/moonlight-qt) je s Omarchy předinstalovaný, takže můžete okamžitě streamovat hry z počítače se systémem Windows, na kterém běží služba [Sunshine](https://app.lizardbyte.dev/Sunshine/). Moonlight spusťte prostřednictvím klávesové zkratky `Super + Space`.

Pokud jsou počítač s Omarchy i vzdálený herní počítač pevně připojené, je zážitek k nerozeznání od místního hraní. Zvyšte rozlišení na nativní, nastavte obnovovací frekvenci na 120 Hz a maximalizujte přenosovou rychlost — toto je nejlepší způsob, jak v Linuxu hrát konkurenční střílečky, například Fortnite.

Počítač s Omarchy můžete také proměnit v hostitele spuštěním příkazu `omarchy install service sunshine`, který nainstaluje Sunshine a otevře streamovací porty Moonlight pro vaši LAN a Tailscale.

## Battle.net

Nainstalujte [Battle.net](https://eu.shop.battle.net/en-us) výběrem položky _Instalovat > Hry > Battle.net_ z nabídky Omarchy (`Super + Space`). Získáte tak tituly jako Diablo, Starcraft a World of Warcraft jako samostatnou instalaci běžící pod GE-Proton — není potřeba Steam, Lutris ani Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (hry pro Windows)

Nainstalujte [Lutris](https://lutris.net/) výběrem položky _Instalovat > Hry > Lutris_ z nabídky Omarchy (`Super + Space`). Lutris je způsob, jak hrát hry pro Windows z obchodů, jako jsou EA a Ubisoft Connect, které výše nemají vlastní instalační program.

Instalace je trochu roztřesená a občas vypadá, jako by se nic nedělo — prostě buďte trpěliví, na pozadí to pracuje.

## Spouštěč Heroic (Epic Games)

Nainstalujte [spouštěč Heroic](https://heroicgameslauncher.com/) výběrem položky _Instalovat > Hry > Heroic (Epic Games)_ z nabídky Omarchy (`Super + Space`). Heroic umožňuje spouštět tituly z Epic Games, například OddSparks, které se nespoléhají na protipodvádění — plus hry z GOG a Amazon Prime Gaming. Bohužel to znamená žádný Fortnite a žádný Rocket League — dokud Tim Sweeney nepřejde do Linuxu, toto je nejdál, kam se dostaneme.

Stejně jako Lutris může při instalaci her působit pomale a roztřeseně. Dejte mu čas.
