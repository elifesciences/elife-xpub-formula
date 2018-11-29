# `elife-xpub` formula

This repository contains instructions for installing and configuring the `elife-xpub`
project.

This repository provides two ways to deploy `elife-xpub`:
- `salt/`: should be structured as any Saltstack formula should, but it 
should also conform to the structure required by the [builder](https://github.com/elifesciences/builder) 
project.
- `helm/`: provides a `elife-xpub` Helm chart for deployment on a Kubernetes cluster.

The project that this formula actually deploys is called [elife-xpub-deployment](https://github.com/elifesciences/elife-xpub-deployment) and has a `docker-compose` configuration targeting a Docker image of `elife-xpub`.

[MIT licensed](LICENCE.txt)
