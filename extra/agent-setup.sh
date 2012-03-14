#!/bin/bash
version=$1
cd ..



# Setup build directory
if [ ! -e "build" ]; then
  echo "Creating build directory"
  mkdir "build"
fi

# Clean build directory
echo "Cleaning build directory"
rm -r build/*

#################################
# Prep Agent                    #
#################################

echo "Build agent jar"
cd blur-agent
mvn clean package -DskipTests
cd ../build

mkdir agent

echo "Create bin dir"
mkdir agent/bin
cp ../etc/*.sh agent/bin
chmod 775 agent/bin/*.sh

echo "Create conf dir"
mkdir agent/conf
cp ../etc/agent.config.sample agent/conf
cp ../etc/log4j.properties agent/conf 

echo "Create lib dir"
mkdir agent/lib
cp ../blur-agent/target/blur-agent-*.jar agent/lib/agent.jar
cp ../blur-agent/target/lib/*.jar agent/lib
rm agent/lib/ant*.jar
rm agent/lib/commons-cli*.jar
rm agent/lib/commons-el*.jar
rm agent/lib/commons-httpclient*.jar
rm agent/lib/commons-net*.jar
rm agent/lib/core*.jar
rm agent/lib/hamcrest*.jar
rm agent/lib/hsqldb*.jar
rm agent/lib/jasper*.jar
rm agent/lib/jets3t*.jar
rm agent/lib/jetty*.jar
rm agent/lib/jsp-api*.jar
rm agent/lib/junit*.jar
rm agent/lib/mysql-connector-java*.jar
rm agent/lib/oro*.jar
rm agent/lib/servlet-api*.jar
rm agent/lib/xmlenc*.jar

echo "Compressing and zipping agent dir"
mv agent "agent-$version"

ls
#Setup the Agent
cd ..
cp blur-agent-blurtop.config build/agent-/conf/blur-agent.config
cp -r license-maker build/agent-/license-maker
cp extra/my-agent.sh build/agent-/bin/agent.sh
cp extra/mysql-connector-java-5.1.16.jar build/agent-/lib/mysql-connector-java-5.1.16.jar
cd extra
./start-agent.sh
