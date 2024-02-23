# Loading Kernel Modules

## For Testing

When testing functionality (e.g. the modules themselves, or corresponding hardware), the `insmod` command can be used to load the module:
```sh
insmod path/to/some_module.ko
```

This simply loads the specified module.


## For Regular Use

In order to load modules on boot, we can take advantage of [automatic module loading functionality that's built into systemd](https://www.freedesktop.org/software/systemd/man/latest/modules-load.d.html).
The steps to accomplish this are:

- Compile your kernel module as usual
  - Run the `make` command from the module's directory (for example, the [`ad1939`](../ad1939) directory)
- Install the module to your network-shared root filesystem
  - From the module's directory, run this command:
    ```sh
    sudo make modules_install
    ```
- Repeat the above steps for any other modules
- Configure your system to automatically load the modules on every boot
  - Copy [`audiomini-modules.conf`](audiomini-modules.conf) into the `/etc/modules-load.d/` directory within your board's root filesystem
- Reboot, run `lsmod`, and notice that the modules specified in `audiomini-modules.conf` are already loaded!
