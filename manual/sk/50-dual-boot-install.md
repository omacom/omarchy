# Inštalácia dual boot

Môžete nainštalovať Omarchy na jednu partíciu popri Windowse alebo iných inštaláciách.

Táto metóda inštalácie stále predvolene ponúka šifrovanie LUKS pre partíciu, takže sa v podstate nelíši od inštalácie na celý disk a jednoducho vyžaduje, aby bolo na disku k dispozícii voľné miesto.

## Uvoľnenie miesta vo Windowse

Ak chcete inštalovať popri Windowse, zadajte do ponuky Štart `disk management` a vyberte možnosť **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Nájdite príslušnú partíciu, kliknite na ňu pravým tlačidlom myši a vyberte **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadajte veľkosť, o ktorú chcete zmenšiť zväzok. Upozorňujeme, že to bude veľkosť vašej budúcej inštalácie Omarchy vrátane zavádzacej partície.

 ![dual-boot-3](images/dual-boot-3.webp)

Keď skončíte, mali by ste vidieť niečo takéto, kde 50GB časť je miesto, kam v tomto príklade nainštalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Inštalácia Omarchy

Proces inštalácie Omarchy je v podstate rovnaký ako zvyčajne. Po výbere disku dostanete možnosť **Free space install**. Vyberte túto možnosť, aby ste zabránili vymazaniu celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrďte, že všetko vyzerá dobre, a počkajte na dokončenie inštalácie ako zvyčajne. Tu si tiež môžete zvoliť inštaláciu bez šifrovania (neodporúča sa), rovnako ako pri inštalácii na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pridanie ďalších inštalácií do zavádzača

Po dokončení inštalácie Omarchy si všimnete, že zavádzač Limine je teraz predvolený. Pomocou neho môžete do Limine pridať aj možnosti pre vaše ďalšie inštalácie, napríklad Windows.

Ak chcete pridať ďalšie operačné systémy, spustite `limine-scan` a podľa pokynov pridajte požadované položky do svojej konfigurácie Limine. Ponuka zavádzania zostáva predvolene skrytá a po jednej sekunde spustí Omarchy. Ak chcete vybrať Windows alebo inú položku, stlačte ľubovoľnú klávesu hneď, ako sa Limine spustí; keď sa zobrazí ponuka, pomocou klávesov so šípkami vyberte položku a stlačte Enter. Ak sa Omarchy spustí skôr, ako stlačíte klávesu, reštartujte počítač a skúste to znova.

## Bitlocker

Je dôležité poznamenať, že táto metóda inštalácie nie je kompatibilná s Bitlockerom, pretože šifruje celý disk, nielen partíciu. Ak sa zobrazí chyba, že je Bitlocker povolený, spustite Windows, prejdite na **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypnite. Dešifrovanie disku môže chvíľu trvať.

 ![dual-boot-7](images/dual-boot-7.webp)
