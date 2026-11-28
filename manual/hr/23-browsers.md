# Preglednici

Omarchy dolazi s preglednikom [Google Chrome](https://www.google.com/chrome/) kao zadanim preglednikom. Tematski je usklađen s ostatkom vašeg sustava i to je ono što otvara `Super + Shift + Return` (ili `Super + Shift + B`), uz `Super + Shift + Alt + B` za privatni prozor, i ono unutar čega se pokreće svaka [web-aplikacija](25-web-apps.md). Otvara se izravno u prozor preglednika: nema zaslona dobrodošlice ni upita za prijavu, statistika korištenja i izvješća o rušenju ne šalju se Googleu, a upiti za privatnost oglasa isključeni su. I dalje se možete prijaviti u svoj Google račun putem gumba profila kad god poželite sinkronizaciju.

Ako Chrome nije po vašem ukusu, niste zapeli s njime. Pod _Instaliraj > Preglednik_ u izborniku Omarchy pronaći ćete [Chromium](https://www.chromium.org/) (običnu verziju otvorenog koda od koje je napravljen Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) i [Ladybird](https://ladybird.org/) (Edge samo na x86 računalima). Odaberite jedan i Omarchy će ga instalirati, postaviti njegov direktorij pravila i primijeniti na njega vašu trenutnu temu.

## Postavljanje jednog kao zadanog

Instaliranje preglednika ne promiče ga u zadani. Za promjenu idite na _Postavljanje > Zadane postavke > Preglednik_ i odaberite jedan. Trenutni zadani označen je kvačicom, a odabir preglednika koji još nemate prvo će ga instalirati.

Iz terminala to je:

```bash
omarchy default browser firefox
```

Pokrenite ga bez argumenta i reći će vam koji je trenutni zadani. Time se postavlja XDG rukovatelj, pa to ne prate samo tipkovnički prečaci Omarchyja — sve što otvara poveznicu, od aplikacije za razgovor do naredbe u terminalu, ide u preglednik koji ste odabrali.

## Copy URL i Download Video

Preglednici iz obitelji Chromium (sam Chromium, Chrome, Edge, Brave i Brave Origin) dolaze s tri proširenja Omarchyja: dvama koja sežu izvan preglednika u ostatak vašeg sustava i jednim koje sređuje WhatsApp.

**Copy URL** stavlja adresu trenutne kartice u vaš međuspremnik pomoću `Alt + Shift + L`. To je brže od klikanja u adresnu traku i kopiranja, a budući da ide kroz međuspremnik sustava, a ne preglednikov, dobivate obavijest Omarchyja koja to potvrđuje i URL je odmah dostupan u [povijesti međuspremnika](08-unified-clipboard-history.md) i svakoj drugoj aplikaciji. Postoji i gumb na alatnoj traci, ako radije klikate.

**Download Video** preuzima videozapis koji se reproducira na stranici koju gledate pomoću `Alt + Shift + D`. Predaje URL alatu [yt-dlp](https://github.com/yt-dlp/yt-dlp), pa radi na puno više toga od YouTubea, a preuzimanje završava u `~/Videos`. Napredak se prikazuje na istom zaslonskom prikazu koji koriste glasnoća i svjetlina, ažurirajući se na mjestu umjesto da gomila obavijesti. Postavite `OMARCHY_YTDLP_DIR` ako želite da datoteke idu negdje drugdje — pogledajte [Česta pitanja](46-faq.md) za to gdje staviti varijable okruženja.

Oba proširenja komuniciraju s Omarchyjem putem malog izvornog domaćina za razmjenu poruka, koji se instalira za vas zajedno s preglednikom. To je dio koji omogućuje da videozapis s web-stranice završi u vašem početnom direktoriju, a URL u vašem upravitelju međuspremnika, što obično proširenje ne može samo.

**WhatsApp Slim** čini da WhatsApp Web slijedi vašu temu sustava i sažima svoj popis razgovora kad je prozor uzak.

Ovo je samo za obitelj Chromium. Firefox i Zen ne dobivaju ih.

## Firefox i Zen

Firefox i Zen druga su obitelj, pa dobivaju drugačiji tretman: Omarchy instalira datoteku pravila za razumne zadane postavke i prebacuje ih u izvorni način rada Wayland, što želite za djelomično skaliranje i glatko pomicanje na dodirnoj ploči.

Ne dobivaju gornja proširenja za Chromium i Omarchy ih ne tematizira, pa su ti dijelovi iskustva na vama da ih postavite.

## Ladybird

Ladybird je preglednik napisan od nule, s vlastitim pogonom, a ne Chromiumovim ili Firefoxovim. Još je u alfi, pa očekujte web-mjesta koja još ne rade, a Omarchy ga instalira kakav jest: bez proširenja, bez teme, bez pravila. Nema ni privatni prozor, pa ga `Super + Shift + Alt + B` otvara s privremenim profilom koji se briše kad ga zatvorite. [Web-aplikacije](25-web-apps.md) i dalje se pokreću u Chromeu ili Chromiumu.

## Ponovno uklanjanje jednog

Bilo koji od ovih preglednika, uključujući Chrome, može se ponovno ukloniti pod _Ukloni > Preglednik_. Poveznice tada idu u Chrome ili Chromium ako je drugi još uvijek instaliran.
