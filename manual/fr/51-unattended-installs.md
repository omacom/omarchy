# Installations sans surveillance

L'ISO Omarchy peut s'installer sans personne au clavier. Si le programme d'installation trouve un second disque libellé `cidata` contenant ses fichiers de configuration, il les copie, ignore complètement l'assistant de configuration et redémarre de lui-même vers le système terminé. Aucune ISO spéciale à construire, aucune entrée supplémentaire dans le menu de démarrage — sans un tel disque attaché, rien ne change et vous obtenez l'assistant normal.

Cela fait d'Omarchy une excellente image de base pour les environnements de développement jetables : créez une VM dans Proxmox ou avec Packer, démarrez-la, partez, connectez-vous en SSH. `cidata` est le libellé `NoCloud` de cloud-init, donc tous les outils de virtualisation courants savent déjà comment attacher un tel disque.

## Les fichiers de configuration

Les fichiers sont exactement ceux qu'écrit l'assistant du programme d'installation, donc le moyen le plus simple d'obtenir un jeu de départ est d'exécuter une installation interactive (dans une VM, par exemple) et de copier ce qu'elle a écrit dans `/root` :

| Fichier | Obligatoire | Objectif |
|------|----------|---------|
| `user_configuration.json` | Oui | Disque, nom d'hôte, fuseau horaire, clavier |
| `user_credentials.json` | Oui | Nom d'utilisateur et hachage du mot de passe, et phrase secrète LUKS pour une installation chiffrée |
| `user_encrypt_installation.txt` | Non | `true` lorsque la configuration contient un bloc `disk_encryption` |
| `authorized_keys` | Non | Clés publiques SSH, une par ligne |
| `tailscale_authkey` | Non | Clé d'authentification Tailscale pour rejoindre votre tailnet au premier démarrage |

Générez le hachage du mot de passe pour `user_credentials.json` avec `openssl passwd -6 "yourpassword"`.

Le nom et l'adresse e-mail pour les commits git ne font pas partie de l'installation. Définissez-les une fois la machine en marche, via SSH par exemple, avec `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Vous pouvez également déposer un fichier vide nommé `defer-provisioning` à la place de `user_credentials.json`. Cela exécute la même [installation de préparation pour un autre propriétaire](02-getting-started.md) que vous pouvez déclencher de manière interactive : la machine s'installe sans informations personnelles, et la première personne qui la démarre choisit son clavier et crée son utilisateur. C'est le mode pour les stations d'imagerie, où le disque ne doit transporter les identifiants de personne.

## Accès SSH

Lorsque `authorized_keys` est présent, l'installation configure les clés comme le fichier `~/.ssh/authorized_keys` de l'utilisateur, active `sshd`, et ouvre le pare-feu pour lui. (Une installation Omarchy standard fournit openssh avec le service désactivé et le port fermé, donc une machine sans surveillance serait autrement inaccessible.) L'installation ajoute uniquement vos clés — elle n'assouplit aucun des autres paramètres d'authentification du démon SSH.

Lorsque `tailscale_authkey` est présent, la machine rejoint plutôt votre tailnet au premier démarrage : Tailscale est installé depuis les paquets fournis avec l'ISO, le pare-feu autorise l'interface du tailnet, et une tâche en arrière-plan exécute la jonction dès que la machine dispose réellement d'un réseau, en réessayant jusqu'à réussir. Utilisez une clé réutilisable et préautorisée afin qu'une seule image de disque puisse servir à de nombreuses machines.

## Construction du disque cidata

Tout système de fichiers avec le bon libellé fonctionne. Une petite ISO est la solution facile :

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Attachez-la ensuite à la VM aux côtés de l'ISO Omarchy. Voici un exemple Proxmox complet :

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

L'ordre de démarrage liste le disque en premier à dessein : le disque vide laisse la place à l'ISO au premier démarrage, et le système installé démarre depuis le disque par la suite pour toujours.

## Deux réserves

Les installations chiffrées sans surveillance ne sont pas entièrement sans surveillance — quelqu'un doit toujours saisir la phrase secrète LUKS au premier démarrage. Et cette phrase secrète va au niveau racine de `user_credentials.json` sous le nom `encryption_password` — archinstall la lit à cet endroit, pas depuis le bloc `disk_encryption` dans `user_configuration.json` — donc traitez un disque cidata construit à partir d'une installation chiffrée comme le secret qu'il est.
