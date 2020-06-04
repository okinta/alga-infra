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

## Servers

This repository allows the creation of different types of servers within Vultr.
It makes use of [agrix](https://github.com/okinta/agrix) for provisioning.

### Deploying Infrastructure

    agrix provision infra/base.yaml
    envsubst < infra/buildiso.yaml | agrix provision
    ./setup-vault.sh
    envsubst < infra/permanent.yaml | agrix provision

#### Giving Root Access to Server

A default FCOS server with root access can be spun up by running:

    userdata:
      stacks:
        - ...
        ...
      root: true

After the machine has finished provisioning, you'll be able to SSH into the
machine and use `sudo`.
