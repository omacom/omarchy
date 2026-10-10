#include <wp/wp.h>

int main(int argc, char **argv) {
  wp_init(WP_INIT_ALL);
  g_assert_cmpint(argc, ==, 2);
  g_autoptr(GError) error = NULL;
  g_autoptr(WpConf) conf = wp_conf_new_open(argv[1], NULL, &error);
  if (!conf) {
    g_printerr("%s\n", error->message);
    return 1;
  }
  g_autoptr(WpSpaJson) rules = wp_conf_get_section(conf, "monitor.alsa.rules");
  g_assert_nonnull(rules);

  const struct {
    const char *name;
    const char *vendor;
    const char *product;
    gboolean matches;
  } cases[] = {
    {"alsa_card.pci-0000_00_1f.3", "0x1022", "0x15e3", TRUE},
    {"alsa_card.pci-0000_c1_00.6", "0x1022", "0x15e3", TRUE},
    {"alsa_card.hdmi", "0x1002", "0x15e3", FALSE},
    {"alsa_card.other", "0x1022", "0x9999", FALSE},
    {"bluez_card.headset", "0x1022", "0x15e3", FALSE},
    {"alsa_card.missing_vendor", NULL, "0x15e3", FALSE},
    {"alsa_card.missing_product", "0x1022", NULL, FALSE},
  };
  for (guint i = 0; i < G_N_ELEMENTS(cases); i++) {
    g_autoptr(WpProperties) props = wp_properties_new_empty();
    wp_properties_set(props, "device.name", cases[i].name);
    wp_properties_set(props, "device.vendor.id", cases[i].vendor);
    wp_properties_set(props, "device.product.id", cases[i].product);
    wp_properties_set(props, "api.alsa.soft-mixer", "false");
    wp_json_utils_match_rules_update_properties(rules, props);
    g_assert_cmpstr(wp_properties_get(props, "api.alsa.soft-mixer"), ==,
      cases[i].matches ? "true" : "false");
    g_print("ok - WirePlumber mixer rule %s %s\n",
      cases[i].matches ? "matches" : "excludes", cases[i].name);
  }
  return 0;
}
