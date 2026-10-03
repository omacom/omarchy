#include "search_model.h"
#include <QSet>
#include <QVariantMap>
#include <algorithm>

namespace {
// ECMAScript /\s/ deliberately differs from QChar::isSpace() for U+0085.
bool separator(QChar ch) {
  const ushort c = ch.unicode();
  return c == '+' || (c >= 9 && c <= 13) || c == 0x20 || c == 0xa0 || c == 0x1680
    || (c >= 0x2000 && c <= 0x200a) || c == 0x2028 || c == 0x2029
    || c == 0x202f || c == 0x205f || c == 0x3000 || c == 0xfeff;
}
bool wordCharacter(QChar ch) {
  const ushort c = ch.unicode();
  return (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_';
}
void appendRange(QVector<int> &out, int start, int length) {
  for (int i = 0; i < length; ++i) out.append(start + i);
}
}

QString SearchModel::keyName(const QString &name) {
  if (name == QLatin1String("control")) return QStringLiteral("ctrl");
  if (name == QLatin1String("meta") || name == QLatin1String("win")) return QStringLiteral("super");
  if (name == QLatin1String("spacebar")) return QStringLiteral("space");
  if (name == QLatin1String("enter")) return QStringLiteral("return");
  if (name == QLatin1String("esc")) return QStringLiteral("escape");
  return name;
}

QVector<SearchModel::Token> SearchModel::tokenize(const QString &text, bool deduplicate) {
  QVector<Token> tokens;
  QSet<QString> seen;
  int pos = 0;
  while (pos < text.size()) {
    while (pos < text.size() && separator(text[pos])) ++pos;
    const int start = pos;
    while (pos < text.size() && !separator(text[pos])) ++pos;
    if (start == pos) break;
    const QString lower = text.mid(start, pos - start).toLower();
    const QString key = keyName(lower);
    if (deduplicate && seen.contains(key)) continue;
    if (deduplicate) seen.insert(key);
    tokens.append({lower, key, start, pos - start});
  }
  return tokens;
}

SearchModel::Match SearchModel::textMatch(const QString &term, const QString &lower, bool decorate) {
  Match result;
  const int first = int(lower.indexOf(term));
  for (int at = first; at >= 0; at = int(lower.indexOf(term, at + 1))) {
    const int end = at + int(term.size());
    if ((at == 0 || !wordCharacter(lower[at - 1])) && (end >= lower.size() || !wordCharacter(lower[end]))) {
      result.found = true;
      result.penalty = at;
      if (decorate) appendRange(result.positions, at, int(term.size()));
      return result;
    }
  }
  if (first >= 0) {
    result.found = true;
    result.quality = 1;
    result.penalty = first;
    if (decorate) appendRange(result.positions, first, int(term.size()));
    return result;
  }
  int next = 0, last = -1;
  for (int i = 0; i < lower.size() && next < term.size(); ++i) {
    if (lower[i] == term[next]) {
      if (decorate) result.positions.append(i);
      last = i;
      ++next;
    }
  }
  result.found = next == term.size();
  result.quality = 2;
  result.penalty = last + 1 - int(term.size());
  return result;
}

QString SearchModel::highlight(const QString &text, const QVector<int> &positions) {
  QVector<bool> marked(text.size(), false);
  for (int pos : positions) if (pos >= 0 && pos < marked.size()) marked[pos] = true;
  QString output;
  output.reserve(text.size() + positions.size() * 7);
  bool active = false;
  for (int i = 0; i < text.size(); ++i) {
    if (active != marked[i]) {
      active = marked[i];
      output += active ? QStringLiteral("<b><u>") : QStringLiteral("</u></b>");
    }
    switch (text[i].unicode()) {
    case '&': output += QLatin1String("&amp;"); break;
    case '<': output += QLatin1String("&lt;"); break;
    case '>': output += QLatin1String("&gt;"); break;
    case '"': output += QLatin1String("&quot;"); break;
    case ' ': output += QLatin1String("&nbsp;"); break;
    case '\t': output += QLatin1String("&nbsp;&nbsp;&nbsp;&nbsp;"); break;
    default: output += text[i];
    }
  }
  if (active) output += QLatin1String("</u></b>");
  return output;
}

QString SearchModel::sectionName(int section) {
  if (section == 1) return QStringLiteral("Shortcut matches");
  if (section == 2) return QStringLiteral("Description matches");
  return {};
}

bool SearchModel::matchEntry(const Entry &entry, Row &row, bool decorate) const {
  if (terms_.isEmpty()) {
    if (decorate) { entry.labelHtml.clear(); entry.detailHtml.clear(); }
    return true;
  }
  QVector<int> labelPositions, detailPositions;
  bool descriptionUsed = false;
  int quality = 0, penalty = 0;
  for (const auto &term : terms_) {
    auto key = entry.keys.constFind(term.key);
    if (key != entry.keys.cend()) {
      if (decorate) appendRange(labelPositions, key->start, key->length);
      continue;
    }
    const auto inLabel = textMatch(term.text, entry.descriptionLower, decorate);
    const auto inDetail = textMatch(term.text, entry.detailLower, decorate);
    const bool useDetail = inDetail.found && (!inLabel.found || inDetail.quality < inLabel.quality
      || (inDetail.quality == inLabel.quality && inDetail.penalty < inLabel.penalty));
    const auto &found = useDetail ? inDetail : inLabel;
    if (!found.found) return false;
    descriptionUsed = true;
    quality = std::max(quality, found.quality);
    penalty += found.penalty;
    if (decorate) {
      if (useDetail) detailPositions += found.positions;
      else for (int pos : found.positions) labelPositions.append(entry.descriptionStart + pos);
    }
  }
  const int extraKeys = std::max(0, entry.keyCount - int(terms_.size()));
  row.section = descriptionUsed ? 2 : 1;
  row.score = descriptionUsed ? 2 + quality : (extraKeys ? 1 : 0);
  row.penalty = descriptionUsed ? penalty : extraKeys;
  if (decorate) {
    entry.labelHtml = highlight(entry.label, labelPositions);
    entry.detailHtml = highlight(entry.detail, detailPositions);
  }
  return true;
}

void SearchModel::reset(const QStringList &options) {
  const bool changed = !initialized_ || options != options_;
  if (changed) {
    QVector<Entry> entries;
    entries.reserve(options.size());
    for (const auto &option : options) {
      auto parts = option.split(QLatin1Char('\t'), Qt::KeepEmptyParts);
      if (parts.size() > 1) parts.removeFirst();
      Entry entry;
      entry.label = parts.takeFirst();
      entry.detail = parts.join(QLatin1Char('\t'));
      entry.value = entry.detail.isEmpty() ? entry.label : entry.label + QLatin1Char('\t') + entry.detail;
      const int arrow = int(entry.label.indexOf(QChar(0x2192)));
      entry.descriptionStart = arrow < 0 ? int(entry.label.size()) : arrow + 1;
      const auto keys = tokenize(arrow < 0 ? entry.label : entry.label.left(arrow), false);
      entry.keyCount = int(keys.size());
      for (const auto &key : keys) if (!entry.keys.contains(key.key)) entry.keys.insert(key.key, key);
      entry.descriptionLower = entry.label.mid(entry.descriptionStart).toLower();
      entry.detailLower = entry.detail.toLower();
      entries.append(std::move(entry));
    }
    // Remove old indices before replacing their backing entries. Model
    // observers can read valid old data during rowsAboutToBeRemoved.
    if (!rows_.isEmpty()) {
      beginRemoveRows({}, 0, count() - 1);
      rows_.clear();
      endRemoveRows();
    }
    entries_ = std::move(entries);
    options_ = options;
    initialized_ = true;
  }
  applyFilter({}, changed);
}

void SearchModel::filter(const QString &query) { applyFilter(query); }
void SearchModel::applyFilter(const QString &query, bool force) {
  if (!force && query == query_) return;
  query_ = query;
  terms_ = tokenize(query, true);
  ++generation_;
  scratch_.clear();
  scratch_.reserve(entries_.size());
  for (int i = 0; i < entries_.size(); ++i) {
    Row row;
    row.sourceIndex = i;
    if (matchEntry(entries_[i], row, false)) scratch_.append(row);
  }
  std::sort(scratch_.begin(), scratch_.end(), [](const Row &a, const Row &b) {
    if (a.score != b.score) return a.score < b.score;
    if (a.penalty != b.penalty) return a.penalty < b.penalty;
    return a.sourceIndex < b.sourceIndex;
  });
  int details = 0, sections = 0, previous = 0;
  for (const auto &row : scratch_) {
    if (!entries_[row.sourceIndex].detail.isEmpty()) ++details;
    if (row.section && row.section != previous) ++sections;
    previous = row.section;
  }
  const int nextCount = int(scratch_.size());
  if (nextCount < count()) {
    beginRemoveRows({}, nextCount, count() - 1);
    rows_.resize(nextCount);
    endRemoveRows();
  }
  const int overlap = count();
  QVector<int> changes(overlap);
  for (int i = 0; i < overlap; ++i) {
    changes[i] = (rows_[i].sourceIndex != scratch_[i].sourceIndex ? 1 : 0)
      | (rows_[i].section != scratch_[i].section ? 2 : 0);
    rows_[i] = scratch_[i];
  }
  if (nextCount > overlap) {
    beginInsertRows({}, overlap, nextCount - 1);
    rows_.reserve(nextCount);
    for (int i = overlap; i < nextCount; ++i) rows_.append(scratch_[i]);
    endInsertRows();
  }
  // Notifying unchanged section/label roles makes ListView redo layout work.
  // Coalesce adjacent rows with the same changed roles into one notification.
  for (int start = 0; start < overlap;) {
    int end = start + 1;
    while (end < overlap && changes[end] == changes[start]) ++end;
    QList<int> roles{LabelHtml, DetailHtml};
    if (changes[start] & 1) roles.append({Label, Detail, Value, SourceIndex});
    if (changes[start] & 2) roles.append(Section);
    emit dataChanged(index(start), index(end - 1), roles);
    start = end;
  }
  detailCount_ = details;
  sectionCount_ = sections;
  emit metricsChanged();
}

int SearchModel::rowCount(const QModelIndex &parent) const { return parent.isValid() ? 0 : count(); }
const SearchModel::Entry *SearchModel::entryAt(int row) const {
  if (row < 0 || row >= count()) return nullptr;
  const int source = rows_[row].sourceIndex;
  return source >= 0 && source < entries_.size() ? &entries_[source] : nullptr;
}
void SearchModel::ensureFormatted(const Row &row) const {
  auto &entry = entries_[row.sourceIndex];
  if (entry.formattedGeneration == generation_) return;
  Row decorated;
  matchEntry(entry, decorated, true);
  entry.formattedGeneration = generation_;
}
QVariant SearchModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid() || index.column() != 0) return {};
  const auto *entry = entryAt(index.row());
  if (!entry) return {};
  const auto &row = rows_[index.row()];
  switch (role) {
  case Label: return entry->label;
  case Detail: return entry->detail;
  case Value: return entry->value;
  case Section: return sectionName(row.section);
  case SourceIndex: return row.sourceIndex;
  case LabelHtml: ensureFormatted(row); return entry->labelHtml;
  case DetailHtml: ensureFormatted(row); return entry->detailHtml;
  default: return {};
  }
}
QHash<int, QByteArray> SearchModel::roleNames() const {
  return {{Label,"label"},{Detail,"detail"},{Value,"value"},{Section,"section"},
      {SourceIndex,"sourceIndex"},{LabelHtml,"labelHtml"},{DetailHtml,"detailHtml"}};
}
QString SearchModel::value(int row) const { const auto *entry = entryAt(row); return entry ? entry->value : QString(); }
QStringList SearchModel::labels() const {
  QStringList result;
  result.reserve(count());
  for (const auto &row : rows_) result.append(entries_[row.sourceIndex].label);
  return result;
}
QVariantMap SearchModel::get(int row) const {
  if (!entryAt(row)) return {};
  QVariantMap result;
  const auto roles = roleNames();
  for (auto role : roles.asKeyValueRange()) result.insert(QString::fromLatin1(role.second), data(index(row), role.first));
  result.insert(QStringLiteral("score"), rows_[row].score);
  result.insert(QStringLiteral("penalty"), rows_[row].penalty);
  return result;
}
QVariantList SearchModel::snapshot() const {
  QVariantList result;
  result.reserve(count());
  for (int i = 0; i < count(); ++i) result.append(get(i));
  return result;
}
