# Sistemski posnetki

Posnetke samodejno ustvarimo ob vsaki posodobitvi Omarchy, če pa želite ustvariti svojega, lahko uporabite `omarchy-snapshot create`.

Če želite zagnati in obnoviti posnetek, ga izberete v zagonskem nalagalniku Limine. Zagonski meni je privzeto skrit, zato takoj, ko se Limine zažene, pritisnite katero koli tipko, da ga prikažete.

Na tem zaslonu izberite posnetek, ki ga želite zagnati, glede na datum in različico. Različico Omarchy v času posnetka lahko vidite v spodnjem levem kotu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ko se sistem zažene, se prikaže obvestilo, da ste v zagonskem posnetku, in če ga kliknete, se začne postopek obnovitve. Lahko pa uporabite tudi `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

To bo obnovilo vaš korenski datotečni sistem, ne pa vašega `/home`. Deluje torej za razveljavitev pokvarjene sistemske posodobitve, ne pa za obnovitev izgubljenih osebnih datotek.

To pomeni tudi, da vaš imenik `~/.config` ostane takšen, kot je. Če se torej vračate na starejšo različico knjižnice ali aplikacije, ki shranjuje konfiguracijske datoteke v novi obliki zapisa, boste morali to urediti ročno.

Isto velja za Omarchyjev lastni zapis o tem, katere migracije so že bile izvedene: živi v vašem domačem imeniku, zato preživi obnovitev. Migracije, ki so bile izvedene po zajemu posnetka, ostanejo označene kot končane, čeprav so bile spremembe, ki so jih naredile v korenskem datotečnem sistemu, razveljavljene, in jih naslednji `omarchy update` ne bo znova zagnal. Če torej po obnovitvi znova posodobite in nekaj, kar je nastavila prejšnja posodobitev, še vedno manjka, je to verjetni razlog.

_Opomba: Ta funkcija je na voljo samo v namestitvah, ki uporabljajo zagonski nalagalnik Limine, ki je privzeti od Omarchy 2.0. Ni na voljo, če uporabljate GRUB ali systemd-boot._
