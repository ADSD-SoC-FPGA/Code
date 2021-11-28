/* SPDX-License-Identifier: GPL-2.0 or MIT                               */
/* Copyright(c) 2021 Ross K.Snider. All rights reserved.                 */
/*-------------------------------------------------------------------------
 * Description:  Linux Platform Device Driver for the 
 *               HPS_LED_patterns component
 * ------------------------------------------------------------------------
 * Authors : Ross K. Snider and Trevor Vannoy
 * Company : Montana State University
 * Create Date : November 10, 2021
 * Revision : 1.0
 * License : GPL-2.0 or MIT (opensource.org / licenses / MIT, GPL-2.0)
-------------------------------------------------------------------------*/
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/types.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/uaccess.h>
/*#include "fp_conversions.h"*/

/*-----------------------------------------------------------------------*/
/* DEFINE STATEMENTS                                                     */
/*-----------------------------------------------------------------------*/
/* Define the Component Register Offsets*/
#define REG0_HPS_LED_CONTROL_OFFSET 0x0
/* #define REG1 (Add offset for SYS_CLKs_sec) */
#define REG2_LED_REG_OFFSET 0x08
/* #define REG3 (Add offset for Base_rate) */

/* Memory span of all registers (used or not) in the                     */
/* component hps_led_patterns                                            */
#define SPAN 0x10


/*-----------------------------------------------------------------------*/
/* HPS_LED_patterns device structure                                     */
/*-----------------------------------------------------------------------*/
/*
 * struct  hps_led_patterns_dev - Private hps_led_patterns device struct.
 * @miscdev: miscdevice used to create a char device 
 *           for the hps_led_patterns component
 * @base_addr: Base address of the hps_led_patterns component
 * @lock: mutex used to prevent concurrent writes 
 *        to the hps_led_patterns component
 *
 * An hps_led_patterns_dev struct gets created for each hps_led_patterns 
 * component in the system.
 */
struct hps_led_patterns_dev {
	struct miscdevice miscdev;
	void __iomem *base_addr;
	struct mutex lock;
};

/*-----------------------------------------------------------------------*/
/* REG0: HPS_LED_control register read function show()                   */
/*-----------------------------------------------------------------------*/
/*
 * hps_led_control_show() - Return the hps_led_control value 
 *                          to user-space via sysfs.
 * @dev: Device structure for the hps_led_patterns component. This 
 *       device struct is embedded in the hps_led_patterns' device struct.
 * @attr: Unused.
 * @buf: Buffer that gets returned to user-space.
 *
 * Return: The number of bytes read.
 */
static ssize_t hps_led_control_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	bool hps_control;

	// Get the private hps_led_patterns data out of the dev struct
	struct hps_led_patterns_dev *priv = dev_get_drvdata(dev);

	hps_control = ioread32(priv->base_addr + REG0_HPS_LED_CONTROL_OFFSET);

	return scnprintf(buf, PAGE_SIZE, "%u\n", hps_control);
}
/*-----------------------------------------------------------------------*/
/* REG0: HPS_LED_control register write function store()                 */
/*-----------------------------------------------------------------------*/
/**
 * hps_led_control_store() - Store the hps_led_control value.
 * @dev: Device structure for the hps_led_patterns component. This 
 *       device struct is embedded in the hps_led_patterns' 
 *       platform device struct.
 * @attr: Unused.
 * @buf: Buffer that contains the hps_led_control value being written.
 * @size: The number of bytes being written.
 *
 * Return: The number of bytes stored.
 */
static ssize_t hps_led_control_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	bool hps_control;
	int ret;
	struct hps_led_patterns_dev *priv = dev_get_drvdata(dev);

	// Parse the string we received as a bool
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289 
	ret = kstrtobool(buf, &hps_control);
	if (ret < 0) {
		// kstrtobool returned an error
		return ret;
	}

	iowrite32(hps_control, priv->base_addr + REG0_HPS_LED_CONTROL_OFFSET);

	// Write was succesful, so we return the number of bytes we wrote.
	return size;
}


/*-----------------------------------------------------------------------*/
/* TODO: Add show() and store() functions for                            */
/* Registers REG1 (SYS_CLKs_sec) and REG2 (Base_rate)                    */
/* in component hps_led_patterns                                         */
/*-----------------------------------------------------------------------*/
/* Add here...                                                           */


