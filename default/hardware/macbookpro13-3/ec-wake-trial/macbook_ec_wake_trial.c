// SPDX-License-Identifier: GPL-2.0-only
/* Current-boot experiment for MacBookPro13,3: use the kernel's EC wake helper. */
#include <linux/acpi.h>
#include <linux/dmi.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/suspend.h>

static bool apply;
module_param(apply, bool, 0444);
MODULE_PARM_DESC(apply, "Mark the EC GPE wake-capable if missing (until reboot)");

static int __init macbook_ec_wake_init(void)
{
	struct acpi_table_header *table;
	struct acpi_table_ecdt *ecdt;
	acpi_event_status events;
	acpi_status status;
	unsigned int sleep_flags;
	u32 gpe;
	u8 action;
	int result = 0;

	if (!dmi_match(DMI_SYS_VENDOR, "Apple Inc.") ||
	    !dmi_match(DMI_PRODUCT_NAME, "MacBookPro13,3"))
		return -ENODEV;

	status = acpi_get_table(ACPI_SIG_ECDT, 0, &table);
	if (ACPI_FAILURE(status))
		return -ENODEV;
	if (table->length < sizeof(*ecdt)) {
		acpi_put_table(table);
		return -EINVAL;
	}
	ecdt = (struct acpi_table_ecdt *)table;
	gpe = ecdt->gpe;
	acpi_put_table(table);
	/* Match the EC GPE reported by this machine's running kernel. */
	if (gpe != 0x07)
		return -ENODEV;

	/* Exclude a concurrent suspend while checking or marking the wake GPE. */
	sleep_flags = lock_system_sleep();
	status = acpi_get_gpe_status(NULL, gpe, &events);
	if (ACPI_FAILURE(status) || !(events & ACPI_EVENT_FLAG_HAS_HANDLER)) {
		result = -ENODEV;
		goto out;
	}

	/* Preserve the current mask. AE_TYPE specifically means CAN_WAKE is absent.
	 * This API changes only ACPICA's software wake mask, not GPE hardware.
	 */
	action = (events & ACPI_EVENT_FLAG_WAKE_ENABLED) ?
		 ACPI_GPE_ENABLE : ACPI_GPE_DISABLE;
	status = acpi_set_gpe_wake_mask(NULL, gpe, action);
	pr_info("macbook_ec_wake_trial: GPE=0x%02x events=0x%x wake-mask check=%s apply=%d\n",
		gpe, events, acpi_format_exception(status), apply);
	if (status == AE_OK) {
		pr_info("macbook_ec_wake_trial: already wake-capable; no change made\n");
		goto out;
	}
	if (status != AE_TYPE) {
		result = -EIO;
		goto out;
	}
	if (!apply) {
		pr_info("macbook_ec_wake_trial: EC wake capability missing; observation only\n");
		goto out;
	}

	acpi_ec_mark_gpe_for_wake();
	status = acpi_set_gpe_wake_mask(NULL, gpe, action);
	pr_info("macbook_ec_wake_trial: after kernel EC helper: %s; reboot clears this trial\n",
		acpi_format_exception(status));
	if (ACPI_FAILURE(status))
		result = -EIO;
out:
	unlock_system_sleep(sleep_flags);
	return result;
}

static void __exit macbook_ec_wake_exit(void)
{
	/* There is no public unmark API. The capability stays until reboot. */
	pr_info("macbook_ec_wake_trial: unloaded; reboot restores original EC wake capability\n");
}

module_init(macbook_ec_wake_init);
module_exit(macbook_ec_wake_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Temporary MacBookPro13,3 EC wake-capability trial");
