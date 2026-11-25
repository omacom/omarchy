# Plug-ins do shell

A área de trabalho do Omarchy é executada como um único processo Quickshell de vida longa chamado `omarchy-shell`, e quase tudo o que você vê na tela é um plug-in dentro dele. A barra é um plug-in. Também são os painéis que descem dela, as sobreposições em tela cheia como o seletor de emoji e o gerenciador de área de transferência, o próprio menu do Omarchy, a tela de bloqueio, a caixa de diálogo do polkit e os serviços sem interface que observam sua bateria e aquecem sua tela à noite.

Isso não é apenas um detalhe de implementação. Isso significa que você pode desligar partes da área de trabalho, trocá-las ou escrever as suas próprias sem tocar em uma linha do código-fonte do Omarchy.

Os plug-ins originais vêm com o Omarchy e ficam em `$OMARCHY_PATH/shell/plugins/`. Qualquer coisa que você adicione você mesmo — seus próprios experimentos, ou algo que você encontrou no GitHub — fica em `~/.config/omarchy/plugins/`. Os dois são descobertos da mesma maneira na inicialização, mas os integrados recebem interfaces de shell confiáveis, enquanto plug-ins de terceiros recebem uma interface limitada, restrita ao seu próprio serviço e ciclo de vida. Clones dos integrados mantêm apenas a configuração específica da fonte e as chamadas de interface necessárias para o comportamento original.

## Vendo o que você tem

```
omarchy plugin list
```

Isso imprime todos os plug-ins descobertos, com seu id, se está ativado, se é original ou de terceiros, seus tipos e seu nome de exibição. Adicione `--json` se você for alimentá-lo em outra coisa.