/*-----------------------------------------------------------------------*/
/* REG3: LED_reg register read function show()                           */
/*-----------------------------------------------------------------------*/
/*
 * led_reg_show() - Return the led_reg value to user-space via sysfs.
 * @dev: Device structure for the hps_led_patterns component. This 
 *       device struct is embedded in the hps_led_patterns' platform 
 *       device struct.
 * @attr: Unused.
 * @buf: Buffer that gets returned to user-space.
 *
 * Return: The number of bytes read.
 */
static ssize_t led_reg_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	u8 led_reg;
	struct hps_led_patterns_dev *priv = dev_get_drvdata(dev);

	led_reg = ioread32(priv->base_addr + REG3_LED_REG_OFFSET);

	return scnprintf(buf, PAGE_SIZE, "%u\n", led_reg);
}
/*-----------------------------------------------------------------------*/
/* REG3: LED_reg register write function store()                         */
/*-----------------------------------------------------------------------*/
/*
 * led_reg_store() - Store the led_reg value.
 * @dev: Device structure for the hps_led_patterns component. This 
 *       device struct is embedded in the hps_led_patterns' platform 
 *       device struct.
 * @attr: Unused.
 * @buf: Buffer that contains the  hps_led_patterns value being written.
 * @size: The number of bytes being written.
 *
 * Return: The number of bytes stored.
 */
static ssize_t led_reg_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	u8 led_reg;
	int ret;
	struct hps_led_patterns_dev *priv = dev_get_drvdata(dev);

	// Parse the string we received as a u8
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289 
	ret = kstrtou8(buf, 0, &led_reg);
	if (ret < 0) {
		// kstrtou16 returned an error
		return ret;
	}

	iowrite32(led_reg, priv->base_addr + REG3_LED_REG_OFFSET);

	// Write was succesful, so we return the number of bytes we wrote.
	return size;
}


/*-----------------------------------------------------------------------*/
/* sysfs Attributes                                                      */
/*-----------------------------------------------------------------------*/
// Define sysfs attributes
static DEVICE_ATTR_RW(hps_led_control);    // Attribute for REG0
/* TODO: Add the attributes for REG1 and REG2 using register names       */
static DEVICE_ATTR_RW(led_reg);            // Attribute for REG3

// Create an atribute group so the device core can 
// export the attributes for us.
static struct attribute *hps_led_patterns_attrs[] = {
	&dev_attr_hps_led_control.attr,
/* TODO: Add the attribute entries for REG1 and REG2 using register names*/
	&dev_attr_led_reg.attr,
	NULL,
};
ATTRIBUTE_GROUPS(hps_led_patterns);


/*-----------------------------------------------------------------------*/
/* File Operations read()                                                */
/*-----------------------------------------------------------------------*/
/*
 * hps_led_patterns_read() - Read method for the hps_led_patterns char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value into.
 * @count: The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */
static ssize_t hps_led_patterns_read(struct file *file, char __user *buf,
	size_t count, loff_t *offset)
{
	size_t ret;
	u32 val;

	loff_t pos = *offset;

	/*
	 * Get the device's private data from the file struct's private_data
	 * field. The private_data field is equal to the miscdev field in the
	 * hps_led_patterns_dev struct. container_of returns the 
     * hps_led_patterns_dev struct that contains the miscdev in private_data.
	 */
	struct hps_led_patterns_dev *priv = container_of(file->private_data,
	                            struct hps_led_patterns_dev, miscdev);

	// Check file offset to make sure we are reading to a valid location.
	if (pos < 0) {
		// We can't read from a negative file position.
		return -EINVAL;
	}
	if (pos >= SPAN) {
		// We can't read from a position past the end of our device.
		return 0;
	}
	if ((pos % 0x4) != 0) {
		/*
		 * Prevent unaligned access. Even though the hardware
		 * technically supports unaligned access, we want to
		 * ensure that we only access 32-bit-aligned addresses
		 * because our registers are 32-bit-aligned.
		 */
		pr_warn("hps_led_patterns_read: unaligned access\n");
		return -EFAULT;
	}

	// If the user didn't request any bytes, don't return any bytes :)
	if (count == 0) {
		return 0;
	}

	// Read the value at offset pos.
	val = ioread32(priv->base_addr + pos);

	ret = copy_to_user(buf, &val, sizeof(val));
	if (ret == sizeof(val)) {
		// Nothing was copied to the user.
		pr_warn("hps_led_patterns_read: nothing copied\n");
		return -EFAULT;
	}

	// Increment the file offset by the number of bytes we read.
	*offset = pos + sizeof(val);

	return sizeof(val);
}
/*-----------------------------------------------------------------------*/
/* File Operations write()                                               */
/*-----------------------------------------------------------------------*/
/*
 * hps_led_patterns_write() - Write method for the hps_led_patterns char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value from.
 * @count: The number of bytes being written.
 * @offset: The byte offset in the file being written to.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */
