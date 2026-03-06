# Isolate Envs

```console
$ docker build . -t isolate-envs
$ docker run -d --gpus all -p <PORT>:22 -v <PERSISTENT_HOME_PATH>:/home/student isolate-envs
```
