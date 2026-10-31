# Plugins da shell

O ambiente de trabalho Omarchy corre como um único processo Quickshell de longa duração chamado `omarchy-shell`, e quase tudo o que vês no ecrã é um plugin dentro dele. A barra é um plugin. Também o são os painéis que descem dela, as sobreposições em ecrã inteiro como o seletor de emoji e o gestor da área de transferência, o próprio menu Omarchy, o ecrã de bloqueio, a caixa de diálogo do polkit e os serviços sem interface que vigiam a tua bateria e aquecem o teu ecrã à noite.

Isso não é apenas um detalhe de implementação. Significa que podes desligar partes do ambiente de trabalho, trocá-las ou escrever as tuas próprias sem tocares numa linha do código-fonte do Omarchy.

Os plugins oficiais vêm com o Omarchy e vivem em `$OMARCHY_PATH/shell/plugins/`. Tudo o que adicionares tu próprio — as tuas próprias experiências, ou alguma coisa que encontraste no GitHub — vive em `~/.config/omarchy/plugins/`. Ambos são descobertos da mesma forma no arranque, mas os integrados recebem interfaces de shell fidedignas, enquanto os plugins de terceiros recebem uma interface limitada, circunscrita ao seu próprio serviço e ciclo de vida. Os clones de integrados mantêm apenas a configuração específica da fonte e as chamadas de interface necessárias para o comportamento original.

## Ver o que tens

```
omarchy plugin list
```

Isso imprime todos os plugins descobertos com o seu id, se está ativado, se é oficial ou de terceiros, os seus tipos e o seu nome de apresentação. Adiciona `--json` se o estiveres a alimentar a outra coisa qualquer.

