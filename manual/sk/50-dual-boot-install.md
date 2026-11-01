# Inštalácia Dual Boot

Omarchy môžete nainštalovať na jeden oddiel popri Windows alebo iných inštaláciách.

Táto metóda inštalácie stále predvolene zahŕňa šifrovanie oddielu pomocou LUKS, takže sa prakticky nelíši od inštalácie na celý disk a jednoducho vyžaduje, aby bolo na disku k dispozícii voľné miesto.

## Uvoľnenie miesta vo Windows

Ak chcete inštalovať popri Windows, napíšte do ponuky Štart `disk management` a vyberte možnosť **Vytvoriť a formátovať oddiely pevného disku**.

 ![dual-boot-1](images/dual-boot-1.webp)

Nájdite príslušný oddiel, kliknite naň pravým tlačidlom myši a vyberte možnosť **Zmenšiť zväzok**.

![dual-boot-2](images/dual-boot-2.webp)

 Zadajte veľkosť, o ktorú chcete zväzok zmenšiť. Upozorňujeme, že to bude veľkosť vašej budúcej inštalácie Omarchy vrátane zavádzacieho oddielu.

 ![dual-boot-3](images/dual-boot-3.webp)

Keď skončíte, mali by ste vidieť niečo takéto, kde 50GB časť je tá, kam v tomto príklade nainštalujeme Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Inštalácia Omarchy

Proces inštalácie Omarchy je prakticky rovnaký ako zvyčajne. Po výbere disku dostanete možnosť **Inštalácia do voľného miesta**. Vyberte túto možnosť, aby ste zabránili vymazaniu celého disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Skontrolujte, či všetko vyzerá dobre, a počkajte, kým sa inštalácia dokončí ako zvyčajne. Tu sa tiež môžete rozhodnúť pre inštaláciu bez šifrovania (neodporúča sa), rovnako ako pri inštalácii na celý disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Pridanie ďalších inštalácií do zavádzača

Po dokončení inštalácie Omarchy si všimnete, že zavádzač Limine je teraz predvolený. Pomocou neho môžete do Limine pridať aj možnosti pre vaše ďalšie inštalácie, ako je napríklad Windows.

Ak chcete pridať ďalšie operačné systémy, spustite `limine-scan` a podľa pokynov pridajte požadované položky do konfigurácie Limine. Ponuka zavádzania zostáva predvolene skrytá a Omarchy sa spustí po jednej sekunde. Ak chcete vybrať Windows alebo inú položku, stlačte ľubovoľnú klávesu hneď, ako sa Limine spustí; keď sa zobrazí ponuka, pomocou klávesov so šípkami vyberte položku a stlačte Enter. Ak sa Omarchy spustí skôr, ako stihnete stlačiť klávesu, reštartujte počítač a skúste to znova. Ak ste zapli _Setup > Direct Boot_, firmvér Limine úplne preskočí, takže vyberte Limine z ponuky zavádzania BIOS alebo znova spustite _Setup > Direct Boot_ a položku odstráňte.

## Bitlocker

Je dôležité poznamenať, že táto metóda inštalácie nie je kompatibilná s nástrojom Bitlocker, pretože ten šifruje celý disk, nie iba oddiel. Ak sa zobrazí chyba oznamujúca, že je povolený Bitlocker, spustite Windows, prejdite do časti **Nastavenia -> Súkromie a zabezpečenie -> Šifrovanie zariadenia** a vypnite Bitlocker. Dešifrovanie disku môže chvíľu trvať.

 ![dual-boot-7](images/dual-boot-7.webp)
