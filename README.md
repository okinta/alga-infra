# README

Scripts for configuring Vultr servers.

## IQFeed Server

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

    ./create-iqfeed-server.bash

## Ubuntu Server

This server comes with docker pre-installed and is able to communicate with
other servers within the same private network.

`setup-ubuntu.bash` contains the startup script to add to Vultr. This should be
named `setup-ubuntu` within Vultr. Replace `[VULTR_API_KEY]` with your Vultr
API key.

To create a new server, run:

    ./create-ubuntu-server.bash

## CoreOS Servers

To spin up servers running CoreOS, a few steps are required.

1. Create an ISO that we can boot into to install the OS.
2. Boot into a machine with the mounted ISO to install the OS.
3. Unmount the ISO and reboot into the newly installed OS.

### Creating the ISO

`coreos/create-live-iso.bash` contains the startup script in order to create a
new ISO. This should be named `create-live-iso` within Vultr. Replace
`[VULTR_API_KEY]` with your Vultr API key.

To create the ISO, run:

    ./coreos/build-iso.bash

After many minutes a new ISO will be created in Vultr called
`installcoreos.iso`.

### Creating a Red Hat CoreOS Server (deprecated)

To create a barebones CoreOS server, run:

    ./coreos/create-coreos-server.bash

### Creating a Flatcar Server

To create a barebones Flatcar server, run:

    ./coreos/create-flatcar-server.bash

### Creating a Fedora CoreOS Server

To create a barebones Fedora CoreOS server, run:

    ./coreos/create-fcos-server.bash
