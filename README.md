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
    Sending build context to Docker daemon 60.93 kB
    Step 1/6 : FROM busybox
     ---> 00f017a8c2a6
    Step 2/6 : RUN mkdir -p /bar
     ---> Running in b697b1344dcf
     ---> 1add665dc792
    Removing intermediate container b697b1344dcf
    Step 3/6 : RUN rm -rf /bar ; mkdir -p /bar ; touch /bar/foo
     ---> Running in 69a7c287d4cc
     ---> 41579fb81843
    Removing intermediate container 69a7c287d4cc
    Step 4/6 : RUN ls -ila /bar
     ---> Running in ce7c006e9ec4
    total 8
         24 drwxr-xr-x    2 root     root          4096 Apr  4 15:39 .
          2 drwxr-xr-x   20 root     root          4096 Apr  4 15:39 ..
         25 -rw-r--r--    1 root     root             0 Apr  4 15:39 foo
     ---> e9be5d38d5c8
    Removing intermediate container ce7c006e9ec4
    Step 5/6 : RUN rm -rf /bar ; ls -ila /bar ; mkdir -p /bar ; ls -ila /bar
     ---> Running in 7f7e42156641
    ls: /bar: No such file or directory
    total 8
         24 drwxr-xr-x    2 root     root          4096 Apr  4 15:39 .
          2 drwxr-xr-x   21 root     root          4096 Apr  4 15:39 ..
     ---> db8ac9e4739f
    Removing intermediate container 7f7e42156641
    Step 6/6 : RUN ls -ila /bar
     ---> Running in 7f6856647e56
    total 8
         24 drwxr-xr-x    2 root     root          4096 Apr  4 15:39 .
          2 drwxr-xr-x   21 root     root          4096 Apr  4 15:39 ..
         25 -rw-r--r--    1 root     root             0 Apr  4 15:39 foo
     ---> d92973d52280
    Removing intermediate container 7f6856647e56
    Successfully built d92973d52280

So, why is there still a file `/bar/foo` when the previous `RUN` command did `rm -rf /bar` and `mkdir -p /bar`?

This doesn't happen when:
 - I don't do the first `rm -rf /bar ; mkdir -p /bar`
 - I split the lines containing `rm -rf /bar` and `mkdir -p /bar` into 2 `RUN` commands

It also happens with eg. `debian:jessie` as `FROM`
