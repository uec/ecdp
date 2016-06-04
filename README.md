# README #

ECDP can be build and deployed on tomcat+mysql or you grab the docker version



for Docker:
docker pull zackramjan/ecdp
to start docker container:
docker run -ti -d --privileged --name=ecdp_docker -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:8080 ecdp
(optionally you can add -p 3306:3306 if you want to connect to mariaDB/mysql)

to build:
GXT4.0
GWT1.7
Java7
MariaDB

checkout, Gwt-compile, then deploy war dir to tomcat. make sure /ecdp/src/config.properties has your correct DB connection info. 



to submit updates, use the following json syntax and post to addanalysis.jsp. note the the first 3 properties should be unique, but are not supplied by the system. you can use your internal LIMS ids or generate uuids if needed. 


you can optionally include a file url for each metric, or if you just wish to associate files, you can skip metricName/Value for a given entry


{
   "experimentID":"myExp564",
   "sampleId":"ABC23",
   "analysisID":"Run2_For_ABC455",
   "metrics":[
      {
         "metricName":"Date_Sequenced",
         "metricValue":"Jan 22 2016"         
      },
      {
         "metricName":"project",
         "metricValue":"ABC project",
         "metricFileName":"http://path-an-file.bam",
         "metricFileSize":123123
      },
      {
         "metricName":"sample_name",
         "metricValue":"zacktest"
      },
      {
         "metricFileName":"s3://asdasd.asdad/123123.bam",
         "metricFileSize":123123
      },
      {
         "metricName":"processing",
         "metricValue":"nomeseq"
      }
   ]
}


save your json to a file (ex: test.json) and upload to the server with curl:
   curl -H "Content-Type: application/json" -X POST -d @test.json http://www.ecdp.org/addanalysis.jsp

changes are initially stored in an intermediate table, to push to the main table for diplsay on the web: 
   curl http://www.ecdp.org/updatedb.jsp

to delete an analysis
   curl --data "analysis_id=Run2_For_ABC455" http://www.ecdp.org/deleteanalysis.jsp

