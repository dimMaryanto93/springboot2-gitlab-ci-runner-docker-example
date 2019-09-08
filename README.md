[![pipeline status](http://repository.dimas-maryanto.com/examples/gitlab-ci-cd/springboot2-gitlab-runner-docker/badges/master/pipeline.svg)](http://repository.dimas-maryanto.com/examples/gitlab-ci-cd/springboot2-gitlab-runner-docker/commits/master) 
[![coverage report](http://repository.dimas-maryanto.com/examples/gitlab-ci-cd/springboot2-gitlab-runner-docker/badges/master/coverage.svg)](http://repository.dimas-maryanto.com/examples/gitlab-ci-cd/springboot2-gitlab-runner-docker/commits/master)

## Gitlab Runner with docker

Install `gitlab-runner` same as host with `docker`.

### Setup Docker
pertama. login dulu ke docker private registry

```bash
docker login -u user -p passwordnya example.registry.com
```

will generated `~/.docker/config.json`

```json
{
	"auths": {
		"example.registry.com": {
            "auth": "generated-base64"
		}
	}
}
```

### Setup Gitlab Runner

setelah itu register agent executor menggunakan `gitlar-runner register` seperti berikut example sintaxnya:

```bash
sudo gitlab-runner register \
--url http://host-gitlab \
--registration-token TOKEN \
--executor docker
```

setelah itu edit `/etc/gitlab-runner/config.toml`

```yml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "gitlab-runner-docker"
  url = "http://host-gitlab"
  token = "token-gitlab-ci"
  executor = "docker"
  ### add 'build_dir' for primary build directory like this###
  build_dir = "/builds"
  [runners.custom_build_dir]
  [runners.docker]
    tls_verify = false
    image = "maven:3.6-jdk-8"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
  [runners.machine]
    IdleCount = 0
    MachineDriver = ""
    MachineName = ""
    OffPeakTimezone = ""
    OffPeakIdleCount = 0
    OffPeakIdleTime = 0
```

### Setup SELINUX to disabled 

Setelah itu disabled selinux, edit file `/etc/selinux/config`

```properties
## change SELINUX to disabled
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 
```

setelah itu restart.

### Setup gitlab environtment

Setup gitlab ci/cd for docker authentication pull from registry, add **VARIABLES** `DOCKER_AUTH_CONFIG` di **PROJECT** -> **Settings** -> **CI/CD** -> **Variables** valuenya seperti berikut

```json
{
	"auths": {
		"example.registry.com": {
            "auth": "generated-base64"
		}
	}
}
```

### Push with tags prefix `-release`

Sekarang kita push ke gitlab repository 

```bash
# index repository
git add .

# commit 
git commit -m "first release"

# create tags
git tag -a 0.0.2-release -m "gitlab ci docker with maven docker image"

# push to gitlab
git push --tags
```
