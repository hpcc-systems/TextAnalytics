How to build and run the index search project locally

   Load the indexsearch project into eclipse

   in config/web.xml, change the RoxieServerURL parameter to point to the HPCC Cluster where the indexes reside

   in build.xml, if you don't have a TOMCAT_HOME environment variable on the build machine, change the tomcatRootdir property to point to the tomcat root    directory where the indexer will run

   run the build.xml as an ant task with the "deployLocalPackage" option

   indexsearch.war will be built and placed in your tomcat webapps directory

   start up tomcat

   go to http://localhost:8080/indexsearch to view the search form (or whatever port you have tomcat running on)