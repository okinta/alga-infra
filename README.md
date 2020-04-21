# README

Scripts for configuring Vultr servers.

## Development

To validate the script, use shellcheck:

    shellcheck server

## Servers

This repository allows the creation of different types of servers within Vultr.

See `./server --help` for more usage information.

### Vultrkv Server

This server runs a simple key value store, allowing other servers to save and
retrieve configuration information.

To create a new server, run:

    ./server vultrkv

Additional setup instructions to load data is located in LastPass.

### Windows

This server runs Windows Server 2019. To create a new server, run:

    ./server windows

Deployment requires server2019.iso to be uploaded to Vultr. This image can be
found in OneDrive.

### IQFeed Server

This server runs IQFeed client, allowing other servers within the same private
network to pull data.

Deployment relies on vultrkv to be initialized to pull.

To create a new server, run:

    ./server iqfeed

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

#### Creatimg a Default FCOS Server with Root Access

A default FCOS server with root access can be spun up by running:

    ./server fcos

After the machine has finished provisioning, you'll be able to SSH into the
machine and use `sudo`.

#### Creating a Test FCOS Server

A test FCOS server can be spun up by running:

    ./server test

After the machine is created, you'll be able to SSH into the machine. To
install CoreOS, run:

    ./coreos-installer install /dev/vda [-i ignition-file.ign]
    reboot

After rebooting, the new FCOS server will be running.
