# Brskalniki

Omarchy kot privzeti brskalnik dobavlja [Chromium](https://www.chromium.org/). Gre za navadno odprtokodno zgradbo, tematsko usklajeno s preostalim sistemom, in je tista, ki jo odpre `Super + Shift + Return` in v kateri teče vsaka [spletna aplikacija](25-web-apps.md).

Če Chromium ni po vašem okusu, niste obtičali z njim. Pod _Namesti > Brskalnik_ v meniju Omarchy boste našli Chrome, Edge, Brave, Brave Origin, Firefox in [Zen](https://zen-browser.app/). Izberite enega in Omarchy ga namesti, nastavi njegovo mapo za pravilnike in nanj uporabi vašo trenutno temo.

## Nastavitev enega kot privzetega

Namestitev brskalnika ga ne povzdigne. Ko je v računalniku, pojdite v _Nastavitve > Privzeto > Brskalnik_ in ga izberite — meni navede le brskalnike, ki jih dejansko imate nameščene, in trenutnega privzetega označi s kljukico.

Iz terminala gre tako:

```bash
omarchy default browser firefox
```

Zaženite brez argumenta in povedal bo trenutnega privzetega. To nastavi rokovalnik XDG, tako da mu ne sledijo le bližnjice Omarchy — vse, kar odpre povezavo, od aplikacije za klepet do terminalskega ukaza, gre v brskalnik, ki ste ga izbrali.

## Kopiranje URL-ja in prenos videa

Brskalniki iz družine Chromium (sam Chromium, Chrome, Edge in Brave) prinašajo dve razširitvi Omarchy, ki segata iz brskalnika v preostanek vašega sistema.

**Copy URL** postavi naslov trenutnega zavihka v vaše odložišče z `Alt + Shift + L`. To je hitreje kot klikati v naslovno vrstico in kopirati, ker gre prek sistemskega odložišča in ne brskalnikovega, pa dobite obvestilo Omarchy, ki to potrdi, URL pa je takoj na voljo v [zgodovini odložišča](08-unified-clipboard-history.md) in vsaki drugi aplikaciji. Obstaja tudi gumb v orodni vrstici, če raje klikate.

**Download Video** zgrabi video, ki se predvaja na strani, ki si jo ogledujete, z `Alt + Shift + D`. URL preda programu [yt-dlp](https://github.com/yt-dlp/yt-dlp), zato deluje na mnogo več kot YouTubu, prenos pa pristane v `~/Videos`. Napredek se prikaže v istem zaslonskem prikazu, ki ga uporabljata glasnost in svetlost, in se posodablja na mestu, namesto da bi kopičeval obvestila. Nastavite `OMARCHY_YTDLP_DIR`, če želite, da datoteke gredo drugam — za mesto okoljskih spremenljivk glejte [Pogosta vprašanja](46-faq.md).

Obe razširitvi se z Omarchy pogovarjata prek majhnega izvornega gostitelja sporočil, ki se namesti skupaj z brskalnikom. To omogoča, da video s spletne strani konča v vaši domači mapi in URL v vašem upravitelju odložišča, česar običajna razširitev sama ne zmore.

Ti sta le za družino Chromium. Firefox in Zen ju ne dobita.

## Firefox in Zen

Firefox in Zen sta iz druge družine, zato imata drugačno obravnavo: Omarchy namesti datoteko pravilnikov za smiselne privzete vrednosti in ju preklopi v izvorni način Wayland, ki ga želite za delno povečevanje in gladko drsenje s sledilno ploščico.

Ne dobita zgoraj omenjenih razširitev Chromium in ju Omarchy ne obarva tematsko, tako da sta ta dela izkušnje za nastaviti vama.

## Ponovna odstranitev

Vse, kar ste namestili tukaj, lahko odstranite pod _Odstrani > Brskalnik_. Chromiuma ni na tem seznamu — je del osnovnega sistema.
