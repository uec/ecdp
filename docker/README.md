
ECDP can be build and deployed on tomcat+mysql or you grab the docker version

for Docker:
	
	docker pull zackramjan/ecdp
	
to start docker container:
	
	docker run -ti -d --privileged --name=ecdp_docker -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:8080 ecdp

(optionally you can add -p 3306:3306 if you want to connect to mariaDB/mysql)


If you want to build the native version (non-docker), then note that ecdp is built on the following tools:

	to build:
	GXT4.0 (jar included in src)
	GWT1.7
	Java7
	MariaDB
	tomcat

checkout, Gwt-compile, then deploy war dir to tomcat. make sure /ecdp/src/config.properties has your correct DB connection info. 