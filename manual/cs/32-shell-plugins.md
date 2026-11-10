# Zásuvné moduly shellu

Pracovní prostředí Omarchy běží jako jeden dlouhodobě běžící proces Quickshell nazývaný `omarchy-shell` a téměř vše, co vidíte na obrazovce, je zásuvný modul uvnitř něj. Panel je zásuvný modul. Stejně tak panely, které z něj sjíždějí dolů, celoobrazovkové překryvy, jako je výběr emoji a správce schránky, samotná nabídka Omarchy, zamykací obrazovka, dialog polkit a bezhlavové služby, které hlídají vaši baterii a v noci vaši obrazovku ohřívají.

To není jen implementační detail. Znamená to, že můžete části pracovního prostředí vypínat, vyměňovat je nebo psát své vlastní, aniž byste se dotkli jediného řádku zdrojového kódu Omarchy.

Zásuvné moduly první strany jsou dodávány s Omarchy a žijí v adresáři `$OMARCHY_PATH/shell/plugins/`. Cokoli, co sami přidáte — vlastní experimenty, nebo něco, co jste našli na GitHubu — žije v adresáři `~/.config/omarchy/plugins/`. Oboje se při spuštění zjišťuje stejným způsobem, ale integrované zásuvné moduly dostávají důvěryhodná rozhraní shellu, zatímco zásuvné moduly třetích stran dostávají omezené rozhraní vymezené pro jejich vlastní službu a životní cyklus. Klonům integrovaných modulů zůstává pouze konfigurace specifická pro zdroj a volání uživatelského rozhraní potřebná pro původní chování.

## Zobrazení toho, co máte

```
omarchy plugin list
```

Tím se vytiskne každý objevený zásuvný modul s jeho id, zda je povolený, zda je od první strany nebo třetí strany, jeho druhy a jeho zobrazovaný název. Přidejte volbu `--json`, pokud tím krmíte něco jiného.

