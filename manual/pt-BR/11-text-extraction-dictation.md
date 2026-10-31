# Extração de Texto e Ditado

### Extração de Texto

Pressione `Super + Ctrl + PrtScr` para selecionar uma região da tela para extração de texto. O modelo OCR de código aberto tesseract converterá rapidamente essa seleção em texto e o colocará na área de transferência. Depois, basta pressionar `Super + V` para colar.

Isso é muito útil para capturar endereços em rodapés de imagens ou números de telefone incorporados em títulos de sites.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado padrão, usando processamento em nuvem sem downloads de modelos offline. Escolha Superwhisper ou [Voxtype](https://voxtype.io/) em _Setup > Defaults > Dictation_ no menu do Omarchy. Selecionar um backend o instala, se necessário, e o torna o padrão para o ditado. O Voxtype carrega um modelo básico em inglês que ocupa 150MB; altere o modelo com `voxtype setup model` e outras configurações em `~/.config/voxtype/config.toml`. O Superwhisper abre suas configurações para escolher entre processamento em nuvem ou local, e o OPR mantém o aplicativo atualizado.

Você dita segurando `Right Alt`, ou alternando com `Alt + Space`, e o texto ditado aparecerá na área de entrada em foco. Esses atalhos usam o backend selecionado. O Right Alt também inicia o ditado quando usado em uma combinação de modificadores; use Left Alt para essas combinações. Em layouts de teclado em que Right Alt é AltGr, use `Alt + Space` para manter o AltGr disponível para digitação. Instalações anteriores à adoção do Alt + Space como padrão mantêm `F9` para push-to-talk e `Super + Ctrl + X` para alternar, adicionados a `~/.config/hypr/bindings.lua`; remova-os de lá para devolver essas teclas aos aplicativos.

Os mesmos atalhos funcionam com qualquer backend. Selecione seu backend em Setup > Defaults > Dictation. O instalador do backend o configura e salva a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção é salva em `~/.config/omarchy/defaults/dictation`. Instalações novas selecionam o Superwhisper automaticamente.

O Omarchy carrega automaticamente a integração com o desktop do backend selecionado. Nenhuma configuração do Superwhisper é necessária em `~/.config/hypr/`.

Atalhos personalizados e scripts podem usar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado cuida da gravação e da transcrição. Selecionar o Superwhisper desativa seu atalho nativo de segurar e define sua alternância nativa como `Ctrl + Alt + Space`, mantendo-a separada das teclas de gravação do Omarchy. O Superwhisper exige pelo menos um atalho nativo de gravação, e seu atalho de cancelamento permanece disponível.

Backends adicionais podem se integrar sem alterar o Omarchy. Forneça um executável chamado `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e retorne prontamente, com um status diferente de zero em caso de falha. Seu instalador configura o provedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isso interrompe o backend anterior e salva a seleção de forma atômica; `stop` deve ser bem-sucedido quando o provedor estiver ocioso ou indisponível. Os nomes dos backends usam letras minúsculas, dígitos e hífens. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` o inicia. Adicione uma entrada ao menu Defaults por meio de uma extensão de menu do Omarchy para chamar esse seletor. A integração opcional com o desktop pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
