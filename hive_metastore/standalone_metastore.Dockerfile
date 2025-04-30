FROM eclipse-temurin:8u442-b06-jre

# Get the Hive standalone metastore. 3.0.0 is the latest per April 2025.
RUN wget https://dlcdn.apache.org/hive/hive-standalone-metastore-3.0.0/hive-standalone-metastore-3.0.0-bin.tar.gz
RUN tar -zxvf hive-standalone-metastore-3.0.0-bin.tar.gz
RUN mv apache-hive-metastore-3.0.0-bin /usr/local/metastore
RUN chown $USER:$USER /usr/local/metastore
RUN rm hive-standalone-metastore-3.0.0-bin.tar.gz

# We need some dependencies from Hadoop to use s3.
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
RUN tar -zxvf hadoop-3.2.1.tar.gz
RUN mv hadoop-3.2.1 /usr/local/hadoop
RUN chown $USER:$USER /usr/local/hadoop
RUN rm hadoop-3.2.1.tar.gz

# Now update aspects of the hive metastore
RUN rm /usr/local/metastore/lib/guava-19.0.jar
RUN cp /usr/local/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /usr/local/metastore/lib/
RUN cp /usr/local/hadoop/share/hadoop/tools/lib/hadoop-aws-3.2.1.jar /usr/local/metastore/lib/
RUN cp /usr/local/hadoop/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar /usr/local/metastore/lib/

# Copy metastore s3 config to container
COPY ./metastore-site.xml /usr/local/metastore/conf/metastore-site.xml

# Set environment variable
ENV HADOOP_HOME=/usr/local/hadoop

# Get the mysql driver
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.2.0.tar.gz
RUN tar -zxvf mysql-connector-j-9.2.0.tar.gz
RUN mv mysql-connector-j-9.2.0/mysql-connector-j-9.2.0.jar /usr/local/metastore/lib/
RUN rm -r mysql-connector-j-9.2.0

# Get start up script
COPY ./init_and_run_metastore.sh /init_and_run_metastore.sh

# Initialise and start the metastore
CMD ["/init_and_run_metastore.sh"]

# This should check to see whether port 9083 is in use, which should be true once the metastore is up.
HEALTHCHECK --start-period=10s --interval=10s --timeout=5s --retries=3 CMD ["bash", "-c", "exec 6<> /dev/tcp/localhost/9083"]
