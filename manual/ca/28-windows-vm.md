# Màquina virtual de Windows

Omarchy ofereix una manera fàcil d'executar Windows mitjançant una màquina virtual de Docker. La pots instal·lar amb _Instal·la > Windows_ des del menú d'Omarchy (`Super + Space`).

La teva màquina necessita virtualització KVM per a això, que la majoria en té — però de vegades està desactivada a la BIOS, i l'instal·lador t'ho dirà si és el cas. També voldràs tenir l'espai de disc: el que donis a Windows, més uns 10GB per a la imatge mateixa.

L'instal·lador et demana quanta RAM, quants nuclis de CPU i quant disc vols cedir (64GB o més és el mínim sensat), i després un nom d'usuari i una contrasenya de Windows. Deixa'ls en blanc i obtindràs `docker` / `admin`. La descàrrega triga una estona — 10-15 minuts és normal — i pots seguir el progrés al navegador a `http://127.0.0.1:8006`. El navegador demana el mateix nom d'usuari i la mateixa contrasenya abans d'obrir la consola.

 ![windows-vm](images/windows-vm.webp)

## Fer-la servir

Un cop estigui instal·lada, llança _Windows_ des del llançador d'aplicacions. Això engega la màquina virtual si encara no està en marxa i t'hi connecta per RDP, a pantalla completa. Dona-li 15-30 segons en una arrencada en fred.

La sessió RDP transporta so, el teu micròfon i un porta-retalls compartit, de manera que copiar text entre Linux i Windows simplement funciona. La resolució segueix la teva finestra, i Omarchy hi fa passar l'escala de la pantalla, de manera que no és un embolic borrós en una pantalla HiDPI.

Quan tanques la finestra RDP, la màquina virtual s'apaga automàticament. Si prefereixes deixar-la en marxa — suposa que hi tens alguna cosa treballant a dins —, llança-la amb `omarchy windows vm launch --keep-alive` en el seu lloc.

La resta de controls són a la mateixa ordre:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartir fitxers

El directori `~/Windows` del teu directori personal es comparteix automàticament amb la màquina virtual. Posa-hi fitxers si vols que siguin accessibles a Windows. La màquina virtual no té accés a cap altra part del teu sistema de fitxers, de manera que estàs segur de qualsevol cosa dolenta del costat de Windows. El seu propi disc virtual està disponible a `~/.windows`.

Aquelles rutes familiars del directori personal es queden als seus propis sistemes de fitxers. També poden ser enllaços simbòlics cap a directoris que et pertanyen, cosa útil quan el disc virtual viu en una unitat més gran. L'instal·lador mesura l'espai lliure al sistema de fitxers que conté realment `~/.windows`, no necessàriament el sistema de fitxers que conté el teu directori personal.

Mantén les rutes del disc i de la compartició com a directoris separats que no se solapin. L'eliminació buida deliberadament el directori del disc però preserva el directori compartit. Just abans de l'esborrat, Omarchy fa una comprovació de contenció limitada i es nega a eliminar res si aquella comprovació expira o no pot demostrar que els dos arbres estan separats.

Abans que la màquina virtual s'engegui, Omarchy obre i fixa aquells dos directoris, i després munta amb bind els inodes de directori exactes sobre àncores privades per usuari a sota de `/var/lib/omarchy/windows/mounts`. Docker només veu aquelles àncores protegides per root. Això preserva les ubicacions de disc personalitzades alhora que impedeix que un altre procés que s'executi com tu intercanviï una ruta comprovada abans que el contenidor privilegiat la consumeixi. Els directoris de disc i compartits existents s'estrenyen al mode `0700` durant la migració perquè altres comptes locals no en puguin consultar el contingut.

Els ports de la màquina virtual estan lligats només a localhost, de manera que res de la teva xarxa pot arribar a la màquina Windows. La consola web també requereix el nom d'usuari i la contrasenya de Windows configurats, cosa que impedeix que un altre compte local condueixi la màquina virtual mitjançant el port 8006.

## Límits i llicències

No hi ha passthrough de GPU amb aquesta configuració, de manera que no és adequada per a jocs ni per a l'edició de vídeo. És una gran manera d'executar Microsoft Office o el que sigui que hagis de tenir sí o sí.

La versió instal·lada és Windows 11 Pro, sense activar. Necessitaràs la teva pròpia clau de llicència per fer servir les funcions restringides.

Si aquest ordinador va venir amb Windows, la clau OEM continua sent al microprogramari fins i tot després d'instal·lar Omarchy. Imprimeix-la amb `omarchy windows key`. Aquella clau està lligada a aquesta màquina — activarà un Windows reinstal·lat en aquest maquinari, però normalment no activarà pas la màquina virtual.

Pots canviar l'assignació de recursos més tard tornant a executar `omarchy-windows-vm install`, que reescriu la configuració de la màquina virtual a partir de les teves respostes. El mateix fitxer compose viu ara a `/var/lib/omarchy/windows/docker-compose.yml` i pertany a root — això és deliberat, perquè un procés que s'executi com tu no el pugui reescriure i fer que l'arrencada privilegiada munti tot el teu disc dins del contenidor. Si necessites editar-lo a mà (per exemple per muntar un dispositiu USB), edita'l amb `sudo` i consulta totes les opcions al [projecte Dockur Windows](https://github.com/dockur/windows).

Per desfer-te de tot plegat, fes servir _Elimina > Windows_ des del menú d'Omarchy. Això elimina el disc de la màquina virtual i totes les seves dades, de manera que assegura't que tot el que t'importa hagi sortit abans de `~/Windows`.
