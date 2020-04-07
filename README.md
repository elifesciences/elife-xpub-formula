# `elife-xpub` formula

This repository contains instructions for installing and configuring the `elife-xpub`
project.

This repository provides two ways to deploy `elife-xpub`.

[MIT licensed](LICENCE.txt)

## `salt/`

Should be structured as any Saltstack formula should, but it should also conform to the structure required by the [builder](https://github.com/elifesciences/builder) project.

The project that this formula actually deploys is called [elife-xpub-deployment](https://github.com/elifesciences/elife-xpub-deployment) and has a `docker-compose` configuration targeting a Docker image of `elife-xpub`.

This deployment mode is used in all production-line environments: `end2end`, `staging`, `prod`.

## `helm/`

Provides a `elife-xpub` Helm chart for deployment on a Kubernetes cluster.

This deployment mode is only supported for testing environments, such as temporary environments created to demo a pull request.

### Helm chart release

To release a new version of the Helm chart:

- change the `version` field in `helm/elife-xpub/Chart.yaml`
- push to `master`
- `git tag` it e.g. as `0.1.1`
- wait for the build at https://alfred.elifesciences.org/job/pull-requests-projects/job/elife-xpub-formula/view/tags/

The Helm chart will be pushed on this repository, which is configured in Jenkins:

```
alfred          s3://prod-elife-alfred/helm-charts
```

You can check the version of a chart an environment is using with:

```
$ helm get elife-xpub--pr-2131 | grep CHART
CHART: elife-xpub-0.1.1
```
