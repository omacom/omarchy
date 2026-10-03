#include <QQmlExtensionPlugin>
#include <qqml.h>
#include "search_model.h"

// Directory-local module: register the URI supplied by this relative import.
class ShortcutSearchPlugin : public QQmlExtensionPlugin {
  Q_OBJECT
  Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
  void registerTypes(const char *uri) override { qmlRegisterType<SearchModel>(uri, 1, 0, "SearchModel"); }
};
#include "plugin.moc"
