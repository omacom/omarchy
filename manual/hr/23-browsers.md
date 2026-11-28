# Preglednici

Omarchy dolazi s [Google Chrome](https://www.google.com/chrome/) kao zadanim preglednikom. Tematski je usklađen s ostatkom vašeg sustava i upravo se on otvara preko `Super + Shift + Return` (ili `Super + Shift + B`), uz `Super + Shift + Alt + B` za privatni prozor, a u njemu se izvode i sve [web aplikacije](25-web-apps.md). Otvara se izravno u prozor preglednika: nema zaslona dobrodošlice ni upita za prijavu, statistika upotrebe i izvješća o rušenju ne šalju se Googleu, a upiti za privatnost oglasa isključeni su. I dalje se možete prijaviti u svoj Google račun putem gumba profila kad god želite sinkronizaciju.

Ako vam Chrome nije po ukusu, niste zapeli s njim. Pod _Instaliraj > Preglednik_ u izborniku Omarchy pronaći ćete [Chromium](https://www.chromium.org/) (običnu verziju otvorenog koda od koje je Chrome napravljen), Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/) (Edge samo na x86 računalima). Odaberite jedan i Omarchy će ga instalirati, postaviti njegov direktorij pravila i primijeniti vašu trenutnu temu na njega.

## Postavljanje jednog kao zadanog

Instaliranje preglednika ne čini ga zadanim. Za promjenu idite na _Postavljanje > Zadane postavke > Preglednik_ i odaberite jedan. Trenutni zadani preglednik označen je kvačicom, a odabir preglednika koji još nemate prvo će ga instalirati.

Iz terminala to je:

```bash
omarchy default browser firefox
```

Pokrenite ga bez argumenta i reći će vam koji je trenutni zadani preglednik. Time se postavlja XDG rukovatelj, pa ne prate samo tipkovnički prečaci Omarchyja — sve što otvara poveznicu, od aplikacije za razgovor do naredbe u terminalu, ide u preglednik koji ste odabrali.

## Kopiranje URL-a i preuzimanje videa

Preglednici iz obitelji Chromium (sam Chromium, Chrome, Edge, Brave i Brave Origin) dolaze s tri proširenja Omarchyja: dva koja posežu izvan preglednika u ostatak vašeg sustava i jednim koje sređuje WhatsApp.

**Copy URL** stavlja adresu trenutne kartice u vaš međuspremnik pomoću `Alt + Shift + L`. To je brže od klikanja u adresnu traku i kopiranja, a budući da ide kroz međuspremnik sustava, a ne preglednikov, dobivate obavijest Omarchyja koja to potvrđuje i URL je odmah dostupan u [povijesti međuspremnika](08-unified-clipboard-history.md) i svakoj drugoj aplikaciji. Postoji i gumb na alatnoj traci, ako radije klikate.

**Download Video** preuzima video koji se reproducira na stranici koju gledate pomoću `Alt + Shift + D`. URL predaje [yt-dlp](https://github.com/yt-dlp/yt-dlp), pa radi na mnogo više od samog YouTubea, a preuzimanje završava u `~/Videos`. Napredak se prikazuje u istom prikazu na zaslonu koji koriste glasnoća i svjetlina, ažurirajući se na mjestu umjesto da gomila obavijesti. Postavite `OMARCHY_YTDLP_DIR` ako biste radije da datoteke idu negdje drugdje — pogledajte [FAQ](46-faq.md) za to gdje staviti varijable okruženja.

Oba proširenja komuniciraju s Omarchyjem putem malog izvornog hosta za razmjenu poruka, koji se instalira za vas zajedno s preglednikom. To je dio koji omogućuje da video s web stranice završi u vašem početnom direktoriju, a URL u vašem upravitelju međuspremnika, što obično proširenje samo ne može napraviti.

**WhatsApp Slim** čini da WhatsApp Web slijedi temu vašeg sustava i sažima njegov popis razgovora kada je prozor uzak.

Ovo vrijedi samo za obitelj Chromium. Firefox i Zen ih ne dobivaju.

## Firefox i Zen

Firefox i Zen pripadaju drugoj obitelji, pa dobivaju drugačiji tretman: Omarchy instalira datoteku pravila za razumne zadane postavke i prebacuje ih u izvorni način rada Wayland, što želite za frakcijsko skaliranje i glatko pomicanje trackpadom.

Ne dobivaju gore navedena proširenja za Chromium i Omarchy ih ne tematizira, pa su ti dijelovi iskustva na vama da ih sami postavite.

## Ponovno uklanjanje jednog

Bilo koji od ovih preglednika, uključujući Chrome, može se ponovno ukloniti pod _Ukloni > Preglednik_. Poveznice tada idu u Chrome ili Chromium ako je onaj drugi još uvijek instaliran.
