# README

Scripts for configuring Vultr servers.

## Development

To validate the script, use shellcheck:

    shellcheck server

## Servers

This repository allows the creation of different types of servers within Vultr.

See `./server --help` for more usage information.

### IQFeed Server

This server runs IQFeed client, allowing other servers within the same private
network to pull data.

`setup-windows-iqfeed.cmd` contains the startup script to add to Vultr. This
should be named `setup-windows-iqfeed` within Vultr.

Variables to replace:

* `[VULTR_API_KEY]`: Replace this with your Vultr API key.
* `[IQFEED_PRODUCT]`: Replace this with your IQFeed product provided by your
application or DTN.
* `[IQFEED_PRODUCT_VERSION]`: Replace this with your IQFeed product version by
provided by your application or DTN.
* `[IQFEED_LOGIN]`: Replace this with your IQFeed login id.
* `[IQFEED_PASSWORD]`: Replace this with your IQFeed password.

To create a new server, run:

    ./server iqfeed

### Vultrkv Server

This server runs a simple key value store, allowing other servers to save and
retrieve configuration information.

To create a new server, run:

    ./server vultrkv

### Ubuntu Server

This server comes with docker pre-installed and is able to communicate with
other servers within the same private network.

`setup-ubuntu.bash` contains the startup script to add to Vultr. This should be
named `setup-ubuntu` within Vultr. Replace `[VULTR_API_KEY]` with your Vultr
API key.

To create a new server, run:

    ./server ubuntu

### Fedora CoreOS Servers

To spin up servers running Fedora CoreOS (FCOS), a few steps are required.

1. Create an ISO that we can boot into to install the OS.
2. Boot into a machine with the mounted ISO to install the OS.
3. Unmount the ISO and reboot into the newly installed OS.

#### Creating the ISO

`coreos/create-live-iso.bash` contains the startup script in order to create a
new ISO. This should be named `create-live-iso` within Vultr. Replace
`[VULTR_API_KEY]` with your Vultr API key.

To create the ISO, run:

    ./server buildiso

After many minutes a new ISO will be created in Vultr called
`installcoreos.iso`.

#### Creating a Test FCOS Server

A test FCOS server can be spun up by running:

    ./server test

After the machine is created, you'll be able to SSH into the machine. To
install CoreOS, run:

    ./coreos-installer install /dev/vda [-i ignition-file.ign]
    reboot

After rebooting, the new FCOS server will be running.
