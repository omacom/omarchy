# Pluginy shellu

Pracovní prostředí Omarchy běží v jediném procesu Quickshell nazvaném `omarchy-shell`. Téměř vše, co na obrazovce vidíte, tvoří pluginy: horní lišta, její ovládací panely, celoobrazovkové nabídky emoji a schránky, nabídka Omarchy, zamykací obrazovka i dialog polkit. Pluginy jsou i služby bez uživatelského rozhraní, které sledují baterii nebo večer nastavují teplejší barvy obrazovky.

To není jen implementační detail. Znamená to, že můžete části pracovního prostředí vypínat, vyměňovat je nebo psát své vlastní, aniž byste se dotkli jediného řádku zdrojového kódu Omarchy.

Vestavěné pluginy jsou součástí Omarchy a najdete je v adresáři `$OMARCHY_PATH/shell/plugins/`. Vlastní pluginy a pluginy stažené například z GitHubu patří do `~/.config/omarchy/plugins/`. Při spuštění je shell vyhledá stejným způsobem. Vestavěné pluginy mají přístup k důvěryhodným rozhraním shellu; pluginy třetích stran dostávají rozhraní omezené na správu vlastní služby a životního cyklu. Klony vestavěných pluginů si ponechávají jen přístup ke konfiguraci a voláním rozhraní, které potřebují pro své původní chování.

## Seznam pluginů

```
omarchy plugin list
```

Příkaz vypíše všechny nalezené pluginy, jejich ID, stav povolení, původ (vestavěný nebo od třetí strany), druhy a zobrazovaný název. Pokud chcete výstup zpracovat dalším programem, přidejte `--json`.

ID pluginů používají jmenné prostory. Vestavěné pluginy začínají na `omarchy.` — například `omarchy.clock`, `omarchy.network` a `omarchy.notifications`. Tento prostor je vyhrazený a plugin třetí strany ho nemůže použít.

## Zapínání a vypínání

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Nebo použijte nabídku: _Nastavení > Pluginy_ má možnosti Povolit, Zakázat, Přidat, Klonovat a Odebrat, každou s výběrem, který nabízí pouze pluginy, které pro danou akci dávají smysl.

Stav povolení je uložen v souboru `~/.config/omarchy/shell.json` a pravidlo se u dvou druhů pluginů mírně liší. Plugin třetí strany je povolený přesně tehdy, když se jeho id objeví někde v tomto souboru — jako položka rozložení panelu, jako položka v poli `plugins[]` nebo jako `bar.id`. Vestavěné pluginy, které nejsou widgety lišty, to mají obráceně: jsou ve výchozím nastavení zapnuté a vypnou se pouze uvedením v poli `disabledPlugins[]`.

Plnohodnotný plugin panelu nemá vůbec žádný vypnutý stav. Vždy existuje přesně jeden panel, takže ho nahradíte povolením jiného. Umístění widgetů na panelu je popsáno v části [horní lišta](05-the-top-bar.md).

## Přidání pluginu z gitu

Plugin třetí strany je prostě gitový repozitář se souborem `manifest.json` v kořenu.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Než cokoli udělá, rovnou vám řekne, že pluginy běží jako libovolný kód bez sandboxu uvnitř vašeho dlouhodobě běžícího procesu shellu, ukáže vám adresu URL a požádá vás o potvrzení. Berte to vážně. Rozhraní pluginů třetích stran přímo nevystavuje služby ověřování a náhradní panel dostává pouze omezené schopnosti pro nakonfigurované uživatelské rozhraní bez ověřování. Vizuální pluginy stále sdílejí scénu QML shellu a mohou procházet běžné nadřazené objekty, zatímco veškerý kód pluginů běží se vším, na co může dosáhnout váš uživatelský účet. Stav ověřování je chráněn samostatně tím, že se tyto služby udržují mimo dosažitelný graf objektů hostitele. Přidávejte pouze repozitáře, které jste ochotni spustit, a přečtěte si je, než je povolíte.

Náhradní panel může vykreslovat nainstalované widgety, ale widgety třetích stran podporované službami tam mohou mít omezenou funkčnost, protože panel nesmí požadovat živý objekt služby jiného pluginu. Pokud takový widget potřebuje svou doprovodnou službu, přepněte zpět na integrovaný panel `omarchy.bar`.

Poté repozitář naklonuje do přípravného adresáře, ověří manifest, odmítne instalaci, pokud si dané id již nárokuje jiný plugin, a přesune ho do adresáře `~/.config/omarchy/plugins/<id>/`. Bez volby `--enable` se zeptá, zda ho chcete nyní zapnout, a vy můžete říci ne a nejprve si kód přečíst. Při stažení a ověření pluginu se nespouštějí instalační skripty z repozitáře a sudo není potřeba. Povolení přes IPC už spustí jeho kód v shellu.

