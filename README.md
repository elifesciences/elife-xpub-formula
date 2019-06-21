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

## Helm chart

To release a new version of the Helm chart:

- change the `version` field in `helm/elife-xpub/Chart.yaml`
- push to `master`
- `git tag` it e.g. as `0.1.1`
- wait for the build at https://alfred.elifesciences.org/job/pull-requests-projects/job/elife-xpub-formula/view/tags/

The Helm chart will be pushed on this repository, which is configured in Jenkins:

```
alfred          s3://prod-elife-alfred/helm-charts
```
