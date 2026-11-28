# Brskalniki

Omarchy je privzeto opremljen z brskalnikom [Google Chrome](https://www.google.com/chrome/). Njegova tema je usklajena s preostalim sistemom in odpre se z `Super + Shift + Return` (ali `Super + Shift + B`), z `Super + Shift + Alt + B` za zasebno okno, v njem pa se izvajajo tudi vse [spletne aplikacije](25-web-apps.md). Odpre se neposredno v okno brskalnika: ni pozdravnega zaslona ali poziva k prijavi, statistika uporabe in poročila o zrušitvah se ne pošiljajo Googlu, pozivi glede zasebnosti oglasov pa so izklopljeni. Še vedno se lahko kadar koli prijavite v svoj Google račun s profilnim gumbom, če želite sinhronizacijo.

Če Chrome ni po vašem okusu, niste obsojeni nanj. Pod _Namesti > Brskalnik_ v meniju Omarchy boste našli [Chromium](https://www.chromium.org/) (navadna odprtokodna različica, iz katere je izdelan Chrome), Edge, Brave, Brave Origin, Firefox in [Zen](https://zen-browser.app/) (Edge samo na računalnikih x86). Izberite enega in Omarchy ga bo namestil, zanj nastavil imenik pravilnikov in nanj uporabil vašo trenutno temo.

## Nastavitev privzetega brskalnika

Namestitev brskalnika ga še ne nastavi za privzetega. Če ga želite zamenjati, pojdite v _Nastavitve > Privzeto > Brskalnik_ in enega izberite. Trenutni privzeti brskalnik je označen s kljukico, izbira brskalnika, ki ga še nimate, pa ga najprej namesti.

Iz terminala je ukaz:

```bash
omarchy default browser firefox
```

Zaženite ga brez argumenta in povedal vam bo, kateri je trenutno privzeti. S tem nastavite obdelovalnik XDG, zato se mu ne prilagodijo le bližnjice v Omarchyju — vse, kar odpre povezavo, od aplikacije za klepet do ukaza v terminalu, bo šlo v brskalnik po vaši izbiri.

## Kopiranje URL-ja in prenos videa

Brskalniki iz družine Chromium (sam Chromium, Chrome, Edge, Brave in Brave Origin) dobijo tri razširitve za Omarchy: dve segata iz brskalnika v preostali del vašega sistema, ena pa pospravi WhatsApp.

**Copy URL** z `Alt + Shift + L` postavi naslov trenutnega zavihka v vaše odložišče. To je hitreje kot klikanje v naslovno vrstico in kopiranje, in ker gre skozi sistemsko odložišče in ne skozi brskalnikovo, prejmete potrditveno obvestilo Omarchyja, URL pa je takoj na voljo v [zgodovini odložišča](08-unified-clipboard-history.md) in vseh drugih aplikacijah. Obstaja tudi gumb v orodni vrstici, če raje klikate.

**Download Video** z `Alt + Shift + D` zgrabi videoposnetek, ki se predvaja na strani, ki jo gledate. URL preda programu [yt-dlp](https://github.com/yt-dlp/yt-dlp), zato deluje na precej več kot le YouTubu, prenos pa pristane v `~/Videos`. Napredek se prikaže v istem zaslonskem prikazu, ki ga uporabljata glasnost in svetlost, in se posodablja na mestu, namesto da bi kopiči obvestila. Nastavite `OMARCHY_YTDLP_DIR`, če želite, da datoteke namesto tja gredo kam drugam — v [pogostih vprašanjih](46-faq.md) preverite, kam postaviti okoljske spremenljivke.

Obe razširitvi komunicirata z Omarchyjem prek majhnega izvornog gostitelja za sporočanje, ki se namesti skupaj z brskalnikom. Prav ta del omogoča, da videoposnetek s spletne strani konča v vašem domačem imeniku, URL pa v vašem upravitelju odložišča, česar običajna razširitev sama ne more narediti.

**WhatsApp Slim** poskrbi, da WhatsApp Web sledi vaši sistemski temi, in strne seznam klepetov, ko je okno ozko.

Te so samo za družino Chromium. Firefox in Zen jih ne dobita.

## Firefox in Zen

Firefox in Zen sta iz druge družine, zato sta deležna drugačne obravnave: Omarchy namesti datoteko s pravilniki za smiselne privzete nastavitve in ju preklopi v izvorni način Wayland, ki ga želite za delno skaliranje in gladko drsenje s sledilno ploščico.

Zgoraj navedenih razširitev za Chromium ne dobita in Omarchy zanju ne uporabi teme, zato so ti deli izkušnje prepuščeni vaši nastavitvi.

## Ponovna odstranitev brskalnika

Vsakega od teh brskalnikov, vključno s Chromom, lahko znova odstranite pod _Odstrani > Brskalnik_. Povezave nato gredo v Chrome ali Chromium, če je drugi še vedno nameščen.