static ssize_t hps_led_patterns_write(struct file *file, const char __user *buf,
	size_t count, loff_t *offset)
{
	size_t ret;
	u32 val;

	loff_t pos = *offset;

	/*
	 * Get the device's private data from the file struct's private_data
	 * field. The private_data field is equal to the miscdev field in the
	 * hps_led_patterns_dev struct. container_of returns the 
     * hps_led_patterns_dev struct that contains the miscdev in private_data.
	 */
	struct hps_led_patterns_dev *priv = container_of(file->private_data,
	                              struct hps_led_patterns_dev, miscdev);

	// Check file offset to make sure we are writing to a valid location.
	if (pos < 0) {
		// We can't write to a negative file position.
		return -EINVAL;
	}
	if (pos >= SPAN) {
		// We can't write to a position past the end of our device.
		return 0;
	}
	if ((pos % 0x4) != 0) {
		/*
		 * Prevent unaligned access. Even though the hardware
		 * technically supports unaligned access, we want to
		 * ensure that we only access 32-bit-aligned addresses
		 * because our registers are 32-bit-aligned.
		 */
		pr_warn("hps_led_patterns_write: unaligned access\n");
		return -EFAULT;
	}

	// If the user didn't request to write anything, return 0.
	if (count == 0) {
		return 0;
	}

	mutex_lock(&priv->lock);

	ret = copy_from_user(&val, buf, sizeof(val));
	if (ret == sizeof(val)) {
		// Nothing was copied from the user.
		pr_warn("hps_led_patterns_write: nothing copied from user space\n");
		ret = -EFAULT;
		goto unlock;
	}

	// Write the value we were given at the address offset given by pos.
	iowrite32(val, priv->base_addr + pos);

	// Increment the file offset by the number of bytes we wrote.
	*offset = pos + sizeof(val);

	// Return the number of bytes we wrote.
	ret = sizeof(val);

unlock:
	mutex_unlock(&priv->lock);
	return ret;
}


/*-----------------------------------------------------------------------*/
/* File Operations Supported                                             */
/*-----------------------------------------------------------------------*/
/*
 *  hps_led_patterns_fops - File operations supported by the  
 *                          hps_led_patterns driver
 * @owner: The hps_led_patterns driver owns the file operations; this 
 *         ensures that the driver can't be removed while the 
 *         character device is still in use.
 * @read: The read function.
 * @write: The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows 
 *          users to change what position they are writing/reading to/from.
 */
static const struct file_operations  hps_led_patterns_fops = {
	.owner = THIS_MODULE,
	.read = hps_led_patterns_read,
	.write = hps_led_patterns_write,
	.llseek = default_llseek,
};


/*-----------------------------------------------------------------------*/
/* Platform Driver Probe (Initialization) Function                       */
/*-----------------------------------------------------------------------*/
/*
 * hps_led_patterns_probe() - Initialize device when a match is found
 * @pdev: Platform device structure associated with our 
 *        hps_led_patterns device; pdev is automatically created by the 
 *        driver core based upon our hps_led_patterns device tree node.
 *
 * When a device that is compatible with this hps_led_patterns driver 
 * is found, the driver's probe function is called. This probe function 
 * gets called by the kernel when an hps_led_patterns device is found 
 * in the device tree.
 */
