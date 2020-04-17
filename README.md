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
