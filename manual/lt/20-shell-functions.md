# Shell funkcijos

Omarchy pristatoma su rinkiniu shell funkcijų, skirtų supaprastinti įprastas užduotis ir apibendrinti sudėtingus parametrų iškvietimus.

## Suspaudimas

- `compress [file/dir]`: sukurti tar.gz archyvą iš failo/katalogo.
- `decompress [file.tar.gz]`: išskleisti tar.gz failą.

## Diskai

- `iso2sd [image.iso]`: sukurti paleidžiamą diską SD kortelėje naudojant nurodytą iso failą ir interaktyviai pasirenkant diską.
- `format-drive [device] [name]`: formatuoti visą diską su vienu exFAT skaidiniu (kuris veikia ir Windows, ir macOS). Paleisk be argumentų, kad pamatytum prieinamus diskus. Būk atsargus!

## Kūrimo išdėstymai

Momentiniai kelių skydelių kūrimo išdėstymai tmux:

- `tdl [ai]`: sukurti Tmux Dev Layout su tavo redaktoriumi, AI agentu ir terminalu. Naudok agentų alias, pavyzdžiui, `tdl c` opencode arba `tdl cx` Claude Code, arba perduok antrą agentą, kad paleistum abu, pavyzdžiui, `tdl c cx`.
- `tds`: sukurti Tmux Dev Square su redaktoriumi, skirtumų stebėjimu (per `hunk diff --watch`), terminalu ir opencode.
- `tdlm [ai]`: sukurti `tdl` langą kiekvienam dabartinio katalogo pakatalogui.
- `tsl [count] [command]`: sukurti skydelių spiečių, išdėliotą tinklelyje, kurie visi vykdo tą pačią komandą (puikiai tinka AI agentams).

Tie patys išdėstymai prieinami Herdr kaip `hdl`, `hds`, `hdlm` ir `hsl`.

## Git worktree

- `ga [branch]`: sukurti naują worktree ir šaką šalia dabartinės saugyklos ir į ją įšokti.
- `gd`: pašalinti dabartinį worktree ir jo šaką (pirmiausia paprašo patvirtinimo).

## Rsync stebėtojai

- `rsw [source] [destination]`: paleisti foninį stebėtoją, kuris rsync'ina šaltinį į paskirties vietą, kai kas nors pasikeičia. Paskirties vieta gali būti nuotolinis host, pavyzdžiui, `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: išvardyti visus aktyvius stebėtojus.
- `dsw`: sustabdyti visus aktyvius stebėtojus.

## SSH portų persiuntimas

Idealiai tinka žiniatinklio kūrimui su localhost saugaus konteksto privilegijomis prieš nuotolinę dėžutę.

- `fip`: persiųsti vieną ar kelis portus iš nuotolinio hosto į localhost per SSH.
- `dip`: atjungti vieną ar kelis persiųstus portus.
- `lip`: išvardyti visus aktyvius SSH portų persiuntimus.

Tarkim, paleidi dev serverį porte `3000` mašinoje, pasiekiamoje kaip `nyc-dev`, tada gali paleisti `fip nyc-dev 3000`, kad persiųstum tą portą, tad `localhost:3000` iš tikrųjų pasiekia `nyc-dev:3000`, bet nereikia SSL sertifikatų, kad būtų nustatytas saugus kontekstas, reikalingas, pavyzdžiui, web socket testavimui.

## SSH pakartotinis prisijungimas

Pats `ssh` yra apvyniotas funkcija, kuri išvalo terminalą, jei ryšys nutrūksta, kol nuotolinis tmux, Herdr ar redaktorius jį užvaldęs, o tada automatiškai vėl prisijungia, kai interaktyvi sesija nutrūksta (Ctrl-C sustabdo pakartotinių bandymų ciklą).
