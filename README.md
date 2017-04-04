# PoC for directory recreation problem in Docker

    $ cat /etc/issue
    Ubuntu 16.04.2 LTS \n \l

    $ docker version
    Client:
     Version:      17.03.1-ce
     API version:  1.27
     Go version:   go1.7.5
     Git commit:   c6d412e
     Built:        Mon Mar 27 17:14:09 2017
     OS/Arch:      linux/amd64

    Server:
     Version:      17.03.1-ce
     API version:  1.27 (minimum version 1.12)
     Go version:   go1.7.5
     Git commit:   c6d412e
     Built:        Mon Mar 27 17:14:09 2017
     OS/Arch:      linux/amd64
     Experimental: false

     $ docker info
    Containers: 7
     Running: 0
     Paused: 0
     Stopped: 7
    Images: 373
    Server Version: 17.03.1-ce
    Storage Driver: aufs
     Root Dir: /var/lib/docker/aufs
     Backing Filesystem: extfs
     Dirs: 287
     Dirperm1 Supported: true
    Logging Driver: json-file
    Cgroup Driver: cgroupfs
    Plugins:
     Volume: local
     Network: bridge host macvlan null overlay
    Swarm: inactive
    Runtimes: runc
    Default Runtime: runc
    Init Binary: docker-init
    containerd version: 4ab9917febca54791c5f071a9d1f404867857fcc
    runc version: 54296cf40ad8143b62dbcaa1d90e520a2136ddfe
    init version: 949e6fa
    Security Options:
     apparmor
     seccomp
      Profile: default
    Kernel Version: 4.4.0-71-generic
    Operating System: Ubuntu 16.04.2 LTS
    OSType: linux
    Architecture: x86_64
    CPUs: 8
    Total Memory: 15.5 GiB
    Name: roeldell
    ID: P53E:VO4J:EMBM:PUEV:ZCI4:DBOS:42BL:BYYF:4YHE:QHYW:3SNE:75SR
    Docker Root Dir: /var/lib/docker
    Debug Mode (client): false
    Debug Mode (server): false
    Registry: https://index.docker.io/v1/
    WARNING: No swap limit support
    Experimental: false
    Insecure Registries:
     127.0.0.0/8
    Live Restore Enabled: false

    $ dpkg -s docker-ce | grep Version
    Version: 17.03.1~ce-0~ubuntu-xenial

    $ docker build --no-cache .
    Sending build context to Docker daemon 43.52 kB
    Step 1/6 : FROM debian:jessie
     ---> 8cedef9d7368
    Step 2/6 : RUN mkdir -p /bar
     ---> Running in 3d41e1175745
     ---> f033222feed4
    Removing intermediate container 3d41e1175745
    Step 3/6 : RUN rm -rf /bar ; mkdir -p /bar ; touch /bar/foo
     ---> Running in d10ab231c0a4
     ---> 3ff579e07aad
    Removing intermediate container d10ab231c0a4
    Step 4/6 : RUN ls -ila /bar
     ---> Running in a2cb035962ad
    total 8
    50 drwxr-xr-x  2 root root 4096 Apr  4 15:23 .
     2 drwxr-xr-x 29 root root 4096 Apr  4 15:23 ..
    63 -rw-r--r--  1 root root    0 Apr  4 15:23 foo
     ---> 698535d52ad9
    Removing intermediate container a2cb035962ad
    Step 5/6 : RUN rm -rf /bar ; ls -ila /bar ; mkdir -p /bar ; ls -ila /bar
     ---> Running in 9f99a398bf86
    ls: cannot access /bar: No such file or directory
    total 8
    52 drwxr-xr-x  2 root root 4096 Apr  4 15:23 .
     2 drwxr-xr-x 30 root root 4096 Apr  4 15:23 ..
     ---> efca0aab25f9
    Removing intermediate container 9f99a398bf86
    Step 6/6 : RUN ls -ila /bar
     ---> Running in f8c901531d03
    total 8
    50 drwxr-xr-x  2 root root 4096 Apr  4 15:23 .
     2 drwxr-xr-x 30 root root 4096 Apr  4 15:23 ..
    63 -rw-r--r--  1 root root    0 Apr  4 15:23 foo
     ---> 4e8dc1d4f7a5
    Removing intermediate container f8c901531d03
    Successfully built 4e8dc1d4f7a5

So, why is there still a file `/bar/foo` when the previous `RUN` command did `rm -rf /bar` and `mkdir -p /bar`, and where did the `/bar` directory with inode `52` go?

This doesn't happen when:
 - I split the line containing `rm -rf /bar` and `mkdir -p /bar` into 2 `RUN` commands
 - I touch the `/bar/foo` in a separate `RUN` command
 - I use `busybox` as `FROM`
