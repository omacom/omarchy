/* Apple T1 private CDC-NCM adapter. */

#include <linux/module.h>
#include <linux/usb.h>
#include <linux/usb/cdc.h>
#include <linux/usb/cdc_ncm.h>
#include <linux/usb/usbnet.h>

#define APPLE_VENDOR_ID 0x05ac
#define APPLE_T1_PRODUCT_ID 0x8600
#define APPLE_T1_NCM_INTERFACE 4

static int apple_t1_ncm_bind(struct usbnet *device,
			     struct usb_interface *interface)
{
	return cdc_ncm_bind_common(device, interface,
				   CDC_NCM_DATA_ALTSETTING_NCM, 0);
}

static const struct driver_info apple_t1_ncm_info = {
	.description = "Apple T1 private NCM",
	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET |
		 FLAG_ETHER | FLAG_SEND_ZLP,
	.bind = apple_t1_ncm_bind,
	.unbind = cdc_ncm_unbind,
	.manage_power = usbnet_manage_power,
	.rx_fixup = cdc_ncm_rx_fixup,
	.tx_fixup = cdc_ncm_tx_fixup,
	.set_rx_mode = usbnet_cdc_update_filter,
};

static const struct usb_device_id apple_t1_ncm_devices[] = {
	{
		USB_DEVICE_INTERFACE_NUMBER(APPLE_VENDOR_ID,
					    APPLE_T1_PRODUCT_ID,
					    APPLE_T1_NCM_INTERFACE),
		.driver_info = (unsigned long)&apple_t1_ncm_info,
	},
	{ }
};
MODULE_DEVICE_TABLE(usb, apple_t1_ncm_devices);

static struct usb_driver apple_t1_ncm_driver = {
	.name = "apple_t1_ncm",
	.id_table = apple_t1_ncm_devices,
	.probe = usbnet_probe,
	.disconnect = usbnet_disconnect,
	.suspend = usbnet_suspend,
	.resume = usbnet_resume,
	.reset_resume = usbnet_resume,
	.supports_autosuspend = 1,
	.disable_hub_initiated_lpm = 1,
};
module_usb_driver(apple_t1_ncm_driver);

MODULE_DESCRIPTION("Apple T1 private CDC-NCM adapter");
MODULE_LICENSE("Dual MIT/GPL");
