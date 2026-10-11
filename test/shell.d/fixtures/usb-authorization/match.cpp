#include <usbguard/Rule.hpp>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

static std::string read(const char* path) {
  std::ifstream file(path);
  std::string text;
  std::getline(file, text);
  if (text.empty()) throw std::runtime_error("empty rule");
  return text;
}

static std::string replace(std::string text, const std::string& from, const std::string& to) {
  const auto index = text.find(from);
  if (index == std::string::npos) throw std::runtime_error("missing attribute");
  text.replace(index, from.size(), to);
  return text;
}

static void check(const char* name, const usbguard::Rule& policy, const usbguard::Rule& device, bool expected) {
  if (policy.appliesTo(device) != expected) throw std::runtime_error(name);
  std::cout << "ok - native USBGuard: " << name << '\n';
}

int main(int argc, char** argv) {
  if (argc != 3) return 2;
  // Test the policy produced by the real Bash implementation, not a C++ copy.
  const auto policy = usbguard::Rule::fromString(read(argv[1]));
  const auto text = read(argv[2]);
  const auto device = usbguard::Rule::fromString(text);
  check("original connection", policy, device, true);
  auto moved = device;
  moved.setViaPort("9-9.9");
  check("another port", policy, moved, true);
  moved.setParentHash("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
  check("another hub", policy, moved, true);
  auto reloaded = usbguard::Rule::fromString(policy.toString());
  check("serialized policy reload on new hub", reloaded, moved, true);
  check("reconnect on original port", reloaded, device, true);
  auto different = moved;
  different.setHash("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
  check("different hash denied", policy, different, false);
  different = moved;
  different.setSerial("different");
  check("different serial denied", policy, different, false);
  different = moved;
  different.setName("different");
  check("different name denied", policy, different, false);
  check("different product denied", policy, usbguard::Rule::fromString(replace(text, "046d:c53a", "046d:c53b")), false);
  check("different vendor denied", policy, usbguard::Rule::fromString(replace(text, "046d:c53a", "046e:c53a")), false);
  check("different interface denied", policy, usbguard::Rule::fromString(replace(text, "03:00:00", "08:06:50")), false);
  check("different connection type denied", policy, usbguard::Rule::fromString(replace(text, "with-connect-type \"unknown\"", "with-connect-type \"hotplug\"")), false);
  // Existing unmarked/manual rules remain location-bound.
  check("legacy rule still restricts ports and hubs", device, moved, false);
}
