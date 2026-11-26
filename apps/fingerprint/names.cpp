#include "names.h"
#include "reader.h"
#include <QDir>
#include <QFile>
#include <QSet>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QUuid>
#include <fcntl.h>
#include <unistd.h>
#include <stdexcept>

namespace {
QSqlQuery run(const QSqlDatabase &db, const QString &sql, const QVariantList &args = {}) {
  QSqlQuery q(db);
  if (!q.prepare(sql)) throw std::runtime_error(q.lastError().text().toStdString());
  for (const auto &arg : args) q.addBindValue(arg);
  if (!q.exec()) throw std::runtime_error(q.lastError().text().toStdString());
  return q;
}
struct Transaction {
  QSqlDatabase &db;
  explicit Transaction(QSqlDatabase &db) : db(db) { run(db, "BEGIN IMMEDIATE"); }
  ~Transaction() { if (!committed) db.rollback(); }
  void commit() { run(db, "COMMIT"); committed = true; }
  bool committed = false;
};
}
Names::Names() : db(QSqlDatabase::addDatabase("QSQLITE", QUuid::createUuid().toString())) {}
Names::~Names() {
  const auto connection = db.connectionName();
  db = {};
  QSqlDatabase::removeDatabase(connection);
}
void Names::open() {
  if (db.isOpen()) return;
  const auto dir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/omarchy";
  const auto file = dir + "/fingerprint-names.sqlite3";
  if (!QDir().mkpath(dir)) throw std::runtime_error("Could not open the fingerprint names directory.");
  int fd = ::open(QFile::encodeName(file).constData(), O_CREAT | O_RDWR | O_CLOEXEC, 0600);
  if (fd < 0) throw std::runtime_error("Could not open the fingerprint names file.");
  ::close(fd);
  db.setDatabaseName(file);
  if (!db.open()) throw std::runtime_error(db.lastError().text().toStdString());
}
QString Names::bind(const QStringList &models, const QString &model, const QString &identity) {
  open();
  Transaction tx(db);
  run(db, "CREATE TABLE IF NOT EXISTS names (reader TEXT, slot TEXT, number INTEGER, name TEXT, PRIMARY KEY(reader,slot), UNIQUE(reader,number))");
  run(db, "CREATE TABLE IF NOT EXISTS models (model TEXT PRIMARY KEY, incumbent TEXT, twins INTEGER)");
  const QSet<QString> distinct(models.begin(), models.end());
  for (const auto &name : distinct)
    if (models.count(name) > 1)
      run(db, "INSERT INTO models VALUES (?,NULL,1) ON CONFLICT(model) DO UPDATE SET twins=1 WHERE twins=0", {name});
  auto q = run(db, "SELECT incumbent,twins FROM models WHERE model=?", {model});
  const bool found = q.next();
  const bool twins = found && q.value(1).toBool();
  const auto incumbent = found ? q.value(0).toString() : QString();
  q.finish();
  if (!twins && (!found || incumbent != identity))
    run(db, "INSERT OR REPLACE INTO models VALUES (?,?,0)", {model, identity});
  tx.commit();
  return twins && incumbent != identity ? model + "|" + identity : model;
}
QVariantList Names::sync(const QString &reader, const QStringList &enrolled, bool prune) {
  Transaction tx(db);
  QSet<int> used;
  QSet<QString> saved;
  auto q = run(db, "SELECT slot,number FROM names WHERE reader=?", {reader});
  QStringList stale;
  while (q.next()) {
    auto slot = q.value(0).toString();
    if (prune && !enrolled.contains(slot)) stale << slot;
    else { used.insert(q.value(1).toInt()); saved.insert(slot); }
  }
  q.finish();
  for (const auto &slot : stale) run(db, "DELETE FROM names WHERE reader=? AND slot=?", {reader, slot});
  QStringList order = Fprint::slotsInOrder();
  for (const auto &slot : enrolled) if (!order.contains(slot)) order << slot;
  for (const auto &slot : order) {
    if (!enrolled.contains(slot) || saved.contains(slot)) continue;
    int n = 1;
    while (used.contains(n)) ++n;
    run(db, "INSERT INTO names VALUES (?,?,?,NULL)", {reader, slot, n});
    used.insert(n);
  }
  QVariantList result;
  q = run(db, "SELECT slot,number,name FROM names WHERE reader=? ORDER BY number", {reader});
  while (q.next()) result << QVariantMap{{"slot", q.value(0)}, {"number", q.value(1)}, {"name", q.value(2).toString()}};
  q.finish();
  tx.commit();
  return result;
}
void Names::rename(const QString &reader, const QString &slot, const QString &name) {
  run(db, "UPDATE names SET name=? WHERE reader=? AND slot=?", {name, reader, slot});
}
