#pragma once
#include <QSqlDatabase>
#include <QVariantList>

class Names {
public:
  Names();
  ~Names();
  QString bind(const QStringList &models, const QString &model, const QString &identity);
  QVariantList sync(const QString &reader, const QStringList &enrolled, bool prune = true);
  void rename(const QString &reader, const QString &slot, const QString &name);
private:
  QSqlDatabase db;
  void open();
};