Os ids dos plug-ins têm namespaces. Os integrados todos começam com `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — e esse namespace é reservado, então um plug-in de terceiros nunca poderá reivindicá-lo.

## Ligando-os e desligando-os

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Ou use o menu: _Setup > Plugins_ tem Ativar, Desativar, Adicionar, Clonar e Remover, cada um com um seletor que só oferece os plug-ins que fazem sentido para aquela ação.

O estado ativado é armazenado em `~/.config/omarchy/shell.json`, e a regra difere ligeiramente para os dois tipos de plug-in. Um plug-in de terceiros é ativado exatamente quando seu id aparece em algum lugar desse arquivo — como uma entrada do layout da barra, como uma entrada em `plugins[]`, ou como `bar.id`. Plug-ins originais que não são widgets da barra são o contrário: eles estão ligados por padrão e só desligam ao serem listados em `disabledPlugins[]`.

Um plug-in de barra completa não tem nenhum estado desligado. Sempre há exatamente uma barra, então você a substitui ativando outra. A colocação de widgets na barra é coberta em [a barra superior](05-the-top-bar.md).

## Adicionando um plug-in do git

Um plug-in de terceiros é apenas um repositório git com um `manifest.json` na sua raiz.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Antes de fazer qualquer coisa, ele lhe diz simplesmente que plug-ins são executados como código arbitrário, sem sandbox, dentro do seu processo de shell de vida longa, mostra a URL e pede sua confirmação. Leve isso a sério. A interface de plug-ins de terceiros não expõe serviços de autenticação diretamente, e uma barra substituta recebe apenas capacidades limitadas para a interface configurada sem autenticação. Plug-ins visuais ainda compartilham a cena QML do shell e podem percorrer objetos pais comuns, enquanto todo o código de plug-in é executado com tudo o que sua conta de usuário pode alcançar. O estado de autenticação é protegido separadamente, mantendo esses serviços fora do grafo de objetos alcançável do host. Só adicione repositórios que você esteja disposto a executar, e leia-os antes de ativá-los.

Uma barra substituta pode renderizar widgets instalados, mas widgets de terceiros respaldados por serviços podem ter funcionalidade reduzida ali, porque a barra não tem permissão para solicitar o objeto de serviço ativo de outro plug-in. Volte para o `omarchy.bar` integrado se esse widget precisar do seu serviço complementar.

Depois ele clona o repositório para um diretório de preparação, valida o manifesto, recusa a instalação se outro plug-in já reivindicar aquele id e o move para `~/.config/omarchy/plugins/<id>/`. Sem `--enable`, ele pergunta se você quer que ele esteja ligado agora, e você pode dizer não e ir ler o código primeiro. Ele nunca executa nada do plug-in, nunca executa um gancho de instalação e nunca pede sudo — ele clona arquivos, verifica o manifesto e inverte um bit via IPC.

A atualização é um pull com fast-forward desse mesmo checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Sem nenhum id, ele atualiza todos os plug-ins gerenciados pelo git que você tem. Ele mostra o diff antes de aplicá-lo, recusa a atualização se você tiver alterações locais pelas quais não consiga fazer fast-forward e faz rollback se a nova revisão falhar na validação.

```
omarchy plugin remove acme.weather
```

A remoção desativa o plug-in primeiro e depois o exclui se for um checkout git (o repositório ainda está no upstream) ou o desvincula se for um link simbólico. Uma pasta de plug-in feita à mão sem nenhum repositório git é movida para um backup com marca de tempo dentro do diretório de plug-ins em vez de ser excluída diretamente.

## Clonando um integrado para modificá-lo

Esta é minha parte favorita. Se você quiser alterar como um widget integrado se comporta, não edite os arquivos em `$OMARCHY_PATH` — eles pertencem ao pacote e a próxima atualização os sobrescreverá. Clone-o:

```
omarchy plugin clone omarchy.clock
```

Isso copia todo o plug-in para `~/.config/omarchy/plugins/dhh.clock` (seu nome de usuário, não o meu), renomeia-o para "My Clock", ativa-o e muda o shell do integrado para a sua cópia — mantendo a posição e as configurações de um widget de barra existente. Adicione `--edit` para abrir o novo diretório no seu `$EDITOR` imediatamente, que é o que o _Setup > Plugins > Clone Plugin_ do menu faz por você.

O prefixo de nome de usuário mantém o id do seu clone seu, então compartilhá-lo não colide com o de mais ninguém. As chamadas feitas para o id integrado original são roteadas para o seu clone, então nada que se referia a `omarchy.clock` precisa ser atualizado. E se você fizer uma bagunça, `omarchy plugin remove dhh.clock` coloca o integrado de volta.

Salvar um arquivo em qualquer lugar sob `~/.config/omarchy/plugins/` recarrega o código do plug-in automaticamente, então você pode deixar o editor aberto e ver suas alterações acontecerem.

## Escrevendo o seu próprio

Um plug-in é um diretório com um `manifest.json` e algum QML. O manifesto declara `schemaVersion: 1`, um `id`, `name`, `version`, um ou mais `kinds`, e um objeto `entryPoints` apontando para o arquivo QML de cada tipo:

| Tipo | O que é |
|------|------------|
| `bar-widget` | Um componente que a barra ativa pode colocar em uma seção |
| `panel` | Uma janela flutuante persistente ou invocada |
| `overlay` | Uma sobreposição em tela cheia |
| `menu` | Uma superfície de menu invocada |
| `service` | Um singleton sem interface e sem UI |
| `bar` | Uma barra completa que substitui a integrada |

Um plug-in pode declarar vários tipos ao mesmo tempo — o plug-in de mídia é ao mesmo tempo um `service` e um `bar-widget`. Widgets de barra ganham um bloco `barWidget` extra com um nome de exibição, uma categoria, um `defaultSection` opcional e `allowMultiple`, que diz se faz sentido ter mais de um na barra. A maioria dos widgets define isso como `false`; espaçadores e indicadores definem como `true`.

Antes de publicar qualquer coisa, verifique-a:

```
omarchy plugin validate ./my-plugin
```

Isso executa as mesmas verificações que o shell faz no momento do carregamento: a versão do esquema, os campos obrigatórios, um id que não é reservado, pontos de entrada que são caminhos relativos seguros e que realmente existem, um ponto de entrada para cada tipo que você declarou, e nenhum link simbólico em nenhum lugar dentro da pasta.

Para o desenvolvimento de plug-ins, consulte a [referência do shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) e o [catálogo de plug-ins originais](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Compartilhando o seu com o mundo

Depois que você fizer algo de que goste, coloque-o em um repositório git público. Esse é todo o mecanismo de distribuição — qualquer pessoa pode então executar `omarchy plugin add` com sua URL e tê-lo em execução em segundos.

Para ajudar as pessoas a realmente encontrá-lo, liste-o em [plugins.omarchy.org](https://plugins.omarchy.org). Esse é o mercado de plug-ins do shell do Omarchy, e é o primeiro lugar a procurar quando você estiver se perguntando se alguém já criou o widget que você está prestes a escrever. Navegue por ele antes de começar!
