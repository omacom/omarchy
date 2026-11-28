# Brskalniki

Omarchy je privzeto opremljen z [Google Chrome](https://www.google.com/chrome/) kot privzetim brskalnikom. Tematsko je usklajen s preostalim delom vašega sistema, prav njega odpre `Super + Shift + Return` (ali `Super + Shift + B`), z `Super + Shift + Alt + B` pa zasebno okno, in v njem teče vsaka [spletna aplikacija](25-web-apps.md). Odpre se naravnost v okno brskalnika: ni pozdravnega zaslona ali poziva k prijavi, statistika uporabe in poročila o zrušitvah se ne pošiljajo Googlu, pozivi glede zasebnosti pri oglasih pa so izklopljeni. Še vedno se lahko, kadar želite sinhronizacijo, z gumbom profila prijavite v svoj Google račun.

Če vam Chrome ni po okusu, niste obtičali z njim. Pod _Install > Browser_ v meniju Omarchy boste našli [Chromium](https://www.chromium.org/) (navadno odprtokodno različico, iz katere je narejen Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) in [Ladybird](https://ladybird.org/) (Edge samo na napravah x86). Izberite enega in Omarchy ga bo namestil, zanj nastavil imenik pravilnikov in nanj uporabil vašo trenutno temo.

## Kako enega nastaviti za privzetega

Namestitev brskalnika ga še ne povzdigne v privzetega. Za zamenjavo pojdite v _Setup > Defaults > Browser_ in enega izberite. Trenutni privzeti je označen s kljukico, izbira brskalnika, ki ga še nimate, pa ga najprej namesti.

Iz terminala je to:

```bash
omarchy default browser firefox
```

Zaženite ga brez argumenta in povedal vam bo, kateri je trenutni privzeti. S tem nastavite upravljalnika XDG, zato temu ne sledijo samo bližnjične tipke Omarchy — vse, kar odpre povezavo, od aplikacije za klepet do ukaza v terminalu, gre v brskalnik, ki ste ga izbrali.

## Copy URL in Download Video

Brskalniki iz družine Chromium (sam Chromium, Chrome, Edge, Brave in Brave Origin) so opremljeni s tremi razširitvami Omarchy: dvema, ki sežeta iz brskalnika v preostali del vašega sistema, in eno, ki pospravi WhatsApp.

**Copy URL** z `Alt + Shift + L` postavi naslov trenutnega zavihka v vaše odložišče. To je hitreje kot klikanje v naslovno vrstico in kopiranje, in ker gre prek sistemskega odložišča namesto brskalnikovega, prejmete potrditveno obvestilo Omarchy, URL pa je takoj na voljo v [zgodovini odložišča](08-unified-clipboard-history.md) in vsaki drugi aplikaciji. Če raje klikate, je na voljo tudi gumb v orodni vrstici.

**Download Video** z `Alt + Shift + D` zajame videoposnetek, ki se predvaja na strani, ki jo gledate. URL preda [yt-dlp](https://github.com/yt-dlp/yt-dlp), zato deluje na veliko več kot le na YouTube, prenos pa pristane v `~/Videos`. Napredek se prikaže v istem zaslonskem prikazu, ki ga uporabljata glasnost in svetlost, in se posodablja na mestu, namesto da bi se obvestila kopičila eno na drugo. Nastavite `OMARCHY_YTDLP_DIR`, če želite, da datoteke pristanejo drugje — kje nastaviti spremenljivke okolja, si oglejte v [pogostih vprašanjih](46-faq.md).

Obe razširitvi komunicirata z Omarchy prek majhnega izvornega gostitelja za sporočanje, ki se namesti skupaj z brskalnikom. To je tisti del, ki omogoči, da videoposnetek s spletne strani pristane v vašem domačem imeniku, URL pa v vašem upravitelju odložišča, česar običajna razširitev sama ne zmore.

**WhatsApp Slim** poskrbi, da WhatsApp Web sledi vaši sistemski temi in strne svoj seznam klepetov, ko je okno ozko.

Te so na voljo samo za družino Chromium. Firefox in Zen jih ne dobita.

## Firefox in Zen

Firefox in Zen sta iz druge družine, zato sta obravnavana drugače: Omarchy namesti datoteko s pravilniki za smiselne privzete nastavitve in ju preklopi v izvorni način Wayland, kar želite za delno skaliranje in gladko drsenje s sledilno ploščico.

Ne dobita zgornjih razširitev za Chromium in nista tematsko obdelana s strani Omarchy, zato morate te dele izkušnje nastaviti sami.

## Ladybird

Ladybird je brskalnik, napisan od nič, z lastnim pogonom namesto Chromiumovega ali Firefoxovega. Še vedno je v različici alpha, zato pričakujte spletna mesta, ki še ne delujejo, Omarchy pa ga namesti takšnega, kot je: brez razširitev, brez teme, brez pravilnikov. Nima niti zasebnega okna, zato ga `Super + Shift + Alt + B` odpre z začasnim profilom, ki se izbriše, ko ga zaprete. [Spletne aplikacije](25-web-apps.md) še naprej tečejo v Chrome ali Chromium.

## Ponovna odstranitev brskalnika

Vsakega od teh brskalnikov, vključno s Chrome, lahko znova odstranite pod _Remove > Browser_. Povezave nato gredo v Chrome ali Chromium, če je drugi še vedno nameščen.
