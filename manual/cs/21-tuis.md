# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je skvělá alternativa k něčemu, jako je aplikace GitHub Desktop, a běží uvnitř terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného gitem a spustíte `lazygit`. Nebo ho můžete spustit uvnitř Neovimu, kde ho lze spustit pomocí `Space G G`.

Mezi různými panely přeskakujete pomocí `Tab`. V panelu Files vybíráte soubory pro staging pomocí `Space` a poté můžete vytvořit nový commit pomocí `c`. Všechny dostupné příkazy uvidíte pomocí `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který zobrazuje využití paměti, CPU, disku a sítě. Také vypisuje všechny aktivní procesy a umožňuje vám je spravovat.

Omarchy ho nazývá Activity Monitor a spustíte ho ze spouštěče aplikací nebo stisknutím `Super + Shift + T`. Otevře se jako plovoucí okno, které můžete převést do dlaždicového režimu pomocí `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správce pracovních prostorů pro terminál, který vám dává pracovní prostory, karty a panely a všechny je udržuje spuštěné v trvalé relaci, od které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své existující relaci) pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která zrcadlí jeho konfiguraci Tmux, takže klávesa prefixu je zde také `Ctrl + Space`. Všechny klávesové zkratky si můžete prohlédnout pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informace o systému, jako je verze jádra, doba provozu, téma, CPU, paměť a další. Je nástupcem oblíbeného nástroje neofetch.

Omarchy to zabalila jako _About_ do nabídky Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudební přehrávač pro terminál inspirovaný Winamp 2.x, kompletně včetně vestavěných rozhlasových stanic pro lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy v části _Apps_. Stisknutím `?` zobrazíte úplný seznam klávesových zkratek.

## A co Wi-Fi a Bluetooth?

TUIs pro Wi-Fi a Bluetooth nenajdete — tyto úlohy patří shellu Omarchy. Klikněte na ikonu Wi-Fi v horní liště (nebo stiskněte `Super + Ctrl + N`), abyste viděli sítě a mohli se připojit, a klikněte na ikonu Bluetooth (nebo stiskněte `Super + Ctrl + B`) pro spárování a připojení zařízení. Celý příběh najdete v části [sítě](35-networking.md).

## Přidání vlastních

Libovolný terminálový program může dostat plné zacházení jako aplikace. Přejděte do _Install > TUI_ v nabídce Omarchy (`Super + Space`), zadejte mu název, příkaz pro spuštění, styl okna a ikonu a objeví se ve spouštěči aplikací jako každá jiná aplikace. Znovu ho můžete odebrat v části _Remove > TUI_.
