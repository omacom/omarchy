# Autenticació per maquinari

### Autenticació per empremta dactilar

Molts portàtils venen amb un sensor d'empremtes dactilars per fer l'autenticació. Pots fer-lo servir amb Omarchy executant _Setup > Security > Fingerprint_ al menú d'Omarchy (`Super + Space`).

Això instal·larà el paquet d'empremtes dactilars, recollirà la teva empremta, la verificarà, i ja estaràs a punt per fer servir l'empremta dactilar per desbloquejar des de la pantalla de bloqueig (que pots activar amb `Super + Ctrl + L`), entrar en mode sudo i autoritzar les sol·licituds del sistema.

Un cop la pantalla de bloqueig ha apagat la pantalla, el sensor reposa per estalviar energia, així que desperta la pantalla amb qualsevol tecla o amb el touchpad abans de tocar-lo.

Quan la tapa del portàtil està tancada, la sol·licitud d'empremta dactilar se salta automàticament, de manera que vas directe a la sol·licitud de contrasenya en lloc d'esperar un sensor al qual no pots arribar. Si, d'altra banda, necessites treballar amb un teclat extern que no té sensor, simplement prem `CTRL + C` quan se't demani l'empremta dactilar durant `sudo`.

Pots eliminar l'autenticació per empremta dactilar a _Remove > Security > Fingerprint_ al menú d'Omarchy.

### Autenticació Fido2

Si fas servir un dispositiu Fido2, pots configurar-lo per a l'autenticació de `sudo` mitjançant _Setup > Security > Fido2_ al menú d'Omarchy (`Super + Space`). Tanmateix, cobreix `sudo` i les sol·licituds d'autorització del sistema, no pas el desbloqueig de l'ordinador.

Pots eliminar l'autenticació fido2 a _Remove > Security > Fido2_ al menú d'Omarchy.
