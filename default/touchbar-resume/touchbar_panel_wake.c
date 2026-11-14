// SPDX-License-Identifier: GPL-2.0-only
/* One explicit DCS EXIT_SLEEP_MODE command through the existing J293 driver.
 * No reset, brightness change, suspend hook, or direct register write.
 * Temporary workaround: core locks exclude concurrent brightness commands.
 * Kernel-version-specific build; no persistent worker or PM callback.
 */
#include <linux/backlight.h>
#include <linux/device.h>
#include <linux/ktime.h>
#include <linux/delay.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/suspend.h>
#include <drm/drm_mipi_dsi.h>

static bool wake_panel;
module_param(wake_panel, bool, 0400);
MODULE_PARM_DESC(wake_panel, "Explicitly request one DCS exit-sleep command");
static int wake_result = -EINPROGRESS;
module_param(wake_result, int, 0400);


static int __init touchbar_panel_wake_init(void)
{
  struct device *dev, *host;
  struct backlight_device *bl;
  struct mipi_dsi_device *dsi;
  unsigned int sleep_flags;
  u64 start;
  int ret = -EBUSY;

  if (!wake_panel || !of_machine_is_compatible("apple,j293"))
    return -EINVAL;
  dev = bus_find_device_by_name(&mipi_dsi_bus_type, NULL, "228600000.dsi.0");
  if (!dev)
    return -ENODEV;
  bl = backlight_device_get_by_name("228600000.dsi.0");
  if (!bl) {
    put_device(dev);
    return -ENODEV;
  }
  host = dev->parent;
  sleep_flags = lock_system_sleep();
  /* No waiting on a driver or backlight lock in the failed session. */
  if (!mutex_trylock(&host->mutex))
    goto out_sleep;
  if (!mutex_trylock(&dev->mutex))
    goto out_host;
  if (!dev->driver || strcmp(dev->driver->name, "panel-summit") ||
      !host->driver || strcmp(host->driver->name, "adp-mipi") ||
      bl->dev.parent != dev) {
    ret = -ENODEV;
    goto out_device;
  }
  if (!mutex_trylock(&bl->ops_lock))
    goto out_device;
  if (!mutex_trylock(&bl->update_lock))
    goto out_ops;
  if (!bl->ops) {
    ret = -ENODEV;
    goto out_update;
  }
  dsi = to_mipi_dsi_device(dev);
  start = ktime_get_boottime_ns();
  /* Single standard DCS 0x11, no retry, reset, or extra panel command.
   * Allow 150 ms before concurrent brightness operations resume. */
  wake_result = mipi_dsi_dcs_exit_sleep_mode(dsi);
  if (!wake_result)
    msleep(150);
  pr_info("touchbar-panel-wake ns=%llu result=%d elapsed_us=%llu\n",
    start, wake_result, (ktime_get_boottime_ns() - start) / 1000);
  ret = 0; /* retain result parameters until the caller unloads us */
out_update:
  mutex_unlock(&bl->update_lock);
out_ops:
  mutex_unlock(&bl->ops_lock);
out_device:
  mutex_unlock(&dev->mutex);
out_host:
  mutex_unlock(&host->mutex);
out_sleep:
  unlock_system_sleep(sleep_flags);
  put_device(&bl->dev);
  put_device(dev);
  return ret;
}

static void __exit touchbar_panel_wake_exit(void) {}
module_init(touchbar_panel_wake_init);
module_exit(touchbar_panel_wake_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("One-shot J293 panel exit-sleep recovery");
