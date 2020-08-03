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
  name = "gitlab-runner-docker-executor"
  environment = ["DOCKER_TLS_CERTDIR="]
  log_level = "debug"
  url = "http://example.gitlab.com"
  token = "gitlab-runner-token-from-gitlab"
  executor = "docker"
  ### Add spesific build directory
  build_dir = "/builds"  
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
  [runners.docker]
    tls_verify = false
    image = "default.docker.image:v1.0.0"
    ### Add /etc/hosts to docker container
    extra_hosts = ["your.domain.name:XX.XX.XX.XX"]
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
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

### Example log gitlab ci/cd

```bash
Running with gitlab-runner 12.2.0 (a987417a)
  on docker_repository.dimas-maryanto.com Xu3xWTXe
Using Docker executor with image repository.dimas-maryanto.com:8086/maven:3.6-jdk-8 ...
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Pulling docker image repository.dimas-maryanto.com:8086/maven:3.6-jdk-8 ...
Using docker image sha256:4c81be38db66edea5bb1e31e4230d78c7a8b55cf048b590afe31465ab55dd1e4 for repository.dimas-maryanto.com:8086/maven:3.6-jdk-8 ...
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Running on runner-Xu3xWTXe-project-152-concurrent-0 via repository.dimas-maryanto.com...
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Fetching changes with git depth set to 50...
Reinitialized existing Git repository in /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/.git/
From http://repository.dimas-maryanto.com/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker
 * [new tag]         0.0.2-release -> 0.0.2-release
Checking out ec1037b3 as 0.0.2-release...
Removing .m2/
Removing pom.xml.versionsBackup
Removing target/

Skipping Git submodules setup
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Checking cache for default...
No URL provided, cache will not be downloaded from shared cache server. Instead a local version of cache will be extracted. 
Successfully extracted cache
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Authenticating with credentials from $DOCKER_AUTH_CONFIG
$ mvn versions:set -DnewVersion=$CI_COMMIT_TAG
630 [INFO] Scanning for projects...
905 [INFO] 
905 [INFO] ------< com.maryanto.dimas.example:springboot2-gitlab-ci-docker >-------
906 [INFO] Building springboot2-gitlab-ci-docker 0.0.1-SNAPSHOT
907 [INFO] --------------------------------[ jar ]---------------------------------
910 [INFO] 
911 [INFO] --- versions-maven-plugin:2.7:set (default-cli) @ springboot2-gitlab-ci-docker ---
1358 [INFO] Searching for local aggregator root...
1359 [INFO] Local aggregation root: /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker
1362 [INFO] Processing change of com.maryanto.dimas.example:springboot2-gitlab-ci-docker:0.0.1-SNAPSHOT -> 0.0.2-release
1411 [INFO] Processing com.maryanto.dimas.example:springboot2-gitlab-ci-docker
1411 [INFO]     Updating project com.maryanto.dimas.example:springboot2-gitlab-ci-docker
1411 [INFO]         from version 0.0.1-SNAPSHOT to 0.0.2-release
1417 [INFO] 
1421 [INFO] ------------------------------------------------------------------------
1422 [INFO] BUILD SUCCESS
1422 [INFO] ------------------------------------------------------------------------
1423 [INFO] Total time:  0.808 s
1423 [INFO] Finished at: 2019-09-08T03:48:09Z
1423 [INFO] ------------------------------------------------------------------------
$ mvn $MAVEN_CLI_OPTS clean package
Apache Maven 3.6.1 (d66c9c0b3152b2e69ee9bac180bb8fcc8e6af555; 2019-04-04T19:00:29Z)
Maven home: /usr/share/maven
Java version: 1.8.0_222, vendor: Oracle Corporation, runtime: /usr/local/openjdk-8/jre
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-957.27.2.el7.x86_64", arch: "amd64", family: "unix"
593 [INFO] Error stacktraces are turned on.
628 [INFO] Scanning for projects...
824 [INFO] 
824 [INFO] ------< com.maryanto.dimas.example:springboot2-gitlab-ci-docker >-------
825 [INFO] Building springboot2-gitlab-ci-docker 0.0.2-release
825 [INFO] --------------------------------[ jar ]---------------------------------
1174 [INFO] 
1174 [INFO] --- maven-clean-plugin:3.1.0:clean (default-clean) @ springboot2-gitlab-ci-docker ---
1252 [INFO] 
1252 [INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ springboot2-gitlab-ci-docker ---
1351 [INFO] Using 'UTF-8' encoding to copy filtered resources.
1355 [INFO] Copying 1 resource
1361 [INFO] Copying 0 resource
1362 [INFO] 
1362 [INFO] --- maven-compiler-plugin:3.8.1:compile (default-compile) @ springboot2-gitlab-ci-docker ---
1475 [INFO] Changes detected - recompiling the module!
1477 [INFO] Compiling 1 source file to /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/target/classes
2270 [INFO] 
2270 [INFO] --- maven-resources-plugin:3.1.0:testResources (default-testResources) @ springboot2-gitlab-ci-docker ---
2272 [INFO] Using 'UTF-8' encoding to copy filtered resources.
2273 [INFO] skip non existing resourceDirectory /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/src/test/resources
2274 [INFO] 
2274 [INFO] --- maven-compiler-plugin:3.8.1:testCompile (default-testCompile) @ springboot2-gitlab-ci-docker ---
2279 [INFO] Changes detected - recompiling the module!
2280 [INFO] Compiling 1 source file to /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/target/test-classes
2726 [INFO] 
2726 [INFO] --- maven-surefire-plugin:2.22.2:test (default-test) @ springboot2-gitlab-ci-docker ---
2808 [INFO] Surefire report directory: /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/target/surefire-reports
2910 [INFO] 
2910 [INFO] -------------------------------------------------------
2911 [INFO]  T E S T S
2911 [INFO] -------------------------------------------------------
3148 [INFO] Running com.maryanto.dimas.example.GitlabCiDockerApplicationTests
03:48:13.331 [main] DEBUG org.springframework.test.context.junit4.SpringJUnit4ClassRunner - SpringJUnit4ClassRunner constructor called with [class com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.335 [main] DEBUG org.springframework.test.context.BootstrapUtils - Instantiating CacheAwareContextLoaderDelegate from class [org.springframework.test.context.cache.DefaultCacheAwareContextLoaderDelegate]
03:48:13.344 [main] DEBUG org.springframework.test.context.BootstrapUtils - Instantiating BootstrapContext using constructor [public org.springframework.test.context.support.DefaultBootstrapContext(java.lang.Class,org.springframework.test.context.CacheAwareContextLoaderDelegate)]
03:48:13.358 [main] DEBUG org.springframework.test.context.BootstrapUtils - Instantiating TestContextBootstrapper for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests] from class [org.springframework.boot.test.context.SpringBootTestContextBootstrapper]
03:48:13.367 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Neither @ContextConfiguration nor @ContextHierarchy found for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests], using SpringBootContextLoader
03:48:13.369 [main] DEBUG org.springframework.test.context.support.AbstractContextLoader - Did not detect default resource location for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]: class path resource [com/maryanto/dimas/example/GitlabCiDockerApplicationTests-context.xml] does not exist
03:48:13.369 [main] DEBUG org.springframework.test.context.support.AbstractContextLoader - Did not detect default resource location for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]: class path resource [com/maryanto/dimas/example/GitlabCiDockerApplicationTestsContext.groovy] does not exist
03:48:13.370 [main] INFO org.springframework.test.context.support.AbstractContextLoader - Could not detect default resource locations for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]: no resource found for suffixes {-context.xml, Context.groovy}.
03:48:13.370 [main] INFO org.springframework.test.context.support.AnnotationConfigContextLoaderUtils - Could not detect default configuration classes for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]: GitlabCiDockerApplicationTests does not declare any static, non-private, non-final, nested classes annotated with @Configuration.
03:48:13.398 [main] DEBUG org.springframework.test.context.support.ActiveProfilesUtils - Could not find an 'annotation declaring class' for annotation type [org.springframework.test.context.ActiveProfiles] and class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.449 [main] DEBUG org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider - Identified candidate component class: file [/builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/target/classes/com/maryanto/dimas/example/GitlabCiDockerApplication.class]
03:48:13.450 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Found @SpringBootConfiguration com.maryanto.dimas.example.GitlabCiDockerApplication for test class com.maryanto.dimas.example.GitlabCiDockerApplicationTests
03:48:13.518 [main] DEBUG org.springframework.boot.test.context.SpringBootTestContextBootstrapper - @TestExecutionListeners is not present for class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]: using defaults.
03:48:13.518 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Loaded default TestExecutionListener class names from location [META-INF/spring.factories]: [org.springframework.boot.test.mock.mockito.MockitoTestExecutionListener, org.springframework.boot.test.mock.mockito.ResetMocksTestExecutionListener, org.springframework.boot.test.autoconfigure.restdocs.RestDocsTestExecutionListener, org.springframework.boot.test.autoconfigure.web.client.MockRestServiceServerResetTestExecutionListener, org.springframework.boot.test.autoconfigure.web.servlet.MockMvcPrintOnlyOnFailureTestExecutionListener, org.springframework.boot.test.autoconfigure.web.servlet.WebDriverTestExecutionListener, org.springframework.test.context.web.ServletTestExecutionListener, org.springframework.test.context.support.DirtiesContextBeforeModesTestExecutionListener, org.springframework.test.context.support.DependencyInjectionTestExecutionListener, org.springframework.test.context.support.DirtiesContextTestExecutionListener, org.springframework.test.context.transaction.TransactionalTestExecutionListener, org.springframework.test.context.jdbc.SqlScriptsTestExecutionListener]
03:48:13.526 [main] DEBUG org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Skipping candidate TestExecutionListener [org.springframework.test.context.transaction.TransactionalTestExecutionListener] due to a missing dependency. Specify custom listener classes or make the default listener classes and their required dependencies available. Offending class: [org/springframework/transaction/TransactionDefinition]
03:48:13.527 [main] DEBUG org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Skipping candidate TestExecutionListener [org.springframework.test.context.jdbc.SqlScriptsTestExecutionListener] due to a missing dependency. Specify custom listener classes or make the default listener classes and their required dependencies available. Offending class: [org/springframework/transaction/interceptor/TransactionAttribute]
03:48:13.527 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper - Using TestExecutionListeners: [org.springframework.test.context.web.ServletTestExecutionListener@7a69b07, org.springframework.test.context.support.DirtiesContextBeforeModesTestExecutionListener@5e82df6a, org.springframework.boot.test.mock.mockito.MockitoTestExecutionListener@3f197a46, org.springframework.boot.test.autoconfigure.SpringBootDependencyInjectionTestExecutionListener@636be97c, org.springframework.test.context.support.DirtiesContextTestExecutionListener@50a638b5, org.springframework.boot.test.mock.mockito.ResetMocksTestExecutionListener@1817d444, org.springframework.boot.test.autoconfigure.restdocs.RestDocsTestExecutionListener@6ca8564a, org.springframework.boot.test.autoconfigure.web.client.MockRestServiceServerResetTestExecutionListener@50b472aa, org.springframework.boot.test.autoconfigure.web.servlet.MockMvcPrintOnlyOnFailureTestExecutionListener@31368b99, org.springframework.boot.test.autoconfigure.web.servlet.WebDriverTestExecutionListener@1725dc0f]
03:48:13.528 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved @ProfileValueSourceConfiguration [null] for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.529 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved ProfileValueSource type [class org.springframework.test.annotation.SystemProfileValueSource] for class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.529 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved @ProfileValueSourceConfiguration [null] for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.529 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved ProfileValueSource type [class org.springframework.test.annotation.SystemProfileValueSource] for class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.530 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved @ProfileValueSourceConfiguration [null] for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.530 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved ProfileValueSource type [class org.springframework.test.annotation.SystemProfileValueSource] for class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.532 [main] DEBUG org.springframework.test.context.support.AbstractDirtiesContextTestExecutionListener - Before test class: context [DefaultTestContext@16ec5519 testClass = GitlabCiDockerApplicationTests, testInstance = [null], testMethod = [null], testException = [null], mergedContextConfiguration = [WebMergedContextConfiguration@2f7298b testClass = GitlabCiDockerApplicationTests, locations = '{}', classes = '{class com.maryanto.dimas.example.GitlabCiDockerApplication}', contextInitializerClasses = '[]', activeProfiles = '{}', propertySourceLocations = '{}', propertySourceProperties = '{org.springframework.boot.test.context.SpringBootTestContextBootstrapper=true}', contextCustomizers = set[org.springframework.boot.test.context.filter.ExcludeFilterContextCustomizer@3fd7a715, org.springframework.boot.test.json.DuplicateJsonObjectContextCustomizerFactory$DuplicateJsonObjectContextCustomizer@7f13d6e, org.springframework.boot.test.mock.mockito.MockitoContextCustomizer@0, org.springframework.boot.test.web.client.TestRestTemplateContextCustomizer@33f88ab, org.springframework.boot.test.autoconfigure.properties.PropertyMappingContextCustomizer@0, org.springframework.boot.test.autoconfigure.web.servlet.WebDriverContextCustomizerFactory$Customizer@33c7e1bb], resourceBasePath = 'src/main/webapp', contextLoader = 'org.springframework.boot.test.context.SpringBootContextLoader', parent = [null]], attributes = map['org.springframework.test.context.web.ServletTestExecutionListener.activateListener' -> true]], class annotated with @DirtiesContext [false] with mode [null].
03:48:13.533 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved @ProfileValueSourceConfiguration [null] for test class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.533 [main] DEBUG org.springframework.test.annotation.ProfileValueUtils - Retrieved ProfileValueSource type [class org.springframework.test.annotation.SystemProfileValueSource] for class [com.maryanto.dimas.example.GitlabCiDockerApplicationTests]
03:48:13.552 [main] DEBUG org.springframework.test.context.support.TestPropertySourceUtils - Adding inlined properties to environment: {spring.jmx.enabled=false, org.springframework.boot.test.context.SpringBootTestContextBootstrapper=true, server.port=-1}

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.8.RELEASE)

2019-09-08 03:48:13.745  INFO 94 --- [           main] c.m.d.e.GitlabCiDockerApplicationTests   : Starting GitlabCiDockerApplicationTests on runner-Xu3xWTXe-project-152-concurrent-0 with PID 94 (started by root in /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker)
2019-09-08 03:48:13.748  INFO 94 --- [           main] c.m.d.e.GitlabCiDockerApplicationTests   : No active profile set, falling back to default profiles: default
2019-09-08 03:48:15.107  INFO 94 --- [           main] o.s.s.concurrent.ThreadPoolTaskExecutor  : Initializing ExecutorService 'applicationTaskExecutor'
2019-09-08 03:48:15.637  INFO 94 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 2 endpoint(s) beneath base path '/actuator'
2019-09-08 03:48:15.679  INFO 94 --- [           main] c.m.d.e.GitlabCiDockerApplicationTests   : Started GitlabCiDockerApplicationTests in 2.12 seconds (JVM running for 2.597)
5697 [INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 2.535 s - in com.maryanto.dimas.example.GitlabCiDockerApplicationTests
2019-09-08 03:48:15.812  INFO 94 --- [       Thread-3] o.s.s.concurrent.ThreadPoolTaskExecutor  : Shutting down ExecutorService 'applicationTaskExecutor'
6041 [INFO] 
6041 [INFO] Results:
6041 [INFO] 
6041 [INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
6041 [INFO] 
6048 [INFO] 
6048 [INFO] --- maven-jar-plugin:3.1.2:jar (default-jar) @ springboot2-gitlab-ci-docker ---
6181 [INFO] Building jar: /builds/examples/gitlab-ci-cd/springboot2-gitlab-ci-docker/target/springboot2-gitlab-ci-docker-0.0.2-release.jar
6208 [INFO] 
6209 [INFO] --- spring-boot-maven-plugin:2.1.8.RELEASE:repackage (repackage) @ springboot2-gitlab-ci-docker ---
6535 [INFO] Replacing main artifact with repackaged archive
6535 [INFO] ------------------------------------------------------------------------
6535 [INFO] BUILD SUCCESS
6535 [INFO] ------------------------------------------------------------------------
6536 [INFO] Total time:  5.923 s
6536 [INFO] Finished at: 2019-09-08T03:48:16Z
6537 [INFO] ------------------------------------------------------------------------
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Creating cache default...
.m2/repository: found 2814 matching files          
Archive is up to date!                             
Created cache
Authenticating with credentials from $DOCKER_AUTH_CONFIG
Uploading artifacts...
target/*.jar: found 1 matching files               
Uploading artifacts to coordinator... ok            id=79 responseStatus=201 Created token=pt2u7RVQ
Job succeeded
```
