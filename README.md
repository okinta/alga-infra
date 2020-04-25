# README

Provides tools to manage the infrastructure for Okinta's Alga project.

## Who is Okinta?

Okinta IT LLC manages the software infrastructure for businesses. More
information can be found at our website: [okinta.ge](https://okinta.ge/).

## What is Alga?

Alga is the codename for Okinta's algotrading system. Alga automatically
purchases and sells securities on the stock market without human intervention
and with the intention to produce a profit.

The infrastructure for Alga is open source, but the trading algorithms are not.

## So can I deploy this and make money automatically?

Probably not. Although you're free to try and deploy this infrastructure
yourself, not all components of Alga are open source.

## What is a Stack?

An Okinta stack is a deployable unit that runs within Okinta's infrastructure.
Stacks describe all necessary information to deploy a service.

This repository provides the tools in order to deploy a stack.

## Development

To validate the script, use shellcheck:

    shellcheck -x server

## Servers

This repository allows the creation of different types of servers within Vultr.

See `./server --help` for more usage information.

### Deploying a Stack

To deploy a stack, run:

    ./server stack-[name]

If the stack doesn't exist, this command will fail. If the stack does exist,
its configuration will be loaded and deployed.

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

This server comes with docker and a GUI pre-installed. It's able to communicate
with other servers within the same private network.

`vultr-scripts/setup-ubuntu.bash` contains the startup script to add to Vultr.
This should be named `setup-ubuntu` within Vultr.

To create a new server, run:

    ./server ubuntu

### Fedora CoreOS Servers

To spin up servers running Fedora CoreOS (FCOS), a few steps are required.

1. Create an ISO that we can boot into to install the OS.
2. Boot into a machine with the mounted ISO to install the OS.
3. Unmount the ISO and reboot into the newly installed OS.

#### Creating the ISO

`vultr-scripts/create-live-iso.bash` contains the startup script in order to
create a new ISO. This should be named `create-live-iso` within Vultr. Replace
`[VULTR_API_KEY]` with your Vultr API key.

To create the ISO, run:

    ./server buildiso

After many minutes a new ISO will be created in Vultr called
`installcoreos.iso`.

#### Creating a Default FCOS Server with Root Access

A default FCOS server with root access can be spun up by running:

    ./server fcos

After the machine has finished provisioning, you'll be able to SSH into the
machine and use `sudo`.

#### Creating a Test FCOS Server

A test FCOS server can be spun up by running:

    ./server test

After the machine is created, you'll be able to SSH into the machine. To
install CoreOS, run:

    coreos-installer install /dev/vda [-i ignition-file.ign]
    reboot

After rebooting, the new FCOS server will be running.
