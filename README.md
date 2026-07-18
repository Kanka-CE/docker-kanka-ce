# docker-kanka-ce

The Dockerfile used to build the Kanka Community Edition container image, styled after [linuxserver.io](https://www.linuxserver.io)'s image conventions.

> **Want to self-host Kanka CE?** You don't need this repo directly — go to
> **[kanka-ce-deploy](https://github.com/Kanka-CE/kanka-ce-deploy)**, which has the docker-compose file and
> full Quick Start guide, and references the image this repo builds.

## What is this?

This repo contains *only* the image build recipe: the `Dockerfile` and supporting `root/` filesystem for the s6-overlay. 
It doesn't contain Kanka's source code or any patches;
those are located at [kanka-community-edition](https://github.com/Kanka-CE/kanka-community-edition) and [kanka-ce-deploy](https://github.com/Kanka-CE/kanka-ce-deploy), respectively.

By default, the image is built from the latest (already patched) release of `kanka-community-edition`. 
The resulting container is published to the container registry that `kanka-ce-deploy`'s compose file
points at.

## Building the image yourself

```
git clone https://github.com/Kanka-CE/docker-kanka-ce.git
cd docker-kanka-ce
docker build -t kanka-ce:local .
```

## Related repositories

| Repo | What it's for |
|---|---|
| [kanka-community-edition](https://github.com/Kanka-CE/kanka-community-edition) | The patched source this image is built from |
| [kanka-ce-container](https://github.com/Kanka-CE/kanka-ce-container) | Self-hosting: docker-compose and `.env` that run this image |


## License and Acknowledgements
The files in this repository are neither affiliated with the official Kanka project nor with linuxserver.io.  

This repository contains only the files required to build the Docker image, which are based on [docker-bookstack](https://github.com/linuxserver/docker-bookstack) 
provided by [linuxserver.io](https://www.linuxserver.io) and is licensed under GPLv3.

Note that Kanka itself is licensed under the [“Commons Clause” License Condition v1.0](https://github.com/owlchester/kanka/blob/develop/LICENSE).

## ❤️ Support the Official Kanka Project
If you enjoy using the Community Edition, please consider supporting the official Kanka project:
Kanka CE exists because the upstream project is amazing.
If you enjoy using Kanka or Kanka CE, please consider supporting the original creators:

💙 **Kanka Website:** https://kanka.io  

