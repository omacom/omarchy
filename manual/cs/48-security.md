# Zabezpečení

Omarchy bere zabezpečení extrémně vážně. Má to být operační systém, který můžete používat na _Skutečnou práci_ ve _Skutečném světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Takže tady je, co děláme:

1. *Šifrování celého disku je ve výchozím nastavení zapnuté*: To je nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo vám ho ukradnou, data jsou plně zašifrována pomocí standardního LUKS (Linux Unified Key Setup). Instalátor vám umožňuje tuto možnost vypnout u strojů na jedno použití (viz [Začínáme](02-getting-started.md)); instalace bez šifrování nemá žádnou z této ochrany a kdokoli, kdo drží disk, si ho může přečíst.
2. *Firewall je ve výchozím nastavení povolený*: Veškerý příchozí provoz je ve výchozím nastavení blokován, s několika výjimkami: port 53317 pro [LocalSend](https://localsend.org/); dotazy DNS na vlastní resolver počítače na adrese mostu Dockeru (172.17.0.1), přijímané z privátních rozsahů adres, které Docker dává svým kontejnerům; a multicast DNS (port 5353), který umožňuje tiskárnám a dalším zařízením ve vaší síti, aby se navzájem našly, a také tam oznamuje jméno vašeho počítače. Kromě toho firewall zachovává standardní povolení UFW pro ping, získání adresy z vašeho routeru (DHCP) a zjišťování UPnP. Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Nastavení > Zabezpečení > SSHD_, což jako součást nastavení otevře port 22 (s omezením rychlosti proti útokům hrubou silou). Dokonce i přístup k Dockeru zamykáme pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker), aby vaše kontejnery nebyly omylem vystaveny světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, základní distribuce, na které je Omarchy postavené, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je objevena a opravena v jakémkoli balíčku, je rychle k dispozici k instalaci pomocí `omarchy-update`. Tímto způsobem vždy používáte nejnovější, nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky a zrcadlo*: Omarchy se ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Arch core/extra/multilib a ze svého vlastního repozitáře balíčků Omarchy Package Repository. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — pouze několik volitelných instalací, jako jsou prohlížeče třetích stran, čerpá z AUR.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — ISO obrazy, balíčky Omarchy, zrcadlo Arch — je chráněna za impozantním DDoS štítem Cloudflare a hostována na jejich CDN. To poskytuje vynikající dostupnost.

## Změna vašich hesel

U zašifrované instalace máte dvě hesla: jedno, které odemyká disk při spouštění, a druhé, kterým se přihlašujete a používáte `sudo`. Nastavení je nastaví jako stejná. Obě lze změnit v nabídce Omarchy pod _Aktualizace > Heslo_ — _Šifrování disku_ pro první, _Uživatel_ pro druhé. Změna hesla disku nejprve vyžaduje to aktuální, takže ho mějte po ruce. Pokud je změna přerušena, spusťte znovu _Šifrování disku_: zeptá se na heslo, které disk odemyká nyní, a změnu dokončí.

## Předání stroje, který jste už používali

Pokud předáváte svůj stroj někomu jinému, nemusíte ho přeinstalovat. Spusťte v nabídce Omarchy _Odebrat > Obnovení do továrního nastavení_, pro potvrzení napište `reset` a restartujte. Tím se smaže každý uživatelský účet a vše v `/home`, zahodí se všechny balíčky a systémové změny provedené od instalace a vymaže se identita stroje — síťová připojení, klíče hostitele, prostě všechno. Po restartu se objeví průvodce nastavením z prvního spuštění, připravený pro nového majitele, aby zadal své vlastní jméno, heslo a šifrovací heslo.

Funguje to tak, že obnoví výchozí snímek, který instalátor pořídí, takže je to k dispozici pouze na strojích nainstalovaných z ISO Omarchy. A na disku bez šifrování je obnovení spíše smazáním než bezpečným vymazáním, takže pokud byla data citlivá, proveďte místo toho čistou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat o heslo, nejčastěji když za vás AI agent provádí dlouhý úsek systémové práce. _Nastavení > Zabezpečení > Sudo bez hesla_ se zeptá, na jak dlouho přístup povolit: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Dokud je přístup aktivní, objeví se vedle ostatních indikátorů na liště nabídek červená varovná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Můžete také předat vlastní počet minut (od 1 do 1440) pomocí `omarchy-sudo-passwordless 30`, nebo použít `omarchy-sudo-passwordless permanent`.

Časově omezený přístup automaticky vyprší, včetně okamžitě po probuzení z režimu spánku, během kterého uplynula lhůta. Restartování počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává povolený, dokud ho nevypnete.

Aktualizace nebo odebrání balíčku nastavení Omarchy ukončí každé dočasné udělení přístupu před změnou podpory jeho vypršení. Pokud příkaz nahlásí chybu autorizace nebo vyčištění, vyřešte ji, než se pokusíte povolit další udělení; chyba neznamená, že přístup bez hesla je neaktivní.

U téhle funkce mějte oči otevřené: dokud je zapnutá, cokoli běžící pod vaším uživatelem může jako root dělat cokoli, aniž by se ptalo. To je celý její smysl, a zároveň celé její riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíčky repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřit na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho obsahuje také a bude použit k bezproblémovému zavedení případných aktualizací.

Podpis pro jakékoli vydání ISO najdete přidáním `.sig` k jeho URL, například `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
