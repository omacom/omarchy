# Bezpečnost

Omarchy bere bezpečnost nesmírně vážně. Má to být operační systém, který můžete používat na _skutečnou práci_ ve _skutečném světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzové situaci. Takže tady je, co děláme:

1. *Šifrování celého disku je ve výchozím nastavení zapnuté*: Je to nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo vám ho ukradnou, data jsou plně zašifrovaná pomocí standardního LUKS (Linux Unified Key Setup). Instalační program vám u strojů na jedno použití umožní to vypnout (viz [Začínáme](02-getting-started.md)); instalace bez šifrování nemá nic z této ochrany a každý, kdo drží disk v ruce, ho může přečíst.
2. *Firewall je ve výchozím nastavení povolený*: Veškerý příchozí provoz je ve výchozím nastavení blokovaný, s několika výjimkami: port 53317 pro [LocalSend](https://localsend.org/); dotazy DNS na vlastní resolver počítače na adrese mostu Dockeru (172.17.0.1), přijímané z rozsahů soukromých adres, které Docker dává svým kontejnerům; a multicast DNS (port 5353), který umožňuje tiskárnám a dalším zařízením ve vaší síti, aby se navzájem našly, a také tam oznamuje název vašeho počítače. Kromě toho firewall zachovává standardní povolení UFW pro ping, získání adresy z vašeho routeru (DHCP) a zjišťování UPnP. Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Setup > Security > SSHD_, což autorizuje váš klíč SSH, vypne přihlašování heslem a teprve pak otevře port 22 (s omezením rychlosti proti útokům hrubou silou). Dokonce i přístup k Dockeru zamykáme pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker), aby vaše kontejnery nebyly náhodou vystavené světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, základní distribuce, na které je Omarchy postavené, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je objevená a opravená v jakémkoli balíčku, je rychle dostupná k instalaci pomocí `omarchy-update`. Tímto způsobem pořád používáte nejnovější, nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky a zrcadlo*: Omarchy se ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib (u strojů ARM z repozitářů Arch Linux ARM, plus Asahi ALARM na Apple Silicon) a na svůj vlastní Omarchy Package Repository. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — pouze několik volitelných instalací, jako prohlížeče třetích stran, čerpá z AUR.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — soubory ISO, balíčky Omarchy, zrcadlo Archu — je chráněná za mohutným štítem Cloudflare proti DDoS a hostovaná na jejich CDN. To poskytuje vynikající dostupnost.

## Změna vašich hesel

Na šifrované instalaci máte dvě hesla: jedno, které odemyká disk při spouštění, a druhé, kterým se přihlašujete a používáte `sudo`. Nastavení je nastaví jako stejná. Obě můžete změnit v nabídce Omarchy pod _Update > Password_ — první pod _Drive Encryption_, druhé pod _User_. Při změně hesla disku budete nejdřív požádáni o to současné, takže ho mějte po ruce. Pokud se změna přeruší, spusťte _Drive Encryption_ znovu: zeptá se na heslo, které disk odemyká právě teď, a změnu dokončí.

## Předání stroje, který jste už používali

Pokud svůj stroj předáváte někomu dalšímu, nemusíte ho přeinstalovávat. V nabídce Omarchy spusťte _Remove > Factory Reset_, pro potvrzení napište `reset`, na vyzvání zadejte heslo šifrování disku a restartujte počítač. Tím se smaže každý uživatelský účet a všechno v `/home`, zahodí se všechny balíčky a systémové změny, které jste od instalace provedli, a vymaže se identita stroje — síťová připojení, klíče hostitele, prostě všechno. Co se znovu spustí, je průvodce nastavením z prvního spuštění, připravený na to, aby jeho nový majitel zadal své vlastní jméno, heslo a heslo šifrování.

Funguje to obnovením výchozího snímku, který instalační program pořídí, takže je to dostupné pouze na strojích nainstalovaných z ISO Omarchy. A na disku bez šifrování je resetování spíš smazání než bezpečné vymazání, takže pokud byla data citlivá, proveďte místo toho čerstvou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat o heslo, nejčastěji když za vás AI agent dělá dlouhý úsek systémové práce. _Setup > Security > Passwordless Sudo_ se zeptá, jak dlouho má být přístup povolený: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Dokud je přístup aktivní, objeví se vedle ostatních indikátorů v pruhu nabídky červená varovná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Můžete také zadat vlastní počet minut (od 1 do 1440) pomocí `omarchy-sudo-passwordless 30`, nebo použít `omarchy-sudo-passwordless permanent`.

Časovaný přístup vyprší automaticky, a to i okamžitě po obnovení ze spánku, který přesáhl termín. Restartování počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává povolený, dokud ho nevypnete.

Aktualizace nebo odebrání balíčku nastavení Omarchy ukončí každé dočasné udělení přístupu předtím, než se změní jeho podpora vypršení. Pokud příkaz nahlásí chybu autorizace nebo čištění, vyřešte ji, než se pokusíte povolit další udělení; chyba neznamená, že přístup bez hesla není aktivní.

Mějte v tomhle jasno: dokud je to zapnuté, cokoli běžící pod vaším uživatelem může jako root dělat cokoli, aniž by se to zeptalo. To je celý smysl, a také celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíčky repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřte na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho také obsahuje a bude použitý k bezproblémovému zavedení případných aktualizací.

Podpis pro jakékoli vydání ISO najdete přidáním `.sig` k jeho URL, například `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
