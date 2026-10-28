# Uspání systému

Omarchy má ve výchozím nastavení povolené pozastavení i hibernaci, ale pokud s některou z těchto možností máte na svém počítači problémy, můžete je vypnout.

Na počítačích s NVIDIA GB10, jako jsou DGX Spark a ASUS Ascent GX10, jsou pozastavení a hibernace vypnuté, stejně jako v DGX OS od NVIDIA, protože u tohoto hardwaru zatím nebylo prokázáno, že uspání funguje. Přepínač pozastavení ani nastavení hibernace se tam neuplatní. Chcete-li uspání znovu zapnout, odstraňte `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomocí `sudo rm`; Pozastavení se pak vrátí do nabídky a hibernaci lze nastavit stejně jako na ostatních počítačích. Spuštěním `sudo omarchy apply hardware --install-user "$USER"` soubor vrátíte zpět.

### Profily napájení

Na notebooku si Omarchy pamatuje váš profil napájení zvlášť pro napájení ze sítě a pro běh na baterii a přepíná mezi nimi, jak napájení připojujete a odpojujete. Ve výchozím nastavení to znamená výkon při napájení ze sítě a vyvážený režim na baterii.

Co váš počítač nabízí, zjistíte pomocí `omarchy powerprofiles list`, a profil, který chcete pro stav, v němž se právě nacházíte, nastavíte pomocí `omarchy powerprofiles set autodetect power-saver`. Chcete-li nastavit druhý stav, aniž byste cokoli odpojovali, pojmenujte ho přímo: `omarchy powerprofiles set battery power-saver`. Ať vyberete cokoli, přesně to dostanete zpět, až se příště ocitnete v daném stavu.

### Přepnutí pozastavení

Pozastavení přepnete spuštěním `omarchy toggle suspend` z terminálu. Tím se pouze zobrazí/skryje možnost v nabídce _System_ (nebo `Super + Esc`), a pak můžete vyzkoušet, zda na vašem systému funguje spolehlivě. Pokud ne, stejným příkazem ji zase skryjete.

### Přepnutí hibernace

Hibernaci nastavíte spuštěním `omarchy hibernation setup` z terminálu. Hibernace vytvoří na vašem spouštěcím disku podsvazek /swap o velikosti vaší fyzické paměti RAM, takže se ujistěte, že máte dostatek volného místa nazbyt. Na počítači s 32GB pamětí budete pro tento svazek vždy potřebovat 32GB+ volného místa. Hibernace také vyžaduje výchozí zavaděč Limine.

Po nastavení uvidíte možnost hibernace v nabídce _System_ (nebo `Super + Esc`), a pak můžete vyzkoušet, zda na vašem systému funguje spolehlivě. Pokud ne, můžete ji zase odstranit spuštěním `omarchy hibernation remove`.
