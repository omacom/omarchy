# Installations sans surveillance

L'ISO d'Omarchy peut s'installer toute seule, sans personne au clavier. Si le programme d'installation trouve un second lecteur étiqueté `cidata` contenant ses fichiers de configuration, il les copie, saute entièrement l'assistant de configuration et redémarre de lui-même dans le système terminé. Aucune ISO spéciale à construire, aucune entrée supplémentaire dans le menu de démarrage — sans un tel lecteur connecté, rien ne change et vous obtenez l'assistant normal.

Cela fait d'Omarchy une excellente image de base pour les environnements de développement jetables : créez une VM dans Proxmox ou avec Packer, démarrez-la, partez, connectez-vous en SSH. `cidata` est l'étiquette `NoCloud` de cloud-init, donc tous les outils de virtualisation courants savent déjà comment connecter un tel lecteur.

## Les fichiers de configuration

Ces fichiers sont exactement ceux qu'écrit l'assistant du programme d'installation lui-même, donc le moyen le plus simple d'obtenir un jeu de départ est d'effectuer une installation interactive (dans une VM, par exemple) et de copier ce qu'il a écrit dans `/root` :

| Fichier | Obligatoire | Rôle |
|------|----------|---------|
| `user_configuration.json` | Oui | Disque, nom d'hôte, fuseau horaire, clavier |
| `user_credentials.json` | Oui | Nom d'utilisateur et hachage du mot de passe |
| `user_encrypt_installation.txt` | Non | `true` lorsque la configuration comporte un bloc `disk_encryption` |
| `authorized_keys` | Non | Clés publiques SSH, une par ligne |
| `tailscale_authkey` | Non | Clé d'authentification Tailscale pour rejoindre votre tailnet au premier démarrage |

Générez le hachage du mot de passe pour `user_credentials.json` avec `openssl passwd -6 "yourpassword"`.

Le nom et l'adresse e-mail pour les commits git ne font pas partie de l'installation. Définissez-les une fois la machine en service, par SSH par exemple, avec `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Vous pouvez aussi déposer un fichier vide nommé `defer-provisioning` à la place de `user_credentials.json`. Cela exécute la même [installation préparer-pour-un-autre-propriétaire](02-getting-started.md) que vous pouvez déclencher de manière interactive : la machine s'installe sans aucune information personnelle, et la première personne qui la démarre choisit son clavier et crée son utilisateur. C'est le mode pour les stations de déploiement d'images, où le lecteur ne doit contenir les identifiants de personne.

## Accès SSH

Lorsque `authorized_keys` est présent, l'installation configure les clés comme `~/.ssh/authorized_keys` de l'utilisateur, active `sshd` et ouvre le pare-feu pour lui. (Une installation Omarchy standard est livrée avec openssh, le service désactivé et le port fermé, donc une machine sans surveillance serait sinon inaccessible.) L'installation ajoute uniquement vos clés — elle n'assouplit aucun des autres paramètres d'authentification du démon SSH.

Lorsque `tailscale_authkey` est présent, la machine rejoint plutôt votre tailnet au premier démarrage : Tailscale est installé à partir des paquets fournis avec l'ISO, le pare-feu autorise l'interface du tailnet, et une tâche en arrière-plan effectue la jonction dès que la machine dispose réellement du réseau, en réessayant jusqu'à ce qu'elle réussisse. Utilisez une clé réutilisable et pré-autorisée pour qu'une seule image de lecteur puisse servir à de nombreuses machines.

## Construire le lecteur cidata

N'importe quel système de fichiers avec la bonne étiquette convient. Une minuscule ISO est le moyen le plus simple :

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Connectez-la ensuite à la VM à côté de l'ISO d'Omarchy. Voici un exemple Proxmox complet :

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

L'ordre de démarrage place délibérément le disque en premier : le disque vide laisse la place à l'ISO au premier démarrage, et le système installé démarre ensuite depuis le disque pour toujours.

## Deux réserves

Les installations chiffrées sans surveillance ne sont pas entièrement sans surveillance — quelqu'un doit encore saisir la phrase secrète LUKS au premier démarrage. Et le bloc `disk_encryption` dans `user_configuration.json` contient cette phrase secrète en texte clair, donc traitez un lecteur cidata construit à partir d'une installation chiffrée comme le secret qu'il est.
