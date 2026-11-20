# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je příjemná alternativa k aplikacím typu GitHub Desktop a běží přímo v terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného systémem git a spustíte `lazygit`. Nebo ho můžete spustit uvnitř Neovim, kde ho otevřete pomocí `Space G G`.

Mezi jednotlivými panely přeskakujete pomocí `Tab`. V panelu Files vybíráte soubory pro staging pomocí `Space` a poté můžete vytvořit nový commit pomocí `c`. Všechny dostupné příkazy zobrazíte pomocí `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který ukazuje využití paměti, CPU, disku a sítě. Také vypisuje všechny aktivní procesy a umožňuje je spravovat.

Omarchy mu říká Activity Monitor a spustíte ho ze spouštěče aplikací nebo stisknutím `Super + Shift + T`. Otevře se jako plovoucí okno, které můžete převést na dlaždici pomocí `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správce pracovních prostorů pro terminál, který vám nabízí pracovní prostory, karty a panely a udržuje je všechny spuštěné v trvalé relaci, od které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své stávající relaci) ze spouštěče aplikací nebo pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která odpovídá jeho konfiguraci Tmux, takže i zde je prefixová klávesa `Ctrl + Space`. Všechny klávesové zkratky si můžete prohlédnout pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) ukazuje informace o systému, například verzi jádra, dobu běhu, motiv, CPU, paměť a další. Je to nástupce populárního nástroje neofetch.

Omarchy to zabalilo jako _Systém > O aplikaci_ v nabídce Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudební přehrávač pro terminál inspirovaný Winamp 2.x, včetně vestavěných rozhlasových stanic s lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy v části _Aplikace_. Stisknutím `?` zobrazíte úplný seznam klávesových zkratek.

## A co Wi-Fi a Bluetooth?

Pro Wi-Fi a Bluetooth žádné TUIs nenajdete — tyto úkoly patří shellu Omarchy. Kliknutím na ikonu Wi-Fi v horní liště (nebo stisknutím `Super + Ctrl + N`) zobrazíte sítě a připojíte se k nim a kliknutím na ikonu Bluetooth (nebo stisknutím `Super + Ctrl + B`) spárujete a připojíte zařízení. Celý příběh najdete v části [sítě](35-networking.md).

## Přidávání vlastních

Plného zacházení jako s aplikací se může dostat každému terminálovému programu. V nabídce Omarchy (`Super + Space`) přejděte do _Instalovat > TUI_, zadejte název, příkaz pro spuštění, styl okna a ikonu a program se objeví ve spouštěči aplikací jako každá jiná aplikace. Znovu ho můžete odebrat v části _Odebrat > TUI_.
