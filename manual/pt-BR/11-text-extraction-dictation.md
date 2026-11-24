# Extração de Texto e Ditado

### Extração de Texto

Pressione `Super + Ctrl + PrtScr` para selecionar uma região na tela para extração de texto. O modelo de OCR de código aberto tesseract converterá rapidamente essa seleção em texto e a colocará na área de transferência. Depois, é só pressionar `Super + V` para colar.

Isso é muito útil para pegar endereços em rodapés de imagens ou números de telefone incorporados em títulos de sites.

 ![text-extraction](images/text-extraction.webp)

### Ditado

Em instalações novas, o [Superwhisper](https://superwhisper.com/) é o backend de ditado padrão, usando processamento em nuvem sem downloads de modelos offline. Escolha Superwhisper, [Voxtype](https://voxtype.io/) ou [Hex](https://anoma.ly/hex/) em _Setup > Defaults > Dictation_ no menu do Omarchy. Selecionar um backend o instala, se necessário, e o torna o padrão para o ditado. O Voxtype carrega um modelo básico em inglês que ocupa 150MB; altere o modelo com `voxtype setup model` e outras configurações em `~/.config/voxtype/config.toml`. O Superwhisper abre suas configurações para escolher entre processamento em nuvem ou local, e o OPR mantém o aplicativo atualizado. O Hex baixa seu modelo de fala no dispositivo durante a configuração e roda como o serviço de usuário `hex.service`; abra sua janela pelo ícone na bandeja da barra ou executando `hex` para alterar o modelo e outras configurações.

Você dita mantendo pressionado `Right Alt`, ou alternando com `Alt + Space`, e o texto ditado aparecerá na área de entrada em foco. Esses atalhos usam o backend selecionado. O Right Alt também inicia o ditado quando usado em uma combinação de modificadores; use o Left Alt para essas combinações. Em layouts de teclado em que o Right Alt é AltGr, incluindo quando esse layout é um para o qual você alterna, mantenha-o pressionado sozinho por um momento para ditar; o AltGr pressionado junto com outra tecla ainda digita seu caractere. Instalações anteriores a quando o Alt + Space se tornou o padrão mantêm `F9` para push-to-talk e `Super + Ctrl + X` para alternar, adicionados a `~/.config/hypr/bindings.lua`, onde esse `Super + Ctrl + X` ocupa o lugar do painel de agentes; remova-os lá para devolver essas teclas aos aplicativos e ao painel.

Os mesmos atalhos funcionam com todos os backends. Selecione seu backend em Setup > Defaults > Dictation. O instalador do backend o configura e salva a seleção. Execute `omarchy default dictation` para ver qual está selecionado. A seleção é salva em `~/.config/omarchy/defaults/dictation`. Instalações novas selecionam o Superwhisper automaticamente.

O Omarchy carrega automaticamente a integração com a área de trabalho do backend selecionado. Nenhuma configuração do Superwhisper é necessária em `~/.config/hypr/`.

Bindings e scripts personalizados podem usar `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. O backend selecionado cuida da gravação e da transcrição. Selecionar o Superwhisper desativa seu atalho nativo de manter pressionado e define seu alternador nativo para `Ctrl + Alt + Space`, mantendo-o separado das teclas de gravação do Omarchy. O Superwhisper exige pelo menos um atalho nativo de gravação, e seu atalho de cancelamento continua disponível.

Backends adicionais podem se integrar sem alterar o Omarchy. Forneça um executável chamado `omarchy-dictation-<backend>` no PATH que aceite `start`, `stop` e `toggle` e retorne prontamente, com um status diferente de zero em caso de falha. Seu instalador configura o provedor e chama `omarchy-dictation-use <backend>` após uma configuração bem-sucedida. Isso interrompe o backend anterior e salva a seleção de forma atômica; `stop` deve ter sucesso quando o provedor estiver ocioso ou indisponível. Os nomes dos backends usam letras minúsculas, dígitos e hífens. Forneça `omarchy-install-dictation-<backend>` para a configuração; `omarchy default dictation <backend>` o inicia. Adicione uma entrada no menu Defaults por meio de uma extensão do menu do Omarchy para chamar esse seletor. A integração opcional com a área de trabalho pode ficar em `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
