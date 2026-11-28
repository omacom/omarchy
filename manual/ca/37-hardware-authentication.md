# Autenticació de maquinari

### Autenticació per empremta digital

Molts portàtils vénen amb un sensor d'empremta digital per fer l'autenticació. Pots utilitzar-ho amb Omarchy executant _Configuració > Seguretat > Empremta digital_ al menú d'Omarchy (`Super + Space`).

Això obre una empremta digital a pantalla completa que s'omple a mesura que toques el sensor. Per darrere, Omarchy instal·larà el paquet d'empremta digital, recollirà la teva empremta, la verificarà, i ja estaràs a punt per utilitzar la teva empremta digital per desbloquejar des de la pantalla de bloqueig (que pots activar amb `Super + Ctrl + L`), entrar en mode sudo i autoritzar les sol·licituds del sistema.

Un cop la pantalla de bloqueig ha apagat la pantalla, el sensor reposa per estalviar energia, així que desperta la pantalla amb qualsevol tecla o el touchpad abans de tocar-lo.

Quan la tapa del teu portàtil està tancada, la sol·licitud d'empremta digital se salta automàticament, així que vas directament a la sol·licitud de contrasenya en comptes d'esperar un sensor al qual no pots arribar. Si d'altra manera necessites treballar amb un teclat extern que no té sensor, simplement prem `CTRL + C`, quan se't demani l'empremta digital durant `sudo`.

Pots eliminar l'autenticació per empremta digital a _Elimina > Seguretat > Empremta digital_ al menú d'Omarchy.

### Autenticació Fido2

Si utilitzes un dispositiu Fido2, el pots configurar per a l'autenticació de `sudo` utilitzant _Configuració > Seguretat > Fido2_ al menú d'Omarchy (`Super + Space`). Cobreix `sudo` i les sol·licituds d'autorització del sistema, però no el desbloqueig de l'ordinador.

Pots eliminar l'autenticació fido2 a _Elimina > Seguretat > Fido2_ al menú d'Omarchy.
