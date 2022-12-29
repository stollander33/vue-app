### Creamos imagen vue_helper

```bash
docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t vue_helper - < ./dockerfiles/Setup.Dockerfile
```

```bash
 docker run -v .:/vue-setup -it vue_helper
```

