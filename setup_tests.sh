#!/bin/sh -xe

# This script starts docker and systemd (if el7)

# Version of CentOS/RHEL
el_version="7"

 # Run tests in Container
if [ "$el_version" = "6" ]; then
	sudo docker run --rm=true -v `pwd`:/home/travis/build/chvalean/lis-next:rw centos:centos${OS_VERSION} /bin/bash -c "bash -xe ls /root/"
elif [ "$el_version" = "7" ]; then
	docker run --privileged -d -ti -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup -v `pwd`:/home/travis/build/chvalean/lis-next:rw  ${CENTOS}   /usr/sbin/init
	DOCKER_CONTAINER_ID=$(docker ps | grep centos | awk '{print $1}')
	docker logs $DOCKER_CONTAINER_ID
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "cat /etc/centos-release"
	#docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "yum -y -q update"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "yum -y install automake make gcc wget"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "wget -q -O - http://vault.centos.org/7.2.1511/os/x86_64/Packages/kernel-devel-3.10.0-327.el7.x86_64.rpm"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "rpm -ivh kernel-devel-3.10.0-327.el7.x86_64.rpm"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "mkdir -p /lib/modules/$(uname -r)/extra"
	# work-around to skip warning during install, we won't boot the new kernel
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "touch /lib/modules/$(uname -r)/modules.order"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "touch /lib/modules/$(uname -r)/modules.builtin"
	
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "ln -s /usr/src/kernels/3.10.0-327.el7.x86_64 /lib/modules/4.4.0-51-generic/build"
	docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "cd /home/travis/build/chvalean/lis-next/hv-rhel7.x/hv/ ; bash -e rhel7-hv-driver-install"
	docker stop $DOCKER_CONTAINER_ID
	docker rm -v $DOCKER_CONTAINER_ID
fi
