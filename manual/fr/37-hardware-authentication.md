# Authentification matérielle

### Authentification par empreinte digitale

Beaucoup d'ordinateurs portables sont équipés d'un capteur d'empreinte digitale pour l'authentification. Vous pouvez l'utiliser avec Omarchy en lançant _Setup > Security > Fingerprint_ dans le menu Omarchy (`Super + Space`).

Cela ouvre une empreinte digitale en plein écran qui se remplit au fur et à mesure que vous touchez le capteur. En coulisses, Omarchy installera le paquet d'empreinte digitale, collectera votre empreinte, la vérifiera, et vous serez prêt à utiliser votre empreinte digitale pour déverrouiller depuis l'écran de verrouillage (que vous pouvez déclencher avec `Super + Ctrl + L`), passer en mode sudo et autoriser les invites système.

Une fois que l'écran de verrouillage a éteint l'écran, le capteur se met au repos pour économiser de l'énergie, alors réveillez l'écran avec n'importe quelle touche ou avec le pavé tactile avant de le toucher.

Lorsque le capot de votre ordinateur portable est fermé, l'invite d'empreinte digitale est automatiquement ignorée, vous passez donc directement à l'invite de mot de passe au lieu d'attendre un capteur auquel vous ne pouvez pas accéder. Si vous devez par ailleurs travailler sur un clavier externe qui n'a pas de capteur, appuyez simplement sur `CTRL + C`, lorsque vous êtes invité à présenter votre empreinte digitale pendant `sudo`.

Vous pouvez supprimer l'authentification par empreinte digitale sous _Remove > Security > Fingerprint_ dans le menu Omarchy.

### Authentification Fido2

Si vous utilisez un appareil Fido2, vous pouvez le configurer pour l'authentification `sudo` à l'aide de _Setup > Security > Fido2_ dans le menu Omarchy (`Super + Space`). Il couvre toutefois `sudo` et les invites d'autorisation système, pas le déverrouillage de votre ordinateur.

Vous pouvez supprimer l'authentification fido2 sous _Remove > Security > Fido2_ dans le menu Omarchy.
