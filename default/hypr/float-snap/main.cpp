#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/layout/LayoutManager.hpp>
#include <hyprland/src/layout/space/Space.hpp>
#include <hyprland/src/desktop/view/Window.hpp>
#include <hyprland/src/devices/IKeyboard.hpp>
#include "geometry.hpp"

#include <stdexcept>

static CFunctionHook* beginHook = nullptr;
static CFunctionHook* geometryHook = nullptr;
static WP<Layout::ITarget> active;
static CBox initial;
using Controller = Layout::Supplementary::CDragStateController;
using Begin = void (*)(Controller*, SP<Layout::ITarget>, eMouseBindMode, std::optional<Layout::eRectCorner>, bool);
using Geometry = void (*)(Layout::ITarget*, const CBox&, uint8_t);

static void begin(Controller* self, SP<Layout::ITarget> target, eMouseBindMode mode,
                  std::optional<Layout::eRectCorner> corner, bool exclusive) {
  active.reset();
  reinterpret_cast<Begin>(beginHook->m_original)(self, target, mode, corner, exclusive);
  active = self->target();
  if (auto current = active.lock())
    initial = current->position();
}

// Transform before the compositor configures or paints the client: each drag
// update sends exactly one final geometry, never an unsnapped intermediate size.
static CBox snapForDrag(Layout::ITarget* self, const CBox& box) {
  const auto& drag = g_layoutManager->dragController();
  auto target = drag->target();
  if (!target || target.get() != self || target != active.lock() || !target->floating() || drag->draggingTiled() ||
      !(g_pInputManager->getModsFromAllKBs() & HL_MODIFIER_SHIFT))
    return box;
  auto window = target->window();
  if (!window || !window->m_ruleApplicator->m_tagKeeper.isTagged("omarchy-floating-workspace") ||
      window->m_ruleApplicator->keepAspectRatio().valueOrDefault() || drag->mode() == MBIND_RESIZE_FORCE_RATIO)
    return box;
  auto space = target->space();
  if (!space)
    return box;
  const auto area = space->workArea(true);
  const auto minimum = target->minSize().value_or(Vector2D{20, 20});
  const auto maximum = target->maxSize().value_or(Vector2D{1e9, 1e9});
  const auto snapped = FloatSnap::snap(
    {box.x, box.y, box.w, box.h}, {initial.x, initial.y, initial.w, initial.h},
    {area.x, area.y, area.w, area.h}, drag->mode() == MBIND_MOVE,
    minimum.x, minimum.y, maximum.x, maximum.y);
  return CBox{snapped.x, snapped.y, snapped.width, snapped.height};
}

static void geometry(Layout::ITarget* self, const CBox& box, uint8_t flags) {
  const auto snapped = snapForDrag(self, box);
  reinterpret_cast<Geometry>(geometryHook->m_original)(self, snapped, flags);
}

APICALL EXPORT std::string PLUGIN_API_VERSION() { return HYPRLAND_API_VERSION; }

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
  if (std::string(__hyprland_api_get_hash()) != __hyprland_api_get_client_hash())
    throw std::runtime_error("Float Snap needs rebuilding for this Hyprland version");
  auto install = [&](const std::string& name, const std::string& signature, void* callback) {
    auto matches = HyprlandAPI::findFunctionsByName(handle, name);
    std::erase_if(matches, [&](const auto& match) {
      return !match.demangled.starts_with(signature);
    });
    if (matches.size() != 1)
      throw std::runtime_error("Float Snap: unsupported drag API: " + name);
    auto hook = HyprlandAPI::createFunctionHook(handle, matches.front().address, callback);
    if (!hook || !hook->hook())
      throw std::runtime_error("Float Snap: could not attach drag hook");
    return hook;
  };
  beginHook = install("dragBegin", "Layout::Supplementary::CDragStateController::dragBegin(", reinterpret_cast<void*>(begin));
  geometryHook = install("setPositionGlobal", "Layout::ITarget::setPositionGlobal(Hyprutils::Math::CBox const&,", reinterpret_cast<void*>(geometry));
  return {"Float Snap", "Shift-drag floating windows onto an invisible grid", "Bronson Taylor", "0.1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() { active.reset(); }
