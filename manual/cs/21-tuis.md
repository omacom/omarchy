# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je rozkošnou alternativou k něčemu, jako je aplikace GitHub Desktop, a běží uvnitř terminálu.

Můžete ho spustit přímo tak, že přejdete do libovolného adresáře spravovaného gitem a spustíte příkaz `lazygit`. Nebo ho můžete spustit uvnitř Neovimu, kde ho lze spustit pomocí `Space G G`.

Mezi různými panely přeskakujete pomocí klávesy `Tab`. V panelu Soubory vyberete soubory ke stagování pomocí klávesy `Space` a poté můžete vytvořit nový commit pomocí klávesy `c`. Všechny dostupné příkazy si můžete prohlédnout pomocí klávesy `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásný správce prostředků, který zobrazuje využití paměti, CPU, disku a sítě. Vypisuje také všechny aktivní procesy a umožňuje je spravovat.

Omarchy ho nazývá Aktivita a spouštíte ho stisknutím `Super + Ctrl + T`. Otevře se jako plovoucí okno, které můžete vedle ostatních uspořádat pomocí `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správce pracovního prostoru terminálu, který vám poskytuje pracovní plochy, karty a panely a udržuje je všechny v běhu v trvalé relaci, od které se můžete odpojit a později se k ní vrátit.

Spustíte ho (nebo se znovu připojíte ke své stávající relaci) pomocí `Super + Ctrl + Return`. Omarchy dodává konfiguraci Herdr, která odráží její konfiguraci Tmuxu, takže prefixová klávesa je i zde `Ctrl + Space`. Všechny klávesové zkratky si můžete prohlédnout pomocí `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informace o systému, například verzi jádra, dobu běhu, motiv, CPU, paměť a další. Je to nástupce oblíbeného nástroje neofetch.

Omarchy toto zabalilo jako _O aplikaci_ do nabídky Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudební přehrávač pro terminál inspirovaný programem Winamp 2.x, včetně integrovaných rozhlasových stanic s lo-fi beaty. Spustíte ho pomocí `Super + Shift + Alt + M` nebo z nabídky Omarchy v části _Aplikace_. Úplný seznam klávesových zkratek zobrazíte stisknutím klávesy `?`.

## A co Wi-Fi a Bluetooth?

Pro Wi-Fi a Bluetooth žádné TUI nenajdete — tyto úkoly patří shellu Omarchy. Kliknutím na ikonu Wi-Fi na horním panelu (nebo stisknutím `Super + Ctrl + W`) zobrazíte sítě a připojíte se a kliknutím na ikonu Bluetooth (nebo stisknutím `Super + Ctrl + B`) spárujete a připojíte zařízení. Celý příběh najdete v části [sítě](35-networking.md).

## Přidání vlastních

Každý terminálový program může získat plnohodnotné zacházení jako aplikace. Přejděte do části _Instalovat > TUI_ v nabídce Omarchy (`Super + Space`), zadejte mu název, příkaz ke spuštění, styl okna a ikonu a objeví se ve spouštěči aplikací jako každá jiná aplikace. Odebrat ho můžete znovu v části _Odebrat > TUI_.
