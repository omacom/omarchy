# Windows VM

Omarchy ofereix una manera fàcil d'executar Windows a través d'una VM de Docker en màquines x86_64. La pots instal·lar amb _Install > Windows_ des del menú d'Omarchy (`Super + Space`).

La teva màquina necessita virtualització KVM per a això, i la majoria en tenen — però de vegades està desactivada a la BIOS, i l'instal·lador t'avisarà si és el cas. També voldràs espai de disc: el que donis a Windows, més uns 10GB per a la imatge en si.

L'instal·lador pregunta quanta RAM, quants nuclis de CPU i quant disc vols cedir (64GB o més és el mínim assenyat), i després un nom d'usuari i una contrasenya de Windows. Deixa'ls en blanc i obtindràs `docker` / `admin`. La descàrrega triga una estona — 10-15 minuts és normal — i pots seguir-ne el progrés al navegador a `http://127.0.0.1:8006`. El navegador demana el mateix nom d'usuari i la mateixa contrasenya abans d'obrir la consola.

 ![windows-vm](images/windows-vm.webp)

## Com fer-la servir

Un cop instal·lada, obre _Windows_ des del llançador d'aplicacions. Això inicia la VM si encara no està en marxa i et connecta per RDP, a pantalla completa. Dona-li 15-30 segons en una arrencada en fred.

La sessió RDP transmet el so, el teu micròfon i un porta-retalls compartit, de manera que copiar text entre Linux i Windows senzillament funciona. La resolució segueix la teva finestra, i Omarchy hi transmet l'escalat de la teva pantalla, de manera que no és un embolic borrós en una pantalla HiDPI.

Quan tanques la finestra RDP, la VM s'apaga automàticament. Si prefereixes deixar-la en marxa — posem que hi tens alguna cosa treballant — llança-la amb `omarchy windows vm launch --keep-alive` en comptes d'això.

La resta de controls són a la mateixa ordre:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartir fitxers

El directori `~/Windows` del teu directori personal es comparteix automàticament amb la VM. Posa-hi fitxers si vols que Windows hi pugui accedir. La VM no té accés a cap altra part del teu sistema de fitxers, així que estàs protegit de qualsevol cosa desagradable del costat de Windows. El seu propi disc virtual està disponible a `~/.windows`.

Aquests camins familiars del directori personal es mantenen en els seus propis sistemes de fitxers. També poden ser enllaços simbòlics a directoris teus, cosa útil quan el disc virtual viu en una unitat més gran. L'instal·lador mesura l'espai lliure en el sistema de fitxers que conté realment `~/.windows`, no necessàriament el sistema de fitxers que conté el teu directori personal.

Mantén el disc i els camins compartits com a directoris separats que no se superposin. En eliminar-la, el directori del disc es buida deliberadament però el directori compartit es conserva. Just abans de l'eliminació, Omarchy fa una comprovació de contenció limitada i es nega a eliminar res si aquesta comprovació supera el temps límit o no pot demostrar que els dos arbres són separats.

Abans que la VM s'iniciï, Omarchy obre i fixa aquests dos directoris, i després munta amb bind-mount els inodes exactes dels directoris en ancoratges privats per usuari a sota de `/var/lib/omarchy/windows/mounts`. Docker només veu aquests ancoratges protegits per root. Això preserva les ubicacions personalitzades del disc i alhora impedeix que un altre procés executat com a tu intercanviï un camí comprovat abans que el contenidor privilegiat el consumeixi. Els directoris del disc i compartit existents s'endureixen al mode `0700` durant la migració perquè altres comptes locals no en puguin explorar el contingut.

Els ports de la VM estan vinculats només a localhost, de manera que res de la teva xarxa no pot arribar a la màquina Windows. La consola web també requereix el nom d'usuari i la contrasenya de Windows configurats, cosa que impedeix que un altre compte local controli la VM a través del port 8006.

## Límits i llicències

Amb aquesta configuració no hi ha passthrough de GPU, així que no és adequada per jugar ni per editar vídeo. És una manera excel·lent d'executar Microsoft Office o qualsevol altra cosa que hagis de tenir sí o sí.

La versió instal·lada és Windows 11 Pro, sense activar. Necessitaràs la teva pròpia clau de llicència per utilitzar les funcions restringides.

Si aquest ordinador venia amb Windows, la clau OEM encara és al firmware fins i tot després d'instal·lar Omarchy. Imprimeix-la amb `omarchy windows key`. Aquesta clau està vinculada a aquesta màquina — activarà Windows reinstal·lat en aquest maquinari, però normalment no activarà la VM.

Pots canviar l'assignació de recursos més tard executant `omarchy windows vm install` en un terminal, cosa que reescriu la configuració de la VM a partir de les teves respostes. El fitxer compose en si ara viu a `/var/lib/omarchy/windows/docker-compose.yml` i és propietat de root — és deliberat, perquè un procés executat com a tu no el pugui reescriure i fer que l'arrencada privilegiada munti tot el teu disc dins del contenidor. Si necessites editar-lo a mà (per exemple per muntar un dispositiu USB), edita'l amb `sudo` i consulta totes les opcions al [projecte Dockur Windows](https://github.com/dockur/windows).

Per desfer-te de tot plegat, fes servir _Remove > Windows_ des del menú d'Omarchy. Això elimina el disc de la VM a `~/.windows` i tot el que hi ha instal·lat dins de Windows, així que copia primer fora de la VM tot el que necessitis. La teva carpeta compartida `~/Windows` queda intacta.
