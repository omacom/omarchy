// A blocking Unix-socket client: no GUI, event loop, subprocess polling, or daemon.
#include <json-c/json.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <string>
#include <vector>

using Json = std::unique_ptr<json_object, decltype(&json_object_put)>;
static std::string input;
static bool consumedInput = false;
static int requestFd = -1;

static std::string env(const char* name, const char* fallback = "") {
  const char* value = std::getenv(name);
  return value && *value ? value : fallback;
}

[[noreturn]] static void stock(int argc, char** argv) {
  if (requestFd >= 0) close(requestFd);
  // Restore already-consumed stdin only on fallback; no files in the fast path.
  if (consumedInput) {
    FILE* saved = tmpfile();
    if (!saved || fwrite(input.data(), 1, input.size(), saved) != input.size()
        || fflush(saved) || fseek(saved, 0, SEEK_SET) || dup2(fileno(saved), STDIN_FILENO) < 0) {
      std::perror("shortcut input"); std::exit(1);
    }
    fclose(saved);
  }
  std::string command = env("OMARCHY_PATH") + "/bin/omarchy-menu-select";
  std::vector<char*> arguments{command.data()};
  for (int i = 1; i < argc; ++i) arguments.push_back(argv[i]);
  arguments.push_back(nullptr);
  std::fputs("Shortcut search unavailable; using the stock picker.\n", stderr);
  execv(command.c_str(), arguments.data());
  std::perror(command.c_str()); std::exit(127);
}

static std::string field(json_object* object, const char* key) {
  json_object* value = nullptr;
  if (!json_object_object_get_ex(object, key, &value) || !json_object_is_type(value, json_type_string)) return {};
  return {json_object_get_string(value), static_cast<size_t>(json_object_get_string_len(value))};
}

static bool sendAll(int fd, const std::string& message) {
  size_t offset = 0;
  while (offset < message.size()) {
    ssize_t size = send(fd, message.data() + offset, message.size() - offset, MSG_NOSIGNAL);
    if (size < 0 && errno == EINTR) continue;
    if (size <= 0) return false;
    offset += static_cast<size_t>(size);
  }
  return true;
}

static Json receive(int fd, std::string& buffer, size_t limit) {
  while (true) {
    auto newline = buffer.find('\n');
    if (newline != std::string::npos) {
      if (newline > limit) return {nullptr, json_object_put};
      Json result(json_tokener_parse(buffer.substr(0, newline).c_str()), json_object_put);
      buffer.erase(0, newline + 1);
      if (result && json_object_is_type(result.get(), json_type_object)) return result;
      return {nullptr, json_object_put};
    }
    if (buffer.size() > limit) return {nullptr, json_object_put};
    char bytes[4096];
    ssize_t size = recv(fd, bytes, sizeof(bytes), 0);
    if (size < 0 && errno == EINTR) continue;
    if (size <= 0) return {nullptr, json_object_put};
    buffer.append(bytes, static_cast<size_t>(size));
  }
}

static std::string selectionValue(const std::string& option) {
  auto tab = option.find('\t');
  if (tab == std::string::npos) return option;
  auto value = option.substr(tab + 1); // Drop the optional icon.
  auto detail = value.find('\t');
  if (detail != std::string::npos && detail + 1 == value.size()) value.pop_back();
  return value;
}

