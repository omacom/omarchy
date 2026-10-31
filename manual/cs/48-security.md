# Zabezpečení

Omarchy bere zabezpečení nesmírně vážně. Má to být operační systém, který můžete používat na _Skutečnou Práci_ ve _Skutečném Světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Takže tady je, co děláme:

1. *Šifrování celého disku je povinné*: Toto je nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo vám ho ukradnou, data jsou plně zašifrovaná pomocí standardního LUKS (Linux Unified Key Setup).
2. *Firewall je ve výchozím nastavení zapnutý*: Veškerý příchozí provoz je ve výchozím nastavení blokován kromě portu 53317 pro [LocalSend](https://localsend.org/). Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Nastavení > Zabezpečení > SSHD_, což v rámci nastavení otevře port 22 (s omezením rychlosti proti útokům hrubou silou). Dokonce i přístup k Dockeru zamykáme pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker), aby vaše kontejnery nebyly omylem vystaveny světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, základní distro, na kterém je Omarchy postavené, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je objevena a opravena v kterémkoli balíčku, je rychle k dispozici k instalaci pomocí `omarchy-update`. Tímto způsobem vždy používáte nejnovější, nejbezpečnější verze všeho.
4. *Omarchy udržuje vlastní balíčky a zrcadlo*: Omarchy ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib a ze svého vlastního Omarchy Package Repository. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — pouze několik volitelných instalací, jako prohlížeče třetích stran, čerpá z AUR.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — ISO obrazy, balíčky Omarchy, zrcadlo Archu — je chráněna za mohutným štítem Cloudflare proti DDoS a hostovaná na jejich CDN. To poskytuje vynikající dostupnost.

## Změna hesel

Na zašifrované instalaci máte dvě hesla: jedno, které při startu odemyká disk, a druhé, kterým se přihlašujete a používáte `sudo`. Nastavení je nastaví jako stejná. Obě lze změnit v nabídce Omarchy pod _Aktualizace > Heslo_ — _Šifrování disku_ pro první, _Uživatel_ pro druhé. Změna hesla disku se nejdřív zeptá na to současné, takže ho mějte po ruce. Pokud je změna přerušena, spusťte _Šifrování disku_ znovu: zeptá se na heslo, které disk odemyká nyní, a změnu dokončí.

## Předání počítače, který jste už používali

Pokud počítač předáváte někomu jinému, nemusíte ho přeinstalovávat. V nabídce Omarchy spusťte _Nastavení > Resetovat počítač_, pro potvrzení napište `reset` a restartujte. Tím se smaže každý uživatelský účet a vše v `/home`, zahodí se všechny balíčky a systémové změny, které jste od instalace provedli, a vymaže se identita počítače — síťová připojení, hostitelské klíče, prostě všechno. Co naběhne zpět, je průvodce nastavením z prvního spuštění, připravený, aby jeho nový majitel zadal své vlastní jméno, heslo a šifrovací heslo.

Funguje to obnovením základního snímku, který instalátor pořídí, takže je to dostupné pouze na počítačích nainstalovaných z ISO Omarchy. A na disku bez šifrování je reset smazáním, nikoli bezpečným vymazáním, takže pokud byla data citlivá, proveďte místo toho čerstvou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat o heslo, nejčastěji když za vás AI agent dělá dlouhý úsek systémové práce. _Nastavení > Zabezpečení > Sudo bez hesla_ se zeptá, jak dlouho má být přístup povolen: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Zatímco je přístup aktivní, vedle ostatních indikátorů v pruhu nabídky se objeví červená varovná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Pomocí `omarchy-sudo-passwordless 30` můžete také zadat vlastní počet minut (od 1 do 1440), nebo použít `omarchy-sudo-passwordless permanent`.

Časovaný přístup automaticky vyprší, a to i ihned po probuzení z režimu spánku, který překročil termín. Restartování počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává zapnutý, dokud ho nevypnete.

Aktualizace nebo odebrání balíčku s nastaveními Omarchy ukončí jakékoli dočasné povolení dříve, než se změní podpora jeho vypršení. Pokud příkaz nahlásí chybu autorizace nebo čištění, vyřešte ji, než se pokusíte povolit další povolení; chyba neznamená, že přístup bez hesla není aktivní.

U tohoto mějte oči otevřené: zatímco je to zapnuté, cokoli běžící pod vaším uživatelem může bez dotazování dělat cokoli jako root. To je celý smysl, a také celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíčky repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřit na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho obsahuje také a bude použit k bezproblémovému zavedení případných aktualizací.

Podpis pro kterékoli vydání ISO najdete přidáním `.sig` k jeho URL, například `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
