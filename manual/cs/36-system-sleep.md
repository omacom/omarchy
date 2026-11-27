# Spánek systému

Omarchy ve výchozím nastavení umožňuje uspání a hibernaci, jakmile je nastavená, ale pokud vám na vašem počítači jedno z toho dělá problémy, můžete je vypnout.

Na počítačích s NVIDIA GB10, jako jsou DGX Spark a ASUS Ascent GX10, jsou uspání a hibernace vypnuté, stejně jako v DGX OS od NVIDIA, protože u tohoto hardwaru zatím nebylo prokázáno, že spánek funguje. Přepínač uspání ani nastavení hibernace se tam neuplatní. Pokud chcete spánek znovu zapnout, odstraňte `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomocí `sudo rm`; Suspend se pak vrátí do nabídky a hibernaci půjde nastavit stejně jako na jiných počítačích. Spuštěním `sudo omarchy apply hardware --install-user "$USER"` soubor vrátíte zpět.

### Profily napájení

Na notebooku si Omarchy pamatuje profil napájení zvlášť pro napájení ze sítě a provoz na baterii a přepíná mezi nimi podle toho, zda napájení připojíte, nebo odpojíte. Ve výchozím nastavení to znamená výkon při napájení ze sítě a vyvážený režim na baterii.

Co váš počítač nabízí, zjistíte pomocí `omarchy powerprofiles list` a požadovaný profil pro stav, ve kterém se právě nacházíte, nastavíte pomocí `omarchy powerprofiles set autodetect power-saver`. Pokud chcete nastavit druhý stav, aniž byste cokoliv odpojovali, pojmenujte ho přímo: `omarchy powerprofiles set battery power-saver`. Cokoliv si vyberete, dostanete příště ve stejném stavu zase zpět.

### Přepnutí uspání

Uspání přepnete spuštěním `omarchy toggle suspend` z terminálu. Tím jen zobrazíte/skryjete možnost v nabídce _System_ (nebo `Super + Esc`), a pak můžete zjistit, jestli na vašem systému funguje spolehlivě. Pokud ne, můžete ji stejným příkazem zase skrýt.

### Přepnutí hibernace

Hibernaci nastavíte spuštěním `omarchy hibernation setup` z terminálu (na počítačích Apple Silicon Mac není k dispozici). Hibernace vytvoří na spouštěcí jednotce podsvazek /swap o velikosti vaší fyzické paměti RAM, takže si ověřte, že máte dost volného místa. Na počítači s 32GB pamětí budete pro tento svazek vždy potřebovat více než 32GB volného místa. Hibernace také vyžaduje výchozí zavaděč Limine.

Po nastavení uvidíte možnost hibernace v nabídce _System_ (nebo `Super + Esc`) a pak můžete zjistit, jestli na vašem systému funguje spolehlivě. Pokud ne, můžete ji znovu odstranit spuštěním `omarchy hibernation remove`.
