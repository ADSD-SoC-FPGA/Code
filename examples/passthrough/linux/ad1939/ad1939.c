/* SPDX-License-Identifier: GPL */
/*
 * *Very minimal* SPI driver for the AD1939 audio codec on the Audio Mini.
 *
 * Original platform driver by Tyler Davis, Copyright (c) 2018 AudioLogic Inc, Bozeman MT.
 * Rewritten as a SPI driver by Trevor Vannoy, Copyright (c) 2024 Trevor Vannoy.
 */

#include <linux/module.h>
#include <linux/spi/spi.h>
#include <linux/of.h>

static int ad1939_audiomini_probe(struct spi_device *spidev)
{
    int ret;
    char cmd[3];
    cmd[0] = 0x08;

    // NOTE: we could set bits_per_word to 24, since that's what the AD1939
    // uses, but for now we are just sending 3 8-bit words.
    // printk("Set the bits per word\n");
    // spidev->bits_per_word = BITS_PER_WORD;

    printk("Initializing AD1939 codec...\n");

    // Set the unmute commands
    printk("\tUnmuting the channels\n");
    // cmd = { 0x08,0x00,0x80 };
    cmd[1] = 0x00;
    cmd[2] = 0x80;
    ret = spi_write(spidev, &cmd, sizeof(cmd));

    // Send the pll mode command
    printk("\tSetting PLL mode\n");
    cmd[1] = 0x01;
    cmd[2] = 0x00;
    ret = spi_write(spidev, &cmd, sizeof(cmd));

    cmd[1] = 0x10;
    cmd[2] = 0xC8;
    ret = spi_write(spidev, &cmd, sizeof(cmd));

    // Set the sampling frequency (ADC control register 0)
    printk("\tSetting sampling frequency to 48 kHz\n");
    cmd[1] = 0x02;
    cmd[2] = 0x00;
    ret = spi_write(spidev, &cmd, sizeof(cmd));

    cmd[1] = 14;
    cmd[2] = 0x00;
    ret = spi_write(spidev, &cmd, sizeof(cmd));

    return ret;
}

static void ad1939_audiomini_remove(struct spi_device *spidev)
{
    // NOTE: spidev currently doesn't have any device driver data, but if it
    // eventually does, we should clear the data.
    // spi_set_drvdata(spidev, NULL);
}

/** Id matching structure for use in driver/device matching */
static struct of_device_id al_ad1939_dt_ids[] =
{
    { .compatible = "dev,al-ad1939" },
    { }
};
MODULE_DEVICE_TABLE(of, al_ad1939_dt_ids);

static const struct spi_device_id ad1939_spi_ids[] =
{
    { .name = "dev,al-ad1939", },
    { }
};
MODULE_DEVICE_TABLE(spi, ad1939_spi_ids);

static struct spi_driver ad1939_audiomini_driver = {
    .id_table = ad1939_spi_ids,
    .probe = ad1939_audiomini_probe,
    .remove = ad1939_audiomini_remove,
    .driver.name = "ad1939 audiomini",
    .driver.owner = THIS_MODULE,
    .driver.of_match_table = of_match_ptr(al_ad1939_dt_ids),
};

// We don't need to do anything special in init or exit,
// so let the kernel handle it.
module_spi_driver(ad1939_audiomini_driver);

MODULE_DESCRIPTION("Minimal driver for the AD1939 codec on the Audio Mini");
MODULE_AUTHOR("Trevor Vannoy");
MODULE_AUTHOR("Tyler Davis");
MODULE_LICENSE("GPL");