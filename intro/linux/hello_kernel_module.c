/* SPDX-License-Identifier: GPL-2.0 or MIT  */
/*---------------------------------------------------------------------------*/
/* Description:  Hello World Kernel Module                                   */
/*---------------------------------------------------------------------------*/
/* Authors:      Trevor Vannoy & Ross Snider                                 */
/* Company:      Montana State University                                    */
/* Create Date:  March 9, 2021                                               */
/* Revision:     1.0                                                         */
/* License:      GPL-2.0 or MIT  (opensource.org/licenses/MIT)               */  
/*---------------------------------------------------------------------------*/
#include <linux/init.h>
#include <linux/module.h>

static int __init my_kernel_module_init(void) {
    printk(KERN_ALERT "Hello, Linux Kernel World!\n");
    return 0;
}
module_init(my_kernel_module_init);

static void __exit my_kernel_module_exit(void) {
    printk(KERN_ALERT "Goodbye, Linux Kernel World!\n");
}
module_exit(my_kernel_module_exit);

MODULE_DESCRIPTION("Hello World Kernel Module");
MODULE_AUTHOR("myFirstName myLastName");
MODULE_LICENSE("Dual MIT/GPL");
MODULE_VERSION("1.0");