Id zásuvných modulů jsou v jmenném prostoru. Integrované všechny začínají řetězcem `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — a tento jmenný prostor je vyhrazený, takže si ho zásuvný modul třetí strany nemůže nikdy nárokovat.

## Zapínání a vypínání

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Nebo použijte nabídku: _Nastavení > Zásuvné moduly_ má možnosti Povolit, Zakázat, Přidat, Klonovat a Odebrat, každou s výběrem, který nabízí pouze zásuvné moduly, které pro danou akci dávají smysl.

Stav povolení je uložen v souboru `~/.config/omarchy/shell.json` a pravidlo se u dvou druhů zásuvných modulů mírně liší. Zásuvný modul třetí strany je povolený přesně tehdy, když se jeho id objeví někde v tomto souboru — jako položka rozložení panelu, jako položka v poli `plugins[]` nebo jako `bar.id`. Zásuvné moduly první strany, které nejsou widgety panelu, to mají obráceně: jsou ve výchozím nastavení zapnuté a vypnou se pouze uvedením v poli `disabledPlugins[]`.

Plnohodnotný zásuvný modul panelu nemá vůbec žádný vypnutý stav. Vždy existuje přesně jeden panel, takže ho nahradíte povolením jiného. Umístění widgetů na panelu je popsáno v části [horní panel](05-the-top-bar.md).

## Přidání zásuvného modulu z gitu

Zásuvný modul třetí strany je prostě gitový repozitář se souborem `manifest.json` v kořenu.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Než cokoli udělá, rovnou vám řekne, že zásuvné moduly běží jako libovolný kód bez sandboxu uvnitř vašeho dlouhodobě běžícího procesu shellu, ukáže vám adresu URL a požádá vás o potvrzení. Berte to vážně. Rozhraní zásuvných modulů třetích stran přímo nevystavuje služby ověřování a náhradní panel dostává pouze omezené schopnosti pro nakonfigurované uživatelské rozhraní bez ověřování. Vizuální zásuvné moduly stále sdílejí scénu QML shellu a mohou procházet běžné nadřazené objekty, zatímco veškerý kód zásuvných modulů běží se vším, na co může dosáhnout váš uživatelský účet. Stav ověřování je chráněn samostatně tím, že se tyto služby udržují mimo dosažitelný graf objektů hostitele. Přidávejte pouze repozitáře, které jste ochotni spustit, a přečtěte si je, než je povolíte.

Náhradní panel může vykreslovat nainstalované widgety, ale widgety třetích stran podporované službami tam mohou mít omezenou funkčnost, protože panel nesmí požadovat živý objekt služby jiného zásuvného modulu. Pokud takový widget potřebuje svou doprovodnou službu, přepněte zpět na integrovaný panel `omarchy.bar`.

Poté repozitář naklonuje do přípravného adresáře, ověří manifest, odmítne instalaci, pokud si dané id již nárokuje jiný zásuvný modul, a přesune ho do adresáře `~/.config/omarchy/plugins/<id>/`. Bez volby `--enable` se zeptá, zda ho chcete nyní zapnout, a vy můžete říci ne a nejprve si kód přečíst. Zásuvný modul nikdy nespustí nic, nikdy nespustí instalační háček a nikdy nežádá sudo — naklonuje soubory, zkontroluje manifest a přes IPC přepne jeden bit.

Aktualizace je rychlé dopředné stažení téhož checkoutu:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bez id aktualizuje každý vámi spravovaný zásuvný modul pod gitem. Před použitím rozdílů vám je ukáže, odmítne aktualizovat, pokud máte místní změny, přes které se nedokáže rychle posunout vpřed, a vrátí se zpět, pokud nová revize selže při ověření.

```
omarchy plugin remove acme.weather
```

Odebrání zásuvný modul nejprve zakáže, poté ho odstraní, pokud jde o gitový checkout (repozitář je stále upstream), nebo ho odpojí, pokud jde o symbolický odkaz. Ručně vytvořená složka zásuvného modulu bez gitového repozitáře se místo okamžitého odstranění přesune do zálohy s časovým razítkem uvnitř adresáře zásuvných modulů.

## Klonování integrovaného modulu za účelem jeho úpravy

Toto je moje oblíbená část. Pokud chcete změnit, jak se integrovaný widget chová, neupravujte soubory v adresáři `$OMARCHY_PATH` — patří do balíčku a příští aktualizace je přepíše. Místo toho ho naklonujte:

```
omarchy plugin clone omarchy.clock
```

Tím se celý zásuvný modul zkopíruje do adresáře `~/.config/omarchy/plugins/dhh.clock` (vaše uživatelské jméno, ne moje), přejmenuje se na „My Clock“, povolí se a shell se přepne z integrovaného modulu na vaši kopii — při zachování polohy a nastavení stávajícího widgetu na panelu. Přidejte volbu `--edit`, chcete-li nový adresář okamžitě otevřít ve své proměnné `$EDITOR`, což pro vás dělá položka nabídky _Nastavení > Zásuvné moduly > Klonovat zásuvný modul_.

Předpona uživatelského jména zachovává id vašeho klonu jako vaše, takže jeho sdílení nekoliduje s nikým jiným. Volání směřující na původní integrované id se přesměrují na váš klon, takže nic, co odkazovalo na `omarchy.clock`, není třeba aktualizovat. A pokud to pomotáte, příkaz `omarchy plugin remove dhh.clock` vrátí integrovaný modul zpět.

Uložení souboru kamkoli v adresáři `~/.config/omarchy/plugins/` automaticky znovu načte kód zásuvného modulu, takže můžete nechat editor otevřený a sledovat, jak vaše změny dopadají.

## Psaní vlastních modulů

Zásuvný modul je adresář se souborem `manifest.json` a trochou QML. Manifest deklaruje `schemaVersion: 1`, `id`, `name`, `version`, jeden nebo více druhů `kinds` a objekt `entryPoints` odkazující na soubor QML pro každý druh:

| Kind | Co to je |
|------|------------|
| `bar-widget` | Komponenta, kterou může aktivní panel vložit do oddílu |
| `panel` | Trvalé nebo vyvolané plovoucí okno |
| `overlay` | Celoobrazovkový překryv |
| `menu` | Vyvolaná plocha nabídky |
| `service` | Bezhlavý singleton bez uživatelského rozhraní |
| `bar` | Plnohodnotný panel, který nahrazuje integrovaný panel |

Zásuvný modul může deklarovat několik druhů najednou — modul pro média je současně `service` i `bar-widget`. Widgety panelu dostávají navíc blok `barWidget` se zobrazovaným názvem, kategorií, volitelnou položkou `defaultSection` a položkou `allowMultiple`, která říká, zda dává smysl mít na panelu více než jeden. Většina widgetů ji nastavuje na hodnotu `false`; oddělovače a indikátory ji nastavují na hodnotu `true`.

Před publikováním cokoli zkontrolujte:

```
omarchy plugin validate ./my-plugin
```

Tím se spustí stejné kontroly, které shell provádí při načítání: verzi schématu, povinná pole, id, které není vyhrazené, vstupní body, které jsou bezpečnými relativními cestami a skutečně existují, vstupní bod pro každý druh, který jste si nárokovali, a žádné symbolické odkazy nikde uvnitř složky.

Pro vývoj zásuvných modulů se podívejte na [referenci shellu](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) a [katalog zásuvných modulů první strany](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Sdílení vašich modulů se světem

Jakmile vytvoříte něco, co se vám líbí, vložte to do veřejného gitového repozitáře. To je celý distribuční mechanismus — kdokoli pak může spustit příkaz `omarchy plugin add` proti vaší adrese URL a mít ho za pár sekund spuštěný.

Chcete-li lidem pomoci ho skutečně najít, uveďte ho na webu [plugins.omarchy.org](https://plugins.omarchy.org). To je tržiště pro zásuvné moduly shellu Omarchy a je to první místo, kam se podívat, když si lámete hlavu nad tím, zda už někdo nevytvořil widget, který se chystáte psát. Před začátkem si ho prohlédněte!
