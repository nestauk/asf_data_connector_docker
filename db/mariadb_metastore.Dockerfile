FROM mariadb:10.11.11

ADD metastore_init.sql /docker-entrypoint-initdb.d

COPY  healthcheck.sh /healthcheck.sh

CMD ["mariadbd"]

HEALTHCHECK --start-period=10s --interval=10s --timeout=5s --retries=3 CMD ["./healthcheck.sh", "--connect", "--innodb_initialized"]
