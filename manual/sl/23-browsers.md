# Brskalniki

Omarchy ima za privzeti brskalnik nameščen [Google Chrome](https://www.google.com/chrome/). Njegova tema je usklajena s preostalim delom vašega sistema, odpre ga bližnjica `Super + Shift + Return`, v njem pa teče tudi vsaka [spletna aplikacija](25-web-apps.md). Odpre se naravnost v okno brskalnika: ni pozdravnega zaslona ali poziva k prijavi, statistika uporabe in poročila o zrušitvah se ne pošiljajo Googlu, pozivi glede zasebnosti oglasov pa so izklopljeni. Še vedno se lahko kadarkoli prijavite v svoj Google račun z gumbom za profil, kadar želite sinhronizacijo.

Če Chrome ni po vašem okusu, niste obtičali z njim. V meniju Omarchy pod _Namesti > Brskalnik_ boste našli [Chromium](https://www.chromium.org/) (navadno odprtokodno različico, iz katere je narejen Chrome), Edge, Brave, Brave Origin, Firefox in [Zen](https://zen-browser.app/). Izberite enega in Omarchy ga bo namestil, nastavil njegov imenik s pravilniki in nanj uporabil vašo trenutno temo.

## Nastavitev enega za privzetega

Namestitev brskalnika ga še ne naredi privzetega. Ko je na računalniku, pojdite v _Nastavitev > Privzete nastavitve > Brskalnik_ in ga izberite — meni prikaže samo brskalnike, ki jih dejansko imate nameščene, trenutno privzetega pa označi s kljukico.

Iz terminala gre takole:

```bash
omarchy default browser firefox
```

Zaženite ga brez argumenta in povedal vam bo trenutno privzetega. To nastavi obdelovalnik XDG, zato ne sledijo samo bližnjice Omarchy — vse, kar odpre povezavo, od aplikacije za klepet do ukaza v terminalu, gre v brskalnik, ki ste ga izbrali.

## Copy URL in Download Video

Brskalniki iz družine Chromium (sam Chromium, Chrome, Edge in Brave) imajo dve razširitvi Omarchy, ki segata iz brskalnika v preostali del vašega sistema.

**Copy URL** z `Alt + Shift + L` odloži naslov trenutnega zavihka v vaše odložišče. To je hitreje kot klik v naslovno vrstico in kopiranje, in ker gre skozi sistemsko odložišče namesto brskalnikovega, prejmete potrditveno obvestilo Omarchy, URL pa je takoj na voljo v [zgodovini odložišča](08-unified-clipboard-history.md) in vsaki drugi aplikaciji. Če raje klikate, je na voljo tudi gumb v orodni vrstici.

**Download Video** z `Alt + Shift + D` zgrabi video, ki se predvaja na strani, ki jo gledate. URL preda orodju [yt-dlp](https://github.com/yt-dlp/yt-dlp), zato deluje na veliko več kot samo na YouTube, prenos pa pristane v `~/Videos`. Napredek se prikaže na istem zaslonskem prikazu, ki ga uporabljata glasnost in svetlost, in se posodablja na mestu, namesto da bi se obvestila kopičila. Nastavite `OMARCHY_YTDLP_DIR`, če želite, da datoteke gredo drugam — kje nastaviti spremenljivke okolja, si oglejte v [FAQ](46-faq.md).

Obe razširitvi komunicirata z Omarchy prek majhnega gostitelja za izvorno sporočanje, ki se za vas namesti skupaj z brskalnikom. To je del, ki omogoča, da video s spletne strani pristane v vašem domačem imeniku in URL v vašem upravitelju odložišča, česar običajna razširitev sama ne more storiti.

Ti sta na voljo samo za družino Chromium. Firefox in Zen ju ne dobita.

## Firefox in Zen

Firefox in Zen sta iz druge družine, zato sta deležna drugačne obravnave: Omarchy namesti datoteko s pravilniki za smiselne privzete nastavitve in ju preklopi v izvorni način Wayland, ki ga želite za delno skaliranje in gladko drsenje s sledilno ploščico.

Ne dobita zgornjih razširitev za Chromium in Omarchy jima ne nastavi teme, zato morate te dele izkušnje nastaviti sami.

## Ponovna odstranitev

Vsakega od teh brskalnikov, vključno s Chromom, lahko znova odstranite pod _Odstrani > Brskalnik_. Povezave bodo nato šle v Chrome ali Chromium, če je drugi od njiju še vedno nameščen.
