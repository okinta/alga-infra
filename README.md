# README

Scripts for configuring Vultr servers.

## IQFeed Server

This server runs IQFeed client, allowing other servers within the same private
network to pull data.

`setup-windows-iqfeed.cmd` contains the startup script to add to Vultr. This
should be named `setup-windows-iqfeed` within Vultr.

To create a new server, run:

    ./create-iqfeed-server.bash
