# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je příjemná alternativa k aplikacím, jako je GitHub Desktop, a běží přímo v terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného gitem a spustíte `lazygit`. Nebo ho můžete spustit uvnitř Neovimu, kde ho otevřete pomocí `Space G G`.

Mezi jednotlivými panely přeskakujete pomocí `Tab`. V panelu Files vybíráte soubory ke stagingu pomocí `Space` a poté můžete vytvořit nový commit pomocí `c`. Všechny dostupné příkazy si zobrazíte pomocí `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který zobrazuje využití paměti, CPU, disku a sítě. Zobrazuje také všechny aktivní procesy a umožňuje je spravovat.

Omarchy ho označuje jako Activity Monitor a spustíte ho ze spouštěče aplikací nebo stisknutím `Super + Shift + T`. Otevře se jako plovoucí okno, které můžete převést na dlaždici pomocí `Super + T`.

## Herdr

[Herdr](https://herdr.dev) je terminálový správce pracovních prostorů, který vám poskytuje pracovní prostory, karty a panely a udržuje je všechny spuštěné v trvalé relaci, ze které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své existující relaci) ze spouštěče aplikací nebo pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která odráží jeho konfiguraci Tmux, takže prefixové tlačítko je zde také `Ctrl + Space`. Všechny klávesové zkratky si můžete prohlédnout pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informace o systému, jako je verze jádra, doba provozu, motiv, CPU, paměť a další. Je nástupcem oblíbeného nástroje neofetch.

Omarchy ho zařadila jako _System > About_ v nabídce Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro terminálový hudební přehrávač inspirovaný Winampem 2.x, včetně vestavěných rozhlasových stanic s lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy v části _Apps_. Stisknutím `?` zobrazíte úplný seznam klávesových zkratek.

## A co Wi-Fi a Bluetooth?

Pro Wi-Fi a Bluetooth TUIs nenajdete — tyto úkoly patří do shellu Omarchy. Kliknutím na ikonu Wi-Fi v horní liště (nebo stisknutím `Super + Ctrl + N`) zobrazíte sítě a připojíte se k nim a kliknutím na ikonu Bluetooth (nebo stisknutím `Super + Ctrl + B`) spárujete a připojíte zařízení. Celý příběh najdete v části [sítě](35-networking.md).

## Přidání vlastních

Plnohodnotné zacházení jako s aplikací může získat jakýkoli terminálový program. Přejděte do _Install > TUI_ v nabídce Omarchy (`Super + Space`), zadejte název, spouštěcí příkaz, styl okna a ikonu a program se objeví ve spouštěči aplikací jako každá jiná aplikace. Znovu ho můžete odstranit v části _Remove > TUI_.
