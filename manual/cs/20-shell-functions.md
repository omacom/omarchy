# Funkce shellu

Omarchy je dodávána se sadou funkcí shellu, které zjednodušují běžné úkoly a zapouzdřují složitá volání parametrů.

## Komprese

- `compress [file/dir]`: Vytvoří archiv tar.gz ze souboru/adresáře.
- `decompress [file.tar.gz]`: Rozbalí soubor tar.gz.

## Jednotky

- `iso2sd [image.iso]`: Vytvoří spouštěcí jednotku na SD kartě s použitím odkazovaného souboru iso a interaktivním výběrem jednotky.
- `format-drive [device] [name]`: Naformátuje celý disk jako jeden oddíl exFAT (který funguje i ve Windows a macOS). Spuštěním bez argumentů zobrazíte dostupné jednotky. Buďte opatrní!

## Rozvržení pro vývoj

Okamžitá rozvržení pro vývoj ve více panelech pro tmux:

- `tdl [ai]`: Vytvoří vývojové rozvržení Tmux s vaším editorem, agentem umělé inteligence a terminálem. Použijte aliasy agentů, například `tdl c` pro opencode nebo `tdl cx` pro Claude Code, nebo předejte druhého agenta, který spustí oba, například `tdl c cx`.
- `tds`: Vytvoří vývojový čtverec Tmux s editorem, sledováním rozdílů (prostřednictvím příkazu `hunk diff --watch`), terminálem a opencode.
- `tdlm [ai]`: Vytvoří okno `tdl` pro každý podadresář v aktuálním adresáři.
- `tsl [count] [command]`: Vytvoří roj panelů uspořádaných do mřížky, všechny spouštějí stejný příkaz (skvělé pro agenty umělé inteligence).

Stejná rozvržení jsou k dispozici i pro Herdr jako `hdl`, `hds`, `hdlm` a `hsl`.

## Pracovní stromy Gitu

- `ga [branch]`: Vytvoří nový pracovní strom a větev vedle aktuálního repozitáře a přesune se do něj.
- `gd`: Odebere aktuální pracovní strom a jeho větev (nejprve si vyžádá potvrzení).

## Sledovače Rsync

- `rsw [source] [destination]`: Spustí sledovač na pozadí, který synchronizuje zdroj s cílem pomocí rsync, kdykoli se cokoli změní. Cílem může být vzdálený hostitel, například `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Vypíše všechny aktivní sledovače.
- `dsw`: Zastaví všechny aktivní sledovače.

## Přesměrování portů SSH

Ideální pro vývoj webu s oprávněními zabezpečeného kontextu localhostu proti vzdálenému počítači.

- `fip`: Přesměruje jeden nebo více portů ze vzdáleného hostitele na localhost prostřednictvím SSH.
- `dip`: Odpojí jeden nebo více přesměrovaných portů.
- `lip`: Vypíše všechna aktivní přesměrování portů SSH.

Řekněme, že spustíte vývojový server na portu `3000` na počítači přístupném jako `nyc-dev`, poté můžete spustit příkaz `fip nyc-dev 3000`, který tento port přesměruje, takže `localhost:3000` ve skutečnosti dosáhne na `nyc-dev:3000`, ale bez potřeby certifikátů SSL k vytvoření zabezpečeného kontextu potřebného například pro testování webových soketů a podobně.

## Opětovné připojení SSH

Samotný příkaz `ssh` je zabalen do funkce, která vyčistí terminál, pokud připojení zanikne, zatímco si ho nárokuje vzdálený tmux, Herdr nebo editor, a poté se automaticky znovu připojí, když interaktivní relace spadne (Ctrl-C zastaví smyčku opakovaných pokusů).