Aktualizace posune stávající místní kopii repozitáře na novější revizi bez slučování větví (fast-forward):

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bez id aktualizuje každý vámi spravovaný plugin pod gitem. Před použitím rozdílů vám je ukáže, odmítne aktualizovat, pokud místní změny neumožňují aktualizaci bez slučování, a vrátí se zpět, pokud nová revize selže při ověření.

```
omarchy plugin remove acme.weather
```

Odebrání plugin nejprve zakáže, poté ho odstraní, pokud jde o gitový checkout (repozitář je stále upstream), nebo ho odpojí, pokud jde o symbolický odkaz. Ručně vytvořená složka pluginu bez gitového repozitáře se místo okamžitého odstranění přesune do zálohy s časovým razítkem uvnitř adresáře pluginů.

## Úprava vestavěného pluginu pomocí klonu

Toto je moje oblíbená část. Pokud chcete změnit, jak se integrovaný widget chová, neupravujte soubory v adresáři `$OMARCHY_PATH` — patří do balíčku a příští aktualizace je přepíše. Místo toho ho naklonujte:

```
omarchy plugin clone omarchy.clock
```

Tím se celý plugin zkopíruje do adresáře `~/.config/omarchy/plugins/dhh.clock` (vaše uživatelské jméno, ne moje), přejmenuje se na „My Clock“, povolí se a shell se přepne z integrovaného modulu na vaši kopii — při zachování polohy a nastavení stávajícího widgetu na panelu. Přidejte volbu `--edit`, chcete-li nový adresář okamžitě otevřít v editoru určeném proměnnou `$EDITOR`, což pro vás dělá položka nabídky _Nastavení > Pluginy > Klonovat plugin_.

Předpona uživatelského jména zachovává id vašeho klonu jako vaše, takže jeho sdílení nekoliduje s nikým jiným. Volání směřující na původní integrované id se přesměrují na váš klon, takže nic, co odkazovalo na `omarchy.clock`, není třeba aktualizovat. A pokud to pomotáte, příkaz `omarchy plugin remove dhh.clock` vrátí integrovaný modul zpět.

Uložení souboru kamkoli v adresáři `~/.config/omarchy/plugins/` automaticky znovu načte kód pluginu, takže můžete nechat editor otevřený a sledovat, jak vaše změny dopadají.

## Psaní vlastních pluginů

Plugin je adresář se souborem `manifest.json` a trochou QML. Manifest deklaruje `schemaVersion: 1`, `id`, `name`, `version`, jeden nebo více druhů `kinds` a objekt `entryPoints` odkazující na soubor QML pro každý druh:

| Druh | Co to je |
|------|------------|
| `bar-widget` | Komponenta, kterou může aktivní panel vložit do oddílu |
| `panel` | Trvalé nebo vyvolané plovoucí okno |
| `overlay` | Celoobrazovkový překryv |
| `menu` | Vyvolaná plocha nabídky |
| `service` | Jediná sdílená instance služby bez uživatelského rozhraní |
| `bar` | Plnohodnotný panel, který nahrazuje integrovaný panel |

Plugin může deklarovat několik druhů najednou — modul pro média je současně `service` i `bar-widget`. Widgety panelu dostávají navíc blok `barWidget` se zobrazovaným názvem, kategorií, volitelnou položkou `defaultSection` a položkou `allowMultiple`, která říká, zda dává smysl mít na panelu více než jeden. Většina widgetů ji nastavuje na hodnotu `false`; oddělovače a indikátory ji nastavují na hodnotu `true`.

Před zveřejněním plugin zkontrolujte:

```
omarchy plugin validate ./my-plugin
```

Tím se spustí stejné kontroly, které shell provádí při načítání: verzi schématu, povinná pole, id, které není vyhrazené, vstupní body, které jsou bezpečnými relativními cestami a skutečně existují, vstupní bod pro každý druh, který jste si nárokovali, a žádné symbolické odkazy nikde uvnitř složky.

Pro vývoj pluginů se podívejte na [referenci shellu](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) a [katalog vestavěných pluginů](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Sdílení vlastních pluginů

Jakmile vytvoříte něco, co se vám líbí, vložte to do veřejného gitového repozitáře. To je celý distribuční mechanismus — kdokoli pak může spustit příkaz `omarchy plugin add` proti vaší adrese URL a mít ho za pár sekund spuštěný.

Chcete-li lidem pomoci ho skutečně najít, uveďte ho na webu [plugins.omarchy.org](https://plugins.omarchy.org). To je tržiště pro pluginy shellu Omarchy a je to první místo, kam se podívat, když si lámete hlavu nad tím, zda už někdo nevytvořil widget, který se chystáte psát. Před začátkem si ho prohlédněte!
