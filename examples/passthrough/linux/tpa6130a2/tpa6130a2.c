/* SPDX-License-Identifier: GPL */
/*
 * *Very minimal* I2C driver for the TPA6130A2 headphone amplifier on the Audio Mini.
 * Based on a similar rewrite of the AD1939 audio codec driver by Trevor Vannoy.
 *
 * Original platform driver by Tyler Davis (based on work by Raymond Weber), Copyright (c) 2018 FlatEarth Inc, Bozeman MT.
 * Rewritten as a modern I2C driver by Lucas Ritzdorf, Copyright (c) 2024 Lucas Ritzdorf.
 */

#include <linux/module.h>
#include <linux/i2c.h>

static int tpa6130a2_audiomini_probe(struct i2c_client *tpa_client)
{
    int ret;
    char cmd[2];

    printk("Initializing TPA6130A2 amplifier...\n");

    // Enable both channels
    printk("\tUnmuting amplifier channels\n");
    cmd[0] = 0x01;
    cmd[1] = 0xc0;
    ret = i2c_master_send(tpa_client, cmd, ARRAY_SIZE(cmd));
    if (ret < 0) {
        pr_warn("Failed to unmute channels\n");
    }

    // Set -.3dB gain on both channels (closest value to unity)
    printk("\tSetting unity gain\n");
    cmd[0] = 0x02;
    cmd[1] = 0x34;
    ret = i2c_master_send(tpa_client, cmd, ARRAY_SIZE(cmd));
    if (ret < 0) {
        pr_warn("Failed to set gain\n");
    }

    return 0;
}

static void tpa6130a2_audiomini_remove(struct i2c_client *tpa_client)
{
    // This is currently a no-op, but functionality may be added here, such as
    // muting the amplifier upon module removal.
}

/* ID matching structure for use in driver/device binding */
static struct of_device_id al_tpa6130a2_dt_ids[] =
{
    { .compatible = "dev,al-tpa6130a2" },
    { }
};
MODULE_DEVICE_TABLE(of, al_tpa6130a2_dt_ids);

static const struct i2c_device_id tpa6130a2_i2c_ids[] =
{
    { .name = "dev,al-tpa6130a2", },
    { }
};
MODULE_DEVICE_TABLE(i2c, tpa6130a2_i2c_ids);

static struct i2c_driver tpa6130a2_audiomini_driver = {
    .id_table = tpa6130a2_i2c_ids,
    .probe_new = tpa6130a2_audiomini_probe,
    .remove = tpa6130a2_audiomini_remove,
    .driver.name = "tpa6130a2 audiomini",
    .driver.owner = THIS_MODULE,
    .driver.of_match_table = of_match_ptr(al_tpa6130a2_dt_ids),
};

// We don't need to do anything special in init or exit,
// so let the kernel handle it.
module_i2c_driver(tpa6130a2_audiomini_driver);

MODULE_DESCRIPTION("Minimal driver for the TPA6130A2 amplifier on the Audio Mini");
MODULE_AUTHOR("Lucas Ritzdorf");
MODULE_AUTHOR("Tyler Davis");
MODULE_LICENSE("GPL");

