FROM eclipse-temurin:23.0.2_7-jre

# Get Trino server
RUN wget https://repo1.maven.org/maven2/io/trino/trino-server/475/trino-server-475.tar.gz
RUN tar -xzvf trino-server-475.tar.gz
RUN mv trino-server-475 /usr/local/trino
RUN chown $USER:$USER /usr/local/trino
RUN rm trino-server-475.tar.gz

# Get trino cli client
RUN wget https://repo1.maven.org/maven2/io/trino/trino-cli/475/trino-cli-475-executable.jar
RUN mv trino-cli-475-executable.jar /usr/local/trino/bin/trino
RUN chmod +x /usr/local/trino/bin/trino

# Configure trino jvm, node, config and catalog properties
RUN mkdir -p /usr/local/trino/etc/
COPY ./etc/ /usr/local/trino/etc/

# Add less for cli use
RUN apt update
RUN apt install -y less

CMD ["/usr/local/trino/bin/launcher", "run"]