int main(int argc, char** argv) {
  if (argc < 2) stock(argc, argv);
  std::string prompt = argv[1];
  if (prompt != "Keybindings" && prompt != "Tmux keybindings" && prompt != "Herdr keybindings") stock(argc, argv);
  std::vector<std::string> options;
  int flags = 2;
  while (flags < argc && std::strcmp(argv[flags], "--")) options.emplace_back(argv[flags++]);
  if (options.empty() && !isatty(STDIN_FILENO)) {
    consumedInput = true;
    char bytes[8192]; ssize_t size;
    while ((size = read(STDIN_FILENO, bytes, sizeof(bytes))) != 0) {
      if (size < 0) { if (errno == EINTR) continue; return 1; }
      input.append(bytes, static_cast<size_t>(size));
    }
    size_t start = 0;
    while (start < input.size()) {
      auto end = input.find('\n', start);
      if (end == std::string::npos) end = input.size();
      auto line = input.substr(start, end - start);
      if (!line.empty() && line.back() == '\r') line.pop_back();
      options.push_back(line); start = end + 1;
    }
  }
  if (options.empty()) return 1;
  Json payload(json_object_new_object(), json_object_put);
  json_object_object_add(payload.get(), "version", json_object_new_int(1));
  json_object_object_add(payload.get(), "prompt", json_object_new_string(prompt.c_str()));
  auto rows = json_object_new_array();
  for (const auto& option : options) json_object_array_add(rows, json_object_new_string_len(option.data(), static_cast<int>(option.size())));
  json_object_object_add(payload.get(), "options", rows);
  for (int i = flags + 1; i < argc; i += 2) {
    std::string flag = argv[i];
    const char* key = flag == "--width" ? "width" : (flag == "--height" || flag == "--maxheight" ? "maxHeight" : nullptr);
    if (!key || i + 1 >= argc) stock(argc, argv);
    char* end = nullptr; errno = 0;
    long value = std::strtol(argv[i + 1], &end, 10);
    if (errno || end == argv[i + 1] || *end || value < 1 || value > 100000) stock(argc, argv);
    json_object_object_add(payload.get(), key, json_object_new_int64(value));
  }
  auto runtime = env("XDG_RUNTIME_DIR");
  if (runtime.empty()) stock(argc, argv);
  auto display = env("WAYLAND_DISPLAY", "default");
  auto slash = display.rfind('/');
  if (slash != std::string::npos) display.erase(0, slash + 1);
  for (char& ch : display) {
    if (!((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch == '_' || ch == '.' || ch == '-')) ch = '_';
  }
  auto path = runtime + "/omarchy-shortcuts-" + display + ".sock";
  sockaddr_un address{}; address.sun_family = AF_UNIX;
  if (path.size() >= sizeof(address.sun_path)) stock(argc, argv);
  std::memcpy(address.sun_path, path.c_str(), path.size() + 1);
  requestFd = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC | SOCK_NONBLOCK, 0);
  if (requestFd < 0) stock(argc, argv);
  if (connect(requestFd, reinterpret_cast<sockaddr*>(&address), sizeof(address)) < 0) {
    if (errno != EINPROGRESS) stock(argc, argv);
    pollfd waiting{requestFd, POLLOUT, 0};
    int error = 0; socklen_t length = sizeof(error);
    if (poll(&waiting, 1, 2000) <= 0 || getsockopt(requestFd, SOL_SOCKET, SO_ERROR, &error, &length) || error) stock(argc, argv);
  }
  if (fcntl(requestFd, F_SETFL, 0)) stock(argc, argv);
  timeval timeout{2, 0};
  if (setsockopt(requestFd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout))
      || setsockopt(requestFd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout))) stock(argc, argv);
  if (!sendAll(requestFd, std::string(json_object_to_json_string_ext(payload.get(), JSON_C_TO_STRING_PLAIN)) + '\n')) stock(argc, argv);
  std::string buffer;
  auto ready = receive(requestFd, buffer, 65536);
  json_object* version = nullptr;
  if (!ready || field(ready.get(), "status") != "ready"
      || !json_object_object_get_ex(ready.get(), "version", &version)
      || !json_object_is_type(version, json_type_int) || json_object_get_int64(version) != 1) stock(argc, argv);
  timeout = {0, 0}; // Block without polling while the user chooses.
  if (setsockopt(requestFd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout))) stock(argc, argv);
  auto result = receive(requestFd, buffer, 1048576);
  if (!result) stock(argc, argv);
  auto status = field(result.get(), "status");
  if (status == "cancelled") return 1;
  json_object* selected = nullptr;
  if (!json_object_object_get_ex(result.get(), "value", &selected)
      || !json_object_is_type(selected, json_type_string)) stock(argc, argv);
  auto value = field(result.get(), "value");
  if (status == "selected") for (const auto& option : options) {
    if (value == selectionValue(option)) {
      std::fwrite(value.data(), 1, value.size(), stdout); std::fputc('\n', stdout);
      return std::ferror(stdout) ? 1 : 0;
    }
  }
  stock(argc, argv);
}