static int hps_led_patterns_probe(struct platform_device *pdev)
{
	struct hps_led_patterns_dev *priv;
	int ret;

	/*
	 * Allocate kernel memory for the hps_led_patterns device and set it to 0.
	 * GFP_KERNEL specifies that we are allocating normal kernel RAM;
	 * see the kmalloc documentation for more info. The allocated memory
	 * is automatically freed when the device is removed.
	 */
	priv = devm_kzalloc(&pdev->dev, sizeof(struct hps_led_patterns_dev), GFP_KERNEL);
	if (!priv) {
		pr_err("Failed to allocate kernel memory for hps_led_pattern\n");
		return -ENOMEM;
	}

	/*
	 * Request and remap the device's memory region. Requesting the region
	 * make sure nobody else can use that memory. The memory is remapped
	 * into the kernel's virtual address space becuase we don't have access
	 * to physical memory locations.
	 */
	priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(priv->base_addr)) {
		pr_err("Failed to request/remap platform device resource (hps_led_patterns)\n");
		return PTR_ERR(priv->base_addr);
	}

	// Initialize the misc device parameters
	priv->miscdev.minor = MISC_DYNAMIC_MINOR;
	priv->miscdev.name = "hps_led_patterns";
	priv->miscdev.fops = &hps_led_patterns_fops;
	priv->miscdev.parent = &pdev->dev;
	priv->miscdev.groups = hps_led_patterns_groups;

	// Register the misc device; this creates a char dev at 
    // /dev/hps_led_patterns
	ret = misc_register(&priv->miscdev);
	if (ret) {
		pr_err("Failed to register misc device for hps_led_patterns\n");
		return ret;
	}

	// Attach the hps_led_patterns' private data to the 
    // platform device's struct.
	platform_set_drvdata(pdev, priv);

	pr_info("hps_led_patterns_probe successful\n");

	return 0;
}

/*-----------------------------------------------------------------------*/
/* Platform Driver Remove Function                                       */
/*-----------------------------------------------------------------------*/
/*
 * hps_led_patterns_remove() - Remove an hps_led_patterns device.
 * @pdev: Platform device structure associated with our hps_led_patterns device.
 *
 * This function is called when an hps_led_patterns devicee is removed or
 * the driver is removed.
 */
static int hps_led_patterns_remove(struct platform_device *pdev)
{
	// Get thehps_led_patterns' private data from the platform device.
	struct hps_led_patterns_dev *priv = platform_get_drvdata(pdev);

	// Deregister the misc device and remove the /dev/hps_led_patterns file.
	misc_deregister(&priv->miscdev);

	pr_info("hps_led_patterns_remove successful\n");

	return 0;
}

/*-----------------------------------------------------------------------*/
/* Compatible Match String                                               */
/*-----------------------------------------------------------------------*/
/*
 * Define the compatible property used for matching devices to this driver,
 * then add our device id structure to the kernel's device table. For a 
 * device to be matched with this driver, its device tree node must use the 
 * same compatible string as defined here.
 */
static const struct of_device_id hps_led_patterns_of_match[] = {
    // ****Note:**** This .compatible string must be identical to the 
    // .compatible string in the Device Tree Node for hps_led_patterns
	{ .compatible = "adsd,hps_led_patterns", },  
	{ }
};
MODULE_DEVICE_TABLE(of, hps_led_patterns_of_match);

/*-----------------------------------------------------------------------*/
/* Platform Driver Structure                                             */
/*-----------------------------------------------------------------------*/
/*
 * struct hps_led_patterns_driver - Platform driver struct for the 
 *                                  hps_led_patterns driver
 * @probe: Function that's called when a device is found
 * @remove: Function that's called when a device is removed
 * @driver.owner: Which module owns this driver
 * @driver.name: Name of the hps_led_patterns driver
 * @driver.of_match_table: Device tree match table
 * @driver.dev_groups: hps_led_patterns sysfs attribute group; this
 *                     allows the driver core to create the
 *                     attribute(s) without race conditions.
 */
static struct platform_driver hps_led_patterns_driver = {
	.probe = hps_led_patterns_probe,
	.remove = hps_led_patterns_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name = "hps_led_patterns",
		.of_match_table = hps_led_patterns_of_match,
		.dev_groups = hps_led_patterns_groups,
	},
};

/*
 * We don't need to do anything special in module init/exit.
 * This macro automatically handles module init/exit.
 */
module_platform_driver(hps_led_patterns_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Ross Snider");  // Adapted from Trevor Vannoy's Echo Driver
MODULE_DESCRIPTION("hps_led_patterns driver");
MODULE_VERSION("1.0");

