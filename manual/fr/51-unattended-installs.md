# Installations sans surveillance

L'ISO Omarchy peut s'installer tout seul sans personne au clavier. Si l'installateur trouve un second disque étiqueté `cidata` portant ses fichiers de configuration, il les copie, saute entièrement l'assistant de configuration, et redémarre tout seul dans le système terminé. Pas de build d'ISO spéciale, pas d'entrée de menu de démarrage supplémentaire — sans un tel disque attaché, rien ne change et vous obtenez l'assistant habituel.

Cela fait d'Omarchy une excellente image de base pour des environnements de dev jetables : créez une machine virtuelle dans Proxmox ou avec Packer, démarrez-la, partez, connectez-vous en SSH. `cidata` est l'étiquette `NoCloud` de cloud-init, si bien que tous les outils de virtualisation courants savent déjà attacher un tel disque.

## Les fichiers de configuration

Les fichiers sont exactement ce que l'assistant de l'installateur lui-même écrit, si bien que le plus simple pour obtenir un jeu de départ est de lancer une installation interactive (dans une machine virtuelle, par exemple) et de copier ce qu'elle a écrit dans `/root` :

| Fichier | Requis | Rôle |
|------|----------|---------|
| `user_configuration.json` | Oui | Disque, nom d'hôte, fuseau horaire, clavier |
| `user_credentials.json` | Oui | Nom d'utilisateur et hachage du mot de passe |
| `user_full_name.txt` | Non | Nom complet Git |
| `user_email_address.txt` | Non | E-mail Git |
| `user_encrypt_installation.txt` | Non | `true` quand la configuration contient un bloc `disk_encryption` |
| `authorized_keys` | Non | Clés publiques SSH, une par ligne |
| `tailscale_authkey` | Non | Clé d'authentification Tailscale pour rejoindre votre tailnet au premier démarrage |

Générez le hachage de mot de passe pour `user_credentials.json` avec `openssl passwd -6 "yourpassword"`.

Vous pouvez aussi déposer un fichier vide nommé `defer-provisioning` à la place de `user_credentials.json`. Cela lance la même [installation à préparer pour un autre propriétaire](02-getting-started.md) que vous pouvez déclencher interactivement : la machine s'installe sans coordonnées personnelles, et celui qui la démarre en premier choisit son clavier et crée son utilisateur. C'est le mode pour les bancs d'imagerie, où le disque ne doit porter les identifiants de personne.

## Accès SSH

Quand `authorized_keys` est présent, l'installation configure les clés comme `~/.ssh/authorized_keys` de l'utilisateur, active `sshd` et ouvre le pare-feu pour lui. (Une installation Omarchy standard est livrée avec openssh, le service désactivé et le port fermé, si bien qu'une machine sans surveillance serait sinon injoignable.) L'installation ajoute seulement vos clés — elle n'assouplit aucun autre réglage d'authentification du démon SSH.

Quand `tailscale_authkey` est présent, la machine rejoint plutôt votre tailnet au premier démarrage : Tailscale est installé depuis les paquets intégrés à l'ISO, le pare-feu autorise l'interface tailnet, et un job en arrière-plan lance la jonction dès que la machine a vraiment du réseau, en réessayant jusqu'à ce qu'elle réussisse. Utilisez une clé réutilisable et pré-autorisée pour qu'une seule image de disque puisse servir de nombreuses machines.

## Construire le disque cidata

N'importe quel système de fichiers avec la bonne étiquette fonctionne. Une minuscule ISO est la voie facile :

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Attachez-la ensuite à la machine virtuelle aux côtés de l'ISO Omarchy. Voici un exemple Proxmox complet :

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

L'ordre de démarrage liste le disque en premier à dessein : le disque vide retombe sur l'ISO au premier démarrage, et le système installé démarre depuis le disque pour toujours ensuite.

## Deux réserves

Les installations chiffrées sans surveillance ne sont pas entièrement sans surveillance — quelqu'un doit toujours taper la phrase secrète LUKS au premier démarrage. Et le bloc `disk_encryption` dans `user_configuration.json` contient cette phrase secrète en clair, traitez donc un disque cidata construit à partir d'une installation chiffrée comme le secret qu'il est.
