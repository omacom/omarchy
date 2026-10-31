# Extração de Texto e Ditado

### Extração de Texto

Pressione `Super + Ctrl + PrtScr` para selecionar uma região da tela para extração de texto. O modelo de OCR de código aberto tesseract converterá então rapidamente essa seleção em texto e a colocará na área de transferência. Depois é só pressionar `Super + V` para colar.

Isso é muito útil para pegar endereços de rodapés de imagens ou números de telefone embutidos em títulos de sites.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado padrão, usando processamento em nuvem sem downloads de modelos offline. Escolha Superwhisper ou [Voxtype](https://voxtype.io/) em _Configuração > Padrões > Ditado_ no menu do Omarchy. Selecionar um backend o instala, se necessário, e o torna o padrão para ditado. O Voxtype carrega um modelo base em inglês que ocupa 150 MB; altere o modelo com `voxtype setup model` e outras configurações em `~/.config/voxtype/config.toml`. O Superwhisper abre suas configurações para escolher processamento em nuvem ou local, e o OPR mantém o aplicativo atualizado.

Você dita segurando `Right Alt` ou `F9`, ou alternando com `Super + Ctrl + X`, e o texto ditado aparecerá na área de entrada focada. Esses atalhos usam o backend selecionado. O Right Alt também inicia o ditado quando usado em um acorde de modificadores; use o Left Alt para esses acordes. Em layouts de teclado em que o Right Alt é AltGr, use `F9` para manter o AltGr disponível para digitar.

Os mesmos atalhos funcionam com qualquer backend. Selecione seu backend em Configuração > Padrões > Ditado. O instalador do backend o configura e salva a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção é salva em `~/.config/omarchy/defaults/dictation`. Instalações novas selecionam o Superwhisper automaticamente.

O Omarchy carrega automaticamente a integração de desktop do backend selecionado. Nenhuma configuração do Superwhisper é necessária em `~/.config/hypr/`.

Atalhos e scripts personalizados podem usar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado cuida da gravação e da transcrição. Selecionar o Superwhisper desativa seu atalho nativo de segurar e define sua alternância nativa para `Alt + Space`, mantendo-a separada das teclas de gravação do Omarchy. O Superwhisper exige pelo menos um atalho nativo de gravação, e seu atalho de cancelamento continua disponível.

Backends adicionais podem se integrar sem alterar o Omarchy. Forneça um executável chamado `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e retorne prontamente, com um status diferente de zero em caso de falha. Seu instalador configura o provedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isso interrompe o backend anterior e salva a seleção de forma atômica; `stop` deve ter sucesso quando o provedor estiver ocioso ou indisponível. Nomes de backend usam letras minúsculas, dígitos e hífens. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` o inicia. Adicione uma entrada no menu Padrões por meio de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com o desktop pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
