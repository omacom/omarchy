# Aparatinės įrangos autentifikavimas

### Autentifikavimas piršto atspaudu

Daugelyje nešiojamųjų kompiuterių yra piršto atspaudo jutiklis, skirtas autentifikavimui. Jį galite naudoti su Omarchy, Omarchy meniu (`Super + Space`) paleidę _Setup > Security > Fingerprint_.

Atsidarys viso ekrano piršto atspaudo vaizdas, kuris užsipildys jums liečiant jutiklį. Tuo metu fone Omarchy įdiegs piršto atspaudo paketą, nuskaitys jūsų atspaudą, jį patikrins, ir galėsite naudoti piršto atspaudą atrakindami iš užrakto ekrano (kurį galite įjungti paspaudę `Super + Ctrl + L`), įjungdami sudo režimą ir patvirtindami sistemos užklausas.

Kai užrakto ekranas išjungia ekraną, jutiklis ilsisi, kad taupytų energiją, todėl prieš jį liesdami pažadinkite ekraną bet kuriuo klavišu arba jutikliniu kilimėliu.

Kai nešiojamojo kompiuterio dangtis uždarytas, piršto atspaudo užklausa automatiškai praleidžiama, todėl iš karto pereinate prie slaptažodžio užklausos, užuot laukę jutiklio, kurio negalite pasiekti. Jei dėl kitų priežasčių tenka dirbti su išorine klaviatūra, kurioje nėra jutiklio, tiesiog paspauskite `CTRL + C`, kai `sudo` metu jūsų prašoma pateikti piršto atspaudą.

Autentifikavimą piršto atspaudu galite pašalinti Omarchy meniu dalyje _Remove > Security > Fingerprint_.

### Fido2 autentifikavimas

Jei naudojate Fido2 įrenginį, galite jį nustatyti `sudo` autentifikavimui, Omarchy meniu (`Super + Space`) naudodami _Setup > Security > Fido2_. Vis dėlto tai taikoma `sudo` ir sistemos autorizavimo užklausoms, o ne kompiuterio atrakinimui.

Fido2 autentifikavimą galite pašalinti Omarchy meniu dalyje _Remove > Security > Fido2_.
