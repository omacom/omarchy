# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) är ett härligt alternativ till något som GitHub Desktop-appen, och det körs inne i terminalen.

Du kan köra det direkt genom att gå till valfri katalog som hanteras av git och köra `lazygit`. Eller så kan du köra det inne i Neovim, där det kan startas med `Space G G`.

Du hoppar mellan de olika rutorna med `Tab`. I rutan Files väljer du filer för staging med `Space`, och sedan kan du skapa en ny commit med `c`. Du kan se alla tillgängliga kommandon med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) är en vacker resurshanterare som visar användning av minne, CPU, disk och nätverk. Den listar också alla aktiva processer och låter dig hantera dem.

Omarchy kallar den Activity Monitor, och du startar den från appstartaren eller genom att trycka på `Super + Shift + T`. Den öppnas som ett flytande fönster, som du kan göra kaklat med `Super + T`.

## Herdr

[Herdr](https://herdr.dev) är en arbetsytehanterare för terminalen som ger dig arbetsytor, flikar och rutor, och håller dem alla igång i en beständig session som du kan koppla loss från och komma tillbaka till senare.

Du startar den (eller återansluter till din befintliga session) från appstartaren eller med `Super + Ctrl + Return`. Omarchy levereras med en Herdr-konfiguration som speglar dess Tmux-konfiguration, så prefixtangenten är `Ctrl + Space` här också. Du kan bläddra bland alla tangentbindningar med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) visar systeminformation, som kärnversion, uppetid, tema, CPU, minne och mer. Det är en efterföljare till det populära verktyget neofetch.

Omarchy har paketerat detta som _System > About_ i Omarchy-menyn (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) är en retromusikspelare för terminalen inspirerad av Winamp 2.x, komplett med inbyggda radiostationer för lo-fi beats. Starta den med `Super + Shift + Alt + M`, eller från Omarchy-menyn under _Apps_. Tryck på `?` för hela listan över tangentbindningar.

## Vad gäller Wi-Fi och Bluetooth?

Du hittar inga TUI:er för Wi-Fi och Bluetooth — de jobben tillhör Omarchy-skalet. Klicka på Wi-Fi-ikonen i den övre raden (eller tryck på `Super + Ctrl + N`) för att se nätverk och ansluta, och klicka på Bluetooth-ikonen (eller tryck på `Super + Ctrl + B`) för att para ihop och ansluta enheter. Se [nätverk](35-networking.md) för hela berättelsen.

## Lägga till dina egna

Varje terminalprogram kan få hela appbehandlingen. Gå till _Install > TUI_ i Omarchy-menyn (`Super + Space`), ge det ett namn, ett startkommando, en fönsterstil och en ikon, så dyker det upp i appstartaren precis som vilket annat program som helst. Du kan ta bort det igen under _Remove > TUI_.
