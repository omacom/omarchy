# TUI:er

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) är ett utmärkt alternativ till något som GitHub Desktop-applikationen, och det körs inne i terminalen.

Du kan köra det direkt genom att gå till valfri katalog som hanteras av git och köra `lazygit`. Eller så kan du köra det inne i Neovim där det kan startas med `Space G G`.

Du hoppar mellan de olika panelerna med `Tab`. I panelen Files väljer du filer för staging med `Space`, och sedan kan du skapa en ny commit med `c`. Du kan se alla tillgängliga kommandon med `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) är en vacker resurshanterare som visar minnes-, CPU-, disk- och nätverksanvändning. Den listar också alla aktiva processer och låter dig hantera dem.

Omarchy kallar det Activity, och du startar det med `Super + Ctrl + T`. Det öppnas som ett flytande fönster, som du kan kakla med `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) är en terminalarbetsytehanterare som ger dig arbetsytor, flikar och paneler, och håller dem alla igång i en bestående session som du kan koppla bort från och komma tillbaka till senare.

Du startar det (eller återansluter till din befintliga session) med `Super + Ctrl + Return`. Omarchy levererar en Herdr-konfiguration som speglar dess Tmux-config, så prefixtangenten är `Ctrl + Space` här också. Du kan bläddra bland alla tangentbindningar med `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) visar systeminformation som kernelversion, uptime, tema, CPU, minne och mer. Det är en efterföljare till det populära neofetch-verktyget.

Omarchy har paketerat det som _Om_ i Omarchy-menyn (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) är en retro terminalmusikspelare inspirerad av Winamp 2.x, komplett med inbyggda radiostationer för lo-fi beats. Starta den med `Super + Shift + Alt + M`, eller från Omarchy-menyn under _Apps_. Tryck `?` för den fullständiga tangentbindningslistan.

## Vad sägs om Wi-Fi och Bluetooth?

Du hittar inga TUI:er för Wi-Fi och Bluetooth — de uppgifterna tillhör Omarchy-skalet. Klicka på Wi-Fi-ikonen i det övre fältet (eller tryck `Super + Ctrl + W`) för att se nätverk och ansluta, och klicka på Bluetooth-ikonen (eller tryck `Super + Ctrl + B`) för att parkoppla och ansluta enheter. Se [nätverk](35-networking.md) för hela berättelsen.

## Lägg till dina egna

Vilket terminalprogram som helst kan få full app-behandling. Gå till _Installera > TUI_ i Omarchy-menyn (`Super + Space`), ge det ett namn, ett startkommando, en fönsterstil och en ikon, så dyker det upp i app-launchern som vilken annan applikation som helst. Du kan ta bort det igen under _Ta bort > TUI_.
