# Aparatinės įrangos autentifikavimas

### Autentifikavimas piršto atspaudu

Daug nešiojamųjų kompiuterių turi piršto atspaudų jutiklį autentifikavimui. Gali jį naudoti su Omarchy Omarchy meniu (`Super + Space`) paleidęs _Sąranka > Sauga > Piršto atspaudas_.

Taip įdiegsi piršto atspaudų paketą, užfiksuosi savo atspaudą, jį patvirtinsi ir galėsi piršto atspaudu atsirakinti iš užrakinimo ekrano (kurį gali iškviesti su `Super + Ctrl + L`), įjungti sudo režimą ir patvirtinti sistemos užklausas.

Kai užrakinimo ekranas išjungia ekraną, jutiklis ilsisi, kad taupytų energiją, todėl prieš jį liesdamas pažadink ekraną bet kuriuo klavišu arba jutikliniu kilimėliu.

Kai nešiojamojo kompiuterio dangtelis uždarytas, piršto atspaudo užklausa automatiškai praleidžiama, todėl pereini tiesiai prie slaptažodžio užklausos, užuot laukęs jutiklio, kurio negali pasiekti. Jei kitais atvejais tau reikia dirbti su išorine klaviatūra, kuri neturi jutiklio, tiesiog paspausk `CTRL + C`, kai `sudo` metu tavęs paprašys piršto atspaudo.

Autentifikavimą piršto atspaudu gali pašalinti Omarchy meniu pasirinkęs _Pašalinti > Sauga > Piršto atspaudas_.

### Fido2 autentifikavimas

Jei naudoji Fido2 įrenginį, gali jį nustatyti `sudo` autentifikavimui Omarchy meniu (`Super + Space`) pasirinkęs _Sąranka > Sauga > Fido2_. Vis dėlto tai apima `sudo` ir sistemos autorizavimo užklausas, o ne kompiuterio atrakinimą.

fido2 autentifikavimą gali pašalinti Omarchy meniu pasirinkęs _Pašalinti > Sauga > Fido2_.