Os id dos plugins têm espaço de nomes. Os integrados começam todos por `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — e esse espaço de nomes está reservado, por isso um plugin de terceiros nunca o pode reclamar.

## Ligá-los e desligá-los

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Ou usa o menu: _Configurar > Plugins_ tem Ativar plugin, Desativar plugin, Adicionar plugin, Clonar plugin e Remover plugin, cada um com um seletor que só oferece os plugins que fazem sentido para essa ação.

O estado ativado está guardado em `~/.config/omarchy/shell.json`, e a regra difere ligeiramente para os dois tipos de plugin. Um plugin de terceiros está ativado exatamente quando o seu id aparece em algum lugar nesse ficheiro — como uma entrada de disposição da barra, como uma entrada em `plugins[]`, ou como `bar.id`. Os plugins oficiais que não são widgets da barra são ao contrário: estão ligados por predefinição e só se desligam ao serem listados em `disabledPlugins[]`.

Um plugin de barra completo não tem estado desligado de todo. Há sempre exatamente uma barra, por isso substituí-la é ativar outra. A colocação de widgets na barra é abordada em [a barra superior](05-the-top-bar.md).

## Adicionar um plugin a partir do git

Um plugin de terceiros é apenas um repositório git com um `manifest.json` na sua raiz.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Antes de fazer seja o que for, diz-te claramente que os plugins correm como código arbitrário, sem isolamento, dentro do teu processo de shell de longa duração, mostra-te o URL e pede-te para confirmares. Leva isso a sério. A interface de plugins de terceiros não expõe diretamente serviços de autenticação, e uma barra de substituição recebe apenas capacidades limitadas para a interface configurada que não seja de autenticação. Os plugins visuais continuam a partilhar a cena QML da shell e podem percorrer objetos pai normais, enquanto todo o código dos plugins corre com tudo aquilo a que a tua conta de utilizador consegue chegar. O estado de autenticação está protegido em separado, mantendo esses serviços fora do grafo de objetos do anfitrião acessível. Só adiciona repositórios que estejas disposto a correr, e lê-os antes de os ativares.

Uma barra de substituição pode renderizar widgets instalados, mas os widgets de terceiros apoiados em serviços podem ter funcionalidade reduzida aí, porque a barra não está autorizada a pedir o objeto de serviço ativo de outro plugin. Volta à `omarchy.bar` integrada se um widget desses precisar do seu serviço companheiro.

Depois, clona o repositório para um diretório de preparação, valida o manifesto, recusa a instalação se outro plugin já reclamar esse id e move-o para `~/.config/omarchy/plugins/<id>/`. Sem `--enable`, pergunta se o queres ligado já, e podes dizer que não e ir ler o código primeiro. Nunca corre nada do plugin, nunca executa um hook de instalação e nunca pede sudo — clona ficheiros, verifica o manifesto e inverte um bit por IPC.

Atualizar é fazer um pull em avanço rápido desse mesmo checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Sem id, atualiza todos os plugins geridos por git que tiveres. Mostra-te a diferença antes de a aplicar, recusa-se a atualizar se tiveres alterações locais que ele não consiga ultrapassar em avanço rápido e reverte se a nova revisão falhar a validação.

```
omarchy plugin remove acme.weather
```

A remoção desativa primeiro o plugin e depois apaga-o, se for um checkout git (o repositório continua a montante), ou desliga-o, se for uma ligação simbólica. Uma pasta de plugin feita à mão, sem repositório git, é movida para uma cópia de segurança com carimbo temporal dentro do diretório de plugins, em vez de ser apagada de imediato.

## Clonar um integrado para o modificar

Esta é a minha parte favorita. Se quiseres alterar a forma como um widget integrado se comporta, não edites os ficheiros em `$OMARCHY_PATH` — esses pertencem ao pacote e a próxima atualização substitui-os. Clona-o antes:

```
omarchy plugin clone omarchy.clock
```

Isso copia o plugin inteiro para `~/.config/omarchy/plugins/dhh.clock` (o teu nome de utilizador, não o meu), muda-lhe o nome para «My Clock», ativa-o e muda a shell do integrado para a tua cópia — mantendo a posição e as definições de um widget da barra existente. Adiciona `--edit` para abrires o novo diretório no teu `$EDITOR` de imediato, que é o que o _Configurar > Plugins > Clonar plugin_ do menu faz por ti.

O prefixo do nome de utilizador mantém o id do teu clone como teu, por isso partilhá-lo não colide com o de mais ninguém. As chamadas feitas ao id integrado original são encaminhadas para o teu clone, por isso nada do que se referia a `omarchy.clock` precisa de ser atualizado. E, se fizeres uma confusão com ele, `omarchy plugin remove dhh.clock` repõe o integrado.

Guardar um ficheiro em qualquer lugar de `~/.config/omarchy/plugins/` recarrega automaticamente o código do plugin, por isso podes deixar o editor aberto e ver as tuas alterações a aterrar.

## Escrever o teu próprio

Um plugin é um diretório com um `manifest.json` e algum QML. O manifesto declara `schemaVersion: 1`, um `id`, `name`, `version`, um ou mais `kinds` e um objeto `entryPoints` que aponta para o ficheiro QML de cada tipo:

| Tipo | O que é |
|------|------------|
| `bar-widget` | Um componente que a barra ativa pode largar numa secção |
| `panel` | Uma janela flutuante persistente ou invocada |
| `overlay` | Uma sobreposição em ecrã inteiro |
| `menu` | Uma superfície de menu invocada |
| `service` | Um singleton sem interface e sem UI |
| `bar` | Uma barra completa que substitui a integrada |

Um plugin pode declarar vários tipos ao mesmo tempo — o plugin de multimédia é, ao mesmo tempo, um `service` e um `bar-widget`. Os widgets da barra recebem um bloco `barWidget` extra com um nome de apresentação, uma categoria, um `defaultSection` opcional e `allowMultiple`, que diz se faz sentido ter mais do que um na barra. A maioria dos widgets define-o como `false`; os espaçadores e os indicadores definem-no como `true`.

Antes de publicares seja o que for, verifica-o:

```
omarchy plugin validate ./my-plugin
```

Isso executa as mesmas verificações que a shell faz ao carregar: a versão do esquema, os campos obrigatórios, um id que não esteja reservado, pontos de entrada que sejam caminhos relativos seguros e que realmente existam, um ponto de entrada para cada tipo que reclamaste e nenhuma ligação simbólica em parte alguma dentro da pasta.

Para desenvolvimento de plugins, vê a [referência da shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) e o [catálogo de plugins oficiais](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Partilhar o teu com o mundo

Depois de fazeres alguma coisa de que gostes, coloca-a num repositório git público. É esse todo o mecanismo de distribuição — qualquer pessoa pode então executar `omarchy plugin add` contra o teu URL e tê-lo a correr em segundos.

Para ajudares as pessoas a encontrarem-no realmente, lista-o em [plugins.omarchy.org](https://plugins.omarchy.org). É o mercado de plugins da shell do Omarchy, e é o primeiro lugar onde procurar quando estiveres a pensar se alguém já construiu o widget que estás prestes a escrever. Explora-o antes de começares!
