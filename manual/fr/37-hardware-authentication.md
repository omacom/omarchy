# Authentification matérielle

### Authentification par empreinte digitale

De nombreux ordinateurs portables sont équipés d’un capteur d’empreinte digitale pour l’authentification. Vous pouvez l’utiliser avec Omarchy en lançant _Configuration > Sécurité > Empreinte digitale_ dans le menu Omarchy (`Super + Space`).

Cela installera le paquet de gestion des empreintes digitales, enregistrera votre empreinte, la vérifiera, et vous serez prêt à utiliser votre empreinte digitale pour déverrouiller l’écran de verrouillage (que vous pouvez déclencher avec `Super + Ctrl + L`), passer en mode sudo et autoriser les demandes du système.

Une fois que l’écran de verrouillage a éteint l’affichage, le capteur se met en veille pour économiser l’énergie, alors réveillez l’écran avec n’importe quelle touche ou le pavé tactile avant de le toucher.

Lorsque le capot de votre ordinateur portable est fermé, la demande d’empreinte digitale est automatiquement ignorée, vous passez donc directement à la demande de mot de passe au lieu d’attendre un capteur que vous ne pouvez pas atteindre. Si vous devez par ailleurs travailler sur un clavier externe qui n’a pas de capteur, appuyez simplement sur `CTRL + C` lorsque votre empreinte digitale vous est demandée pendant `sudo`.

Vous pouvez supprimer l’authentification par empreinte digitale sous _Supprimer > Sécurité > Empreinte digitale_ dans le menu Omarchy.

### Authentification Fido2

Si vous utilisez un appareil Fido2, vous pouvez le configurer pour l’authentification `sudo` en utilisant _Configuration > Sécurité > Fido2_ dans le menu Omarchy (`Super + Space`). Cela couvre toutefois `sudo` et les demandes d’autorisation du système, pas le déverrouillage de votre ordinateur.

Vous pouvez supprimer l’authentification fido2 sous _Supprimer > Sécurité > Fido2_ dans le menu Omarchy.
