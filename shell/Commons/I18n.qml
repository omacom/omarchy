pragma Singleton
import QtQuick
import Quickshell

QtObject {
  id: root

  readonly property string systemLocale: String(Quickshell.env("LANG") || Qt.locale().name || "")
  readonly property bool isPtBr: systemLocale.indexOf("pt_BR") !== -1 || systemLocale.indexOf("pt-BR") !== -1

  readonly property var ptBrDictionary: ({
    // Ações comuns
    "Cancel": "Cancelar",
    "Confirm": "Confirmar",
    "OK": "OK",
    "Close": "Fechar",
    "Save": "Salvar",
    "Delete": "Excluir",
    "Yes": "Sim",
    "No": "Não",
    "Search": "Buscar",
    "Apply": "Aplicar",
    "Remove": "Remover",
    "Add": "Adicionar",
    "Enable": "Ativar",
    "Disable": "Desativar",

    // Estados e Conexões
    "Connected": "Conectado",
    "Disconnected": "Desconectado",
    "No connection": "Sem conexão",
    "Scanning...": "Buscando redes...",
    "Available": "Disponível",
    "Unavailable": "Indisponível",
    "Charging": "Carregando",
    "Discharging": "Descarregando",
    "Battery": "Bateria",
    "Battery state": "Status da bateria",
    "AC connected": "Conectado à energia",
    "Mute": "Silenciar",
    "Unmute": "Ativar som",
    "Paired": "Pareado",
    "Pairing": "Pareando",

    // Outros termos de interface
    "Settings": "Configurações",
    "Fingerprint reader unavailable": "Leitor de impressão digital indisponível"
  })

  function t(text) {
    if (!text) return ""
    if (root.isPtBr && root.ptBrDictionary.hasOwnProperty(text)) {
      return root.ptBrDictionary[text]
    }
    return text
  }
}
