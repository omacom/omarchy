#pragma once
#include <QAbstractListModel>
#include <QHash>
#include <QStringList>
#include <QVector>

class SearchModel : public QAbstractListModel {
  Q_OBJECT
  Q_PROPERTY(int count READ count NOTIFY metricsChanged)
  Q_PROPERTY(int detailCount READ detailCount NOTIFY metricsChanged)
  Q_PROPERTY(int sectionCount READ sectionCount NOTIFY metricsChanged)
public:
  explicit SearchModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}
  enum Role { Label = Qt::UserRole + 1, Detail, Value, Section, SourceIndex, LabelHtml, DetailHtml };
  int rowCount(const QModelIndex &parent = {}) const override;
  QVariant data(const QModelIndex &index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;
  int count() const { return int(rows_.size()); }
  int detailCount() const { return detailCount_; }
  int sectionCount() const { return sectionCount_; }
  Q_INVOKABLE void reset(const QStringList &options);
  Q_INVOKABLE void filter(const QString &query);
  Q_INVOKABLE QString value(int row) const;
  Q_INVOKABLE QStringList labels() const;
  Q_INVOKABLE QVariantMap get(int row) const;
  // Diagnostic API also exercises the same lazy formatting used by the view.
  Q_INVOKABLE QVariantList snapshot() const;

signals:
  void metricsChanged();

private:
  struct Token { QString text, key; int start = 0, length = 0; };
  struct Entry {
    QString label, detail, value, descriptionLower, detailLower;
    QHash<QString, Token> keys;
    int descriptionStart = 0, keyCount = 0;
    mutable quint64 formattedGeneration = 0;
    mutable QString labelHtml, detailHtml;
  };
  struct Match {
    bool found = false;
    int quality = 0, penalty = 0;
    QVector<int> positions;
  };
  struct Row { int sourceIndex = 0, score = 0, penalty = 0, section = 0; };
  static QString keyName(const QString &name);
  static QVector<Token> tokenize(const QString &text, bool deduplicate);
  static Match textMatch(const QString &term, const QString &lower, bool decorate);
  static QString highlight(const QString &text, const QVector<int> &positions);
  static QString sectionName(int section);
  bool matchEntry(const Entry &entry, Row &row, bool decorate) const;
  void applyFilter(const QString &query, bool force = false);
  void ensureFormatted(const Row &row) const;
  const Entry *entryAt(int row) const;
  QStringList options_;
  QVector<Entry> entries_;
  QVector<Token> terms_;
  QVector<Row> rows_, scratch_;
  QString query_;
  bool initialized_ = false;
  quint64 generation_ = 1;
  int detailCount_ = 0, sectionCount_ = 0;
};
