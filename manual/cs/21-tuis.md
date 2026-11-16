# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je skvělou alternativou k něčemu jako je aplikace GitHub Desktop a běží uvnitř terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného gitem a spustíte `lazygit`. Nebo ho můžete spustit uvnitř Neovim, kde ho lze spustit pomocí `Space G G`.

Mezi jednotlivými podokny přeskakujete pomocí `Tab`. V podokně Files vybíráte soubory k zařazení do stage pomocí `Space` a poté můžete vytvořit nový commit pomocí `c`. Všechny dostupné příkazy zobrazíte pomocí `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který zobrazuje využití paměti, CPU, disku a sítě. Také vypisuje všechny aktivní procesy a umožňuje vám je spravovat.

Omarchy ho označuje jako Activity Monitor a spustíte ho ze spouštěče aplikací nebo stisknutím `Super + Shift + T`. Otevře se jako plovoucí okno, které můžete přepnout do dlaždicového režimu pomocí `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správce terminálových pracovních prostorů, který vám poskytuje pracovní prostory, karty a podokna a všechny je udržuje spuštěné v trvalé relaci, od které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své stávající relaci) ze spouštěče aplikací nebo pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která kopíruje jeho konfiguraci Tmux, takže prefixová klávesa je zde také `Ctrl + Space`. Všechny klávesové zkratky si můžete prohlédnout pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informace o systému, jako je verze jádra, doba provozu, téma, CPU, paměť a další. Je nástupcem oblíbeného nástroje neofetch.

Omarchy ho zabalilo jako _About_ v nabídce Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro terminálový hudební přehrávač inspirovaný Winamp 2.x, včetně vestavěných rozhlasových stanic pro lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy v části _Apps_. Stisknutím `?` zobrazíte úplný seznam klávesových zkratek.

## A co Wi-Fi a Bluetooth?

TUIs pro Wi-Fi a Bluetooth nenajdete — tyto úkoly patří shellu Omarchy. Klikněte na ikonu Wi-Fi v horní liště (nebo stiskněte `Super + Ctrl + N`), chcete-li zobrazit sítě a připojit se, a klikněte na ikonu Bluetooth (nebo stiskněte `Super + Ctrl + B`) pro spárování a připojení zařízení. Celý příběh najdete v části [síťování](35-networking.md).

## Přidání vlastních

Plného zacházení jako s aplikací se může dostat libovolnému terminálovému programu. Přejděte do _Install > TUI_ v nabídce Omarchy (`Super + Space`), dejte mu název, příkaz pro spuštění, styl okna a ikonu a objeví se ve spouštěči aplikací jako každá jiná aplikace. Znovu ho můžete odebrat v části _Remove > TUI_.
