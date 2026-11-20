# Preglednici

Omarchy dolazi s [Google Chrome](https://www.google.com/chrome/) kao zadanim preglednikom. Tematski je usklađen s ostatkom vašeg sustava i to je ono što `Super + Shift + Return` otvara i unutar čega radi svaka [web aplikacija](25-web-apps.md). Otvara se izravno u prozor preglednika: nema zaslona dobrodošlice ni upita za prijavu, statistika korištenja i izvješća o rušenju ne šalju se Googleu, a upiti za privatnost oglasa isključeni su. I dalje se možete prijaviti u svoj Google račun putem gumba profila kad god želite sinkronizaciju.

Ako Chrome nije po vašem ukusu, niste zapeli s njim. Pod _Install > Browser_ u izborniku Omarchy pronaći ćete [Chromium](https://www.chromium.org/) (običnu verziju otvorenog koda od koje je Chrome napravljen), Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/). Odaberite jedan i Omarchy će ga instalirati, postaviti njegov direktorij pravila i primijeniti vašu trenutnu temu na njega.

## Postavljanje jednog kao zadanog

Instaliranje preglednika ne čini ga zadanim. Kad je na računalu, idite na _Setup > Defaults > Browser_ i odaberite ga — izbornik navodi samo preglednike koje ste zapravo instalirali i označava trenutni zadani kvačicom.

S terminala to ide ovako:

```bash
omarchy default browser firefox
```

Pokrenite ga bez argumenta i reći će vam trenutni zadani. Time se postavlja XDG handler, pa to ne prate samo Omarchyjeve tipkovničke prečice — sve što otvara poveznicu, od aplikacije za razgovor do naredbe u terminalu, ide u preglednik koji ste odabrali.

## Copy URL i Download Video

Preglednici iz obitelji Chromium (sam Chromium, Chrome, Edge i Brave) dolaze s dva proširenja Omarchy koja sežu izvan preglednika u ostatak vašeg sustava.

**Copy URL** stavlja adresu trenutne kartice u vaš međuspremnik pomoću `Alt + Shift + L`. To je brže nego kliknuti u adresnu traku i kopirati, a budući da ide kroz međuspremnik sustava, a ne preglednikov, dobivate obavijest Omarchy koja to potvrđuje, a URL je odmah dostupan u [povijesti međuspremnika](08-unified-clipboard-history.md) i svakoj drugoj aplikaciji. Postoji i gumb na alatnoj traci, ako radije klikate.

**Download Video** dohvaća video koji se reproducira na stranici koju gledate pomoću `Alt + Shift + D`. Predaje URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), pa radi na mnogo više od YouTubea, a preuzimanje završava u `~/Videos`. Napredak se prikazuje u istom prikazu na zaslonu koji koriste glasnoća i svjetlina, ažurirajući se na mjestu umjesto da se obavijesti gomilaju. Postavite `OMARCHY_YTDLP_DIR` ako biste radije da datoteke idu negdje drugdje — pogledajte [FAQ](46-faq.md) za mjesto gdje staviti varijable okruženja.

Oba proširenja komuniciraju s Omarchyjem putem malog nativnog hosta za razmjenu poruka, koji se instalira za vas zajedno s preglednikom. To je dio koji omogućuje da video s web-stranice završi u vašem početnom direktoriju, a URL u vašem upravitelju međuspremnika, što obično proširenje samo ne može napraviti.

Ovo je samo za obitelj Chromium. Firefox i Zen ih ne dobivaju.

## Firefox i Zen

Firefox i Zen su druga obitelj, pa dobivaju drugačiji tretman: Omarchy instalira datoteku pravila za razumne zadane postavke i prebacuje ih u nativni Wayland način rada, koji želite za frakcijsko skaliranje i glatko pomicanje dodirnom pločicom.

Ne dobivaju gore navedena proširenja za Chromium i Omarchy ih ne tematizira, pa su ti dijelovi iskustva na vama da ih postavite.

## Ponovno uklanjanje jednog

Bilo koji od ovih preglednika, uključujući Chrome, može se ponovno ukloniti pod _Remove > Browser_. Poveznice tada idu u Chrome ili Chromium ako je drugi još uvijek instaliran.
