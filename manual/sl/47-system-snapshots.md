# Posnetki sistema

Samodejno ustvarimo posnetek ob vsaki posodobitvi sistema Omarchy, če pa želite ustvariti svojega, lahko uporabite `omarchy-snapshot create`.

Če želite posnetek zagnati in obnoviti, ga izberete v zagonskem nalagalniku Limine. (Če se trenutno zaganjate neposredno na zaslon za dešifriranje sistema Omarchy, boste morali najprej prek BIOS-a izbrati Limine kot možnost zagona).

Na tem zaslonu izberite posnetek, v katerega se želite zagnati, glede na datum in različico. Različico sistema Omarchy v času posnetka lahko vidite v spodnjem levem kotu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ko pridete noter, se bo pojavilo obvestilo, ki vas bo obvestilo, da ste v zagonskem posnetku, in če ga kliknete, se bo začel postopek obnovitve. Druga možnost je, da uporabite `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

To bo obnovilo vaš korenski datotečni sistem, ne pa tudi vašega `/home`. Deluje torej za razveljavitev pokvarjene posodobitve sistema, ne pa za obnovitev izgubljenih osebnih datotek.

To pomeni tudi, da vaš imenik `~/.config` ostane takšen, kot je. Če se torej vračate na starejšo različico knjižnice ali aplikacije, ki shranjuje konfiguracijske datoteke v novi obliki, boste morali to urediti ročno.

Enako velja za Omarchyjevo evidenco o tem, katere migracije so se že izvedle: živi v vašem domačem imeniku, zato preživi obnovitev. Migracije, ki so se izvedle po tem, ko je bil posnetek narejen, ostanejo označene kot opravljene, čeprav so bile spremembe, ki so jih naredile v korenskem datotečnem sistemu, razveljavljene, in naslednji `omarchy update` jih ne bo znova zagnal. Če torej po obnovitvi znova posodobite in še vedno manjka nekaj, kar je nastavila prejšnja posodobitev, je to verjeten razlog.

_Opomba: Ta funkcija je na voljo samo pri namestitvah, ki uporabljajo zagonski nalagalnik Limine, ki je privzeti od različice Omarchy 2.0. Ni na voljo, če uporabljate GRUB ali systemd-boot._

### Preskakovanje zagonskega menija

Če se zagonskega menija nikoli ne dotaknete in želite le, da gre naprava naravnost na zaslon za dešifriranje, v meniju Omarchy zaženite _Setup > Direct Boot_. To doda vnos EFI, ki kaže neposredno na Omarchy, tako da ga vdelana programska oprema zažene, ne da bi se ustavila pri Limine.

Kompromis je tisti, ki je omenjen na vrhu: ko je neposredni zagon vklopljen, priti do posnetka pomeni, da morate najprej v zagonskem meniju BIOS-a izbrati Limine. Znova zaženite _Setup > Direct Boot_, da odstranite vnos in se vrnete na zagon prek Limine. Nekatera vdelana programska oprema ne sprejema najbolje vnosov EFI po meri, zato se namestitev noče zagnati na vdelani programski opremi American Megatrends in Apple.
