## GHGVCR Base

A base image for the [ghgvcr](https://github.com/ebimodeling/ghgvcR) project

This base image speeds up the build process by caching certain build steps. It's
faster to download the built image than to rebuild.

```
docker build . -t ebimodeling/ghgvcr-base
docker push ebimodeling/ghgvcr-base
```
