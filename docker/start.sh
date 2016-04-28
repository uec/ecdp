docker run -ti -d --privileged --name=ecdp_docker -v /root/ecdp:/hostmount -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 3306:3306 ecdp
