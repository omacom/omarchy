"""User-visible names for fprintd's fixed enrollment slots."""
import os
import sqlite3
from collections import Counter
from contextlib import closing
from pathlib import Path

FINGERS = [side + "-" + finger for side in ("right", "left") for finger in
           ("index-finger", "thumb", "middle-finger", "ring-finger", "little-finger")]


class Names:
  def __init__(self, reader):
    self.reader = reader
    data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    self.path = data / "omarchy/fingerprint-names.sqlite3"

  @classmethod
  def for_device(cls, readers, path, service):
    model = dict(readers)[path]["name"]
    store = cls(model)
    # fprintd's paths last for one daemon instance. A unique model can be
    # recognized after re-enumeration. Once twins are observed, only an
    # uninterrupted object identity can identify the reader that owned a name.
    counts = Counter(props["name"] for _, props in readers)
    identity = f"{service}{path}"
    with closing(store.connect()) as db, db:
      db.execute("BEGIN IMMEDIATE")
      db.execute("CREATE TABLE IF NOT EXISTS models (model TEXT PRIMARY KEY, incumbent TEXT, twins INTEGER)")
      for name, count in counts.items():
        if count > 1:
          db.execute("""INSERT INTO models VALUES (?, NULL, 1) ON CONFLICT(model)
                        DO UPDATE SET twins=1 WHERE twins=0""", (name,))
      row = db.execute("SELECT incumbent, twins FROM models WHERE model=?", (model,)).fetchone()
      incumbent, twins = row or (None, False)
      if not twins:
        incumbent = identity
      if row != (incumbent, twins):
        db.execute("INSERT OR REPLACE INTO models VALUES (?, ?, ?)", (model, incumbent, twins))
      if twins and incumbent != identity:
        store.reader = f"{model}|{identity}"
    return store

  def connect(self):
    self.path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Create the label file privately even when the containing data directory is shared.
    os.close(os.open(self.path, os.O_CREAT | os.O_RDWR, 0o600))
    db = sqlite3.connect(self.path)
    db.execute("""CREATE TABLE IF NOT EXISTS names (
      reader TEXT, slot TEXT, number INTEGER, name TEXT,
      PRIMARY KEY (reader, slot), UNIQUE (reader, number))""")
    return db

  def sync(self, slots, prune=True):
    # Reconcile only after a successful fprintd listing. Keep each number
    # stable when a different print is removed or a device lists in a new order.
    slots = set(slots)
    with closing(self.connect()) as db, db:
      db.execute("BEGIN IMMEDIATE")
      saved = {slot: (number, name) for slot, number, name in
               db.execute("SELECT slot, number, name FROM names WHERE reader=?", (self.reader,))}
      if prune:
        for slot in saved.keys() - slots:
          db.execute("DELETE FROM names WHERE reader=? AND slot=?", (self.reader, slot))
          del saved[slot]
      for slot in sorted(slots - saved.keys(), key=lambda s: FINGERS.index(s) if s in FINGERS else len(FINGERS)):
        used = {number for number, _ in saved.values()}
        number = next(n for n in range(1, len(used) + 2) if n not in used)
        db.execute("INSERT INTO names VALUES (?, ?, ?, NULL)", (self.reader, slot, number))
        saved[slot] = (number, None)
    return saved

  def rename(self, slot, name):
    with closing(self.connect()) as db, db:
      db.execute("UPDATE names SET name=? WHERE reader=? AND slot=?", (name or None, self.reader, slot))
