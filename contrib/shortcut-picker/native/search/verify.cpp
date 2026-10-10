#include "search_model.h"
#include <QAbstractItemModelTester>
#include <QCoreApplication>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJSEngine>
#include <QTextStream>
#include <cstdio>

int main(int argc, char **argv) {
  QCoreApplication application(argc, argv);
  if (argc != 3) return 2;
  QFile fixtureFile(QString::fromLocal8Bit(argv[1])), oracleFile(QString::fromLocal8Bit(argv[2]));
  if (!fixtureFile.open(QIODevice::ReadOnly) || !oracleFile.open(QIODevice::ReadOnly)) return 2;
  const auto fixture = QJsonDocument::fromJson(fixtureFile.readAll()).object();
  QJSEngine js;
  auto evaluated = js.evaluate(QString::fromUtf8(oracleFile.readAll()), QStringLiteral("Oracle.js"));
  if (evaluated.isError()) { qCritical() << evaluated.toString(); return 1; }
  auto prepare = js.globalObject().property(QStringLiteral("prepare"));
  auto terms = js.globalObject().property(QStringLiteral("terms"));
  auto filter = js.globalObject().property(QStringLiteral("filterPrepared"));
  SearchModel model;
  QAbstractItemModelTester tester(&model, QAbstractItemModelTester::FailureReportingMode::Fatal);
  int comparisons = 0;
  for (const auto &datasetValue : fixture["datasets"].toArray()) {
    const auto dataset = datasetValue.toObject();
    const auto options = dataset["options"].toArray().toVariantList();
    QStringList strings;
    for (const auto &option : options) strings.append(option.toString());
    model.reset(strings);
    const auto prepared = prepare.call({js.toScriptValue(options)});
    for (const auto &query : dataset["queries"].toArray()) {
      const QString text = query.toString();
      model.filter(text);
      const auto expected = filter.call({prepared, terms.call({QJSValue(text)}), QJSValue(true)});
      if (expected.isError()) { qCritical() << expected.toString(); return 1; }
      const auto actualJson = QJsonDocument::fromVariant(model.snapshot());
      const auto expectedJson = QJsonDocument::fromVariant(expected.toVariant());
      if (actualJson != expectedJson) {
        qCritical() << "Mismatch query" << text;
        QFile actual(QStringLiteral("/tmp/native-search-actual.json"));
        QFile wanted(QStringLiteral("/tmp/native-search-expected.json"));
        if (actual.open(QIODevice::WriteOnly)) actual.write(actualJson.toJson());
        if (wanted.open(QIODevice::WriteOnly)) wanted.write(expectedJson.toJson());
        return 1;
      }
      int details = 0, sections = 0;
      QString previous;
      for (int i = 0; i < model.count(); ++i) {
        const auto row = model.get(i);
        if (!row["detail"].toString().isEmpty()) ++details;
        const QString section = row["section"].toString();
        if (!section.isEmpty() && section != previous) ++sections;
        previous = section;
        if (model.value(i) != row["value"].toString()) return 1;
      }
      if (details != model.detailCount() || sections != model.sectionCount()
        || !model.get(-1).isEmpty() || !model.get(model.count()).isEmpty()
        || !model.value(-1).isEmpty() || !model.value(model.count()).isEmpty()) return 1;
      ++comparisons;
    }
  }
  QTextStream(stdout) << "PASS: " << comparisons << " native searches match the QML JavaScript oracle exactly; model invariants and selection values pass.\n";
}
