# Inštalácia v režime dual boot

Omarchy môžete nainštalovať na jeden oddiel popri Windowse alebo iných inštaláciách.

Táto metóda inštalácie stále predvolene zahŕňa šifrovanie oddielu pomocou LUKS, takže sa v podstate nelíši od inštalácie na celý disk a jednoducho vyžaduje, aby bolo na disku k dispozícii voľné miesto.

## Uvoľnenie miesta vo Windowse

Ak chcete inštalovať popri Windowse, zadajte do ponuky Štart `disk management` a vyberte možnosť **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Nájdite príslušný oddiel, kliknite naň pravým tlačidlom myši a vyberte možnosť **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadajte veľkosť, o ktorú chcete zväzok zmenšiť. Upozorňujeme, že to bude veľkosť vašej budúcej inštalácie Omarchy vrátane zavádzacieho oddielu.

 ![dual-boot-3](images/dual-boot-3.webp)

Keď budete hotoví, mali by ste vidieť niečo podobné, kde 50GB časť je v tomto príklade miestom, kam nainštalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Inštalácia Omarchy

Proces inštalácie Omarchy je v podstate rovnaký ako zvyčajne. Po výbere disku dostanete možnosť **Free space install**. Vyberte túto možnosť, aby ste zabránili vymazaniu celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Skontrolujte, či všetko vyzerá dobre, a počkajte, kým sa inštalácia dokončí ako zvyčajne. Tu sa tiež môžete rozhodnúť pre inštaláciu bez šifrovania (neodporúča sa), rovnako ako pri inštalácii na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pridanie ďalších inštalácií do zavádzača

Po dokončení inštalácie Omarchy si všimnete, že zavádzač Limine je teraz predvolený. Pomocou neho môžete do Limine pridať aj možnosti pre svoje ďalšie inštalácie, napríklad Windows.

Ak chcete pridať ďalšie operačné systémy, spustite `limine-scan` a podľa pokynov pridajte požadované položky do svojej konfigurácie Limine. Ponuka zavádzania zostáva predvolene skrytá a Omarchy sa spustí po jednej sekunde. Ak chcete vybrať Windows alebo inú položku, stlačte ľubovoľnú klávesu hneď, ako sa Limine spustí; keď sa zobrazí ponuka, pomocou klávesov so šípkami vyberte položku a stlačte Enter. Ak sa Omarchy spustí skôr, než stihnete stlačiť klávesu, reštartujte počítač a skúste to znova.

## Bitlocker

Je dôležité poznamenať, že táto metóda inštalácie nie je kompatibilná s nástrojom Bitlocker, pretože ten šifruje celý disk, nielen oddiel. Ak narazíte na chybu oznamujúcu, že je Bitlocker povolený, spustite Windows, prejdite do časti **Settings -> Privacy & Security -> Device encryption** a Bitlocker vypnite. Dešifrovanie disku môže chvíľu trvať.

 ![dual-boot-7](images/dual-boot-7.webp)

## Opätovná inštalácia Windowsu

Ak bol tento počítač dodaný s Windowsom, jeho produktový kľúč je uložený vo firmvéri. Spustite `omarchy windows key`, aby sa zobrazil, takže si budete môcť Windows znova aktivovať, ak ho niekedy na tomto počítači preinštalujete.
