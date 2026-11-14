# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) är ett ljuvligt alternativ till något som GitHub Desktop-applikationen, och det körs inne i terminalen.

Du kan köra det direkt genom att gå till valfri katalog som hanteras av git och köra `lazygit`. Eller så kan du köra det inne i Neovim där det kan startas med `Space G G`.

Du hoppar mellan de olika rutorna med `Tab`. I rutan Files väljer du filer för staging med `Space`, och sedan kan du skapa en ny commit med `c`. Du kan se alla tillgängliga kommandon med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) är en vacker resurshanterare som visar användning av minne, CPU, disk och nätverk. Den listar också alla aktiva processer och låter dig hantera dem.

Omarchy kallar den Activity, och du startar den genom att trycka på `Super + Shift + T`. Den öppnas som ett flytande fönster, som du kan lägga in i layouten med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) är en arbetsytehanterare för terminalen som ger dig arbetsytor, flikar och rutor, och håller dem alla igång i en beständig session som du kan koppla loss från och komma tillbaka till senare.

Du startar den (eller återansluter till din befintliga session) med `Super + Ctrl + Return`. Omarchy levereras med en Herdr-konfiguration som speglar dess Tmux-konfiguration, så prefix-tangenten är `Ctrl + Space` här också. Du kan bläddra bland alla tangentbindningar med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) visar systeminformation, som kärnversion, drifttid, tema, CPU, minne och mer. Det är en efterföljare till det populära verktyget neofetch.

Omarchy har paketerat detta som _About_ i Omarchy-menyn (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) är en musikspelare för terminalen i retrostil inspirerad av Winamp 2.x, komplett med inbyggda radiostationer för lo-fi beats. Starta den med `Super + Shift + Alt + M`, eller från Omarchy-menyn under _Apps_. Tryck på `?` för hela listan över tangentbindningar.

## Vad gäller Wi-Fi och Bluetooth?

Du hittar inga TUIs för Wi-Fi och Bluetooth — de jobben tillhör Omarchy-skalet. Klicka på Wi-Fi-ikonen i den övre raden (eller tryck på `Super + Ctrl + N`) för att se nätverk och ansluta, och klicka på Bluetooth-ikonen (eller tryck på `Super + Ctrl + B`) för att parkoppla och ansluta enheter. Se [nätverk](35-networking.md) för hela historien.

## Lägga till dina egna

Alla terminalprogram kan få full appbehandling. Gå till _Install > TUI_ i Omarchy-menyn (`Super + Space`), ge det ett namn, ett startkommando, en fönsterstil och en ikon, så dyker det upp i appstartaren som vilken annan applikation som helst. Du kan ta bort det igen under _Remove > TUI_.
