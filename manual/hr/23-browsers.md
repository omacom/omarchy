# Preglednici

Omarchy dolazi s [Chromiumom](https://www.chromium.org/) kao zadanim preglednikom. To je obična verzija otvorenog koda, tematizirana da odgovara ostatku tvog sustava, i to je ono što `Super + Shift + Return` otvara i unutar čega radi svaka [web-aplikacija](25-web-apps.md).

Ako Chromium nije po tvom ukusu, nisi zaglavio s njim. Pod _Instaliraj > Browser_ u izborniku Omarchy pronaći ćeš Chrome, Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/). Odaberi jedan i Omarchy ga instalira, postavlja mu direktorij pravila i primjenjuje tvoju trenutnu temu na njega.

## Postavljanje jednog kao zadanog

Instalacija preglednika ga ne promiče. Nakon što je na računalu, idi na _Postavke > Defaults > Browser_ i odaberi ga — izbornik navodi samo preglednike koje zapravo imaš instalirane i označava trenutni zadani kvačicom.

Iz terminala to je:

```bash
omarchy default browser firefox
```

Pokreni ga bez argumenta i reći će ti trenutni zadani. Ovo postavlja XDG handler, pa nije samo Omarchyjev prečaci ti koji slijede — sve što otvori poveznicu, od aplikacije za chat do naredbe u terminalu, ide u preglednik koji si odabrao.

## Kopiranje URL-a i preuzimanje videa

Preglednici iz obitelji Chromium (sam Chromium, Chrome, Edge i Brave) dolaze s dva Omarchy proširenja koja dosežu iz preglednika u ostatak tvog sustava.

**Copy URL** stavlja adresu trenutne kartice u tvoj međuspremnik sa `Alt + Shift + L`. To je brže od klikanja u adresnu traku i kopiranja, a budući da ide kroz međuspremnik sustava, a ne preglednikov, dobivaš Omarchy obavijest koja to potvrđuje i URL je odmah dostupan u [povijesti međuspremnika](08-unified-clipboard-history.md) i svakoj drugoj aplikaciji. Tu je i gumb na alatnoj traci, ako radije klikaš.

**Download Video** preuzima video koji se reproducira na stranici koju gledaš sa `Alt + Shift + D`. Predaje URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), pa radi na mnogo više od YouTubea, a preuzimanje završava u `~/Videos`. Napredak se prikazuje u istom zaslonskom prikazu koji koriste glasnoća i svjetlina, ažurirajući se na mjestu umjesto da slaže obavijesti. Postavi `OMARCHY_YTDLP_DIR` ako želiš da datoteke idu drugamo — pogledaj [ČPP](46-faq.md) za mjesto gdje staviti varijable okruženja.

Oba proširenja komuniciraju s Omarchyjem kroz mali native messaging host, koji se instalira za tebe zajedno s preglednikom. To je dio koji omogućuje da video s web-stranice završi u tvom matičnom direktoriju, a URL u tvom upravitelju međuspremnika, što normalno proširenje ne može učiniti samo.

Ovo je samo za obitelj Chromium. Firefox i Zen ih ne dobivaju.

## Firefox i Zen

Firefox i Zen druga su obitelj, pa dobivaju drugačiji tretman: Omarchy instalira datoteku pravila za razumne zadane postavke i prebacuje ih u nativni Wayland način rada, što želiš za frakcijsko skaliranje i glatko pomicanje dodirnom plohom.

Ne dobivaju gore navedena Chromium proširenja i Omarchy ih ne tematizira, pa su ti dijelovi iskustva na tebi da ih postaviš.

## Ponovno uklanjanje

Sve što si ovdje instalirao možeš ukloniti pod _Ukloni > Browser_. Chromium nije na tom popisu — dio je osnovnog sustava.
