# Sistemski posnetki

Posnetke ustvarimo samodejno ob vsaki posodobitvi sistema Omarchy, če pa želite ustvariti svojega, lahko uporabite `omarchy-snapshot create`.

Kako zaženete in obnovite posnetek, je odvisno od zagonskega nalagalnika, s katerim se zažene vaš računalnik. Nove namestitve UEFI uporabljajo systemd-boot; starejše namestitve in računalniki z BIOS uporabljajo Limine. `omarchy-boot-backend` vam pove, katerega imate.

## S systemd-boot

V meniju Omarchy izberite _Sistem > Posnetki_ in izberite posnetek, v katerega se želite zagnati. Računalnik se enkrat znova zažene vanj. Ali pa med zagonom računalnika držite Space, da prikažete zagonski meni, v katerem je vsak posnetek naveden od najnovejšega do najstarejšega, s svojo različico sistema Omarchy in datumom.

Posnetek se zažene z začasno plastjo na vrhu, zato ga lahko uporabljate kot običajno, vendar bo vse, kar spremenite, ob naslednjem ponovnem zagonu izginilo. Če ga želite obdržati, ga naredite za svoj sistem: kliknite obvestilo, ki se prikaže ob prijavi, izberite _Sistem > Posnetki > Obnovi ta posnetek_ ali zaženite `omarchy-snapshot restore`. Obnovitev se izvede med ponovnim zagonom računalnika. Sistem, kakršen je bil prej, ostane v zagonskem meniju kot _Pred obnovitvijo_, `omarchy-snapshot restore backup` pa ga vrne nazaj.

V terminalu:

- `omarchy-snapshot list` navede posnetke, v katere se lahko zaženete;
- `omarchy-snapshot boot 12` se enkrat znova zažene v posnetek 12;
- `omarchy-snapshot restore 12` ob naslednjem ponovnem zagonu naredi posnetek 12 za sistem, `omarchy-snapshot restore --cancel` pa pred tem ponovnim zagonom spremeni vašo odločitev.

## Z Limine

Če želite zagnati in obnoviti posnetek, ga izberete v zagonskem nalagalniku Limine. Zagonski meni je privzeto skrit, zato takoj, ko se Limine zažene, pritisnite katero koli tipko, da ga prikažete.

S tega zaslona izberite posnetek, v katerega se želite zagnati, glede na datum in različico. Različico sistema Omarchy ob času nastanka posnetka lahko vidite v spodnjem levem kotu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ko pridete noter, se bo pojavilo obvestilo, ki vas obvešča, da ste v zagonskem posnetku, in če ga kliknete, se bo začel postopek obnovitve. Druga možnost je, da uporabite `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Kaj zajema obnovitev

Obnovitev vrne vaš korenski datotečni sistem, ne pa tudi vašega `/home`. Zato deluje za razveljavitev pokvarjene posodobitve sistema, ne pa za obnovitev izgubljenih osebnih datotek.

To pomeni tudi, da vaša mapa `~/.config` ostane takšna, kot je. Če se torej vračate na starejšo različico knjižnice ali aplikacije, ki shranjuje konfiguracijske datoteke v novi obliki, boste morali to urediti ročno.

Enako velja za Omarchyjevo lastno evidenco o tem, katere migracije so že bile izvedene: živi v vaši domači mapi, zato preživi obnovitev. Migracije, ki so bile izvedene po nastanku posnetka, ostanejo označene kot opravljene, čeprav so spremembe, ki so jih naredile v korenskem datotečnem sistemu, razveljavljene, in naslednja `omarchy update` jih ne bo znova izvedla. Če torej po obnovitvi znova posodobite in nekaj, kar je nastavila prejšnja posodobitev, še vedno manjka, je to verjeten razlog.
