#pragma once
#include <QStringList>

// Passed explicitly so private-bus tests can exercise authentication using temporary files.
struct SystemFiles {
  SystemFiles();
  QString consentContract = "/usr/share/omarchy-platform/fingerprint-readers";
  QString lockPam = "/etc/pam.d/omarchy-lock-fingerprint";
  QString sudoHelper;
  QString elevation = "/usr/bin/pkexec";
};
struct DeviceInfo {
  QString path, model;
  bool swipe = false;
};
struct Discovery {
  QList<DeviceInfo> devices;
  QString owner, guid, error, sudoState;
  QStringList fingers;
  int selected = 0;
  bool consent = false, lockerSupportsPreference = false, configured = false;
};
Discovery discover(const SystemFiles &files, const QString &previousOwner, const QString &selectedPath, const QString &resumeModel);
