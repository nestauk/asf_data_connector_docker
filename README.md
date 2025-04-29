# ASF Data Connector Docker

## Background

This repo contains a dockerised data connector that enables querying of parquet files in aws s3 using trino via a standalone hive metastore.

This container exists to allow BI tools, like Apache Superset or Metaflow, to connect to data stored as files (e.g. parquet, orc, csv) in object stores (i.e. AWS S3). It might also be useful for other situations where you want to query files in S3 in a database table-like way using SQL, however you should explore whether those situations are better served with `duckdb`. This data connector fills a gap where we found that `duckdb` didn't work as well as we'd hoped (largely because it isn't a data warehousing tool).

Note that although this is a 'big data' workflow, we're primarily interested in its utility to work with smaller data and file sizes. It hasn't been tested on large data volumes and hasn't been set up with that in mind.

## Docker Containers

Docker compose creates three containers that together provide the data connection we're looking to provide.

To start the containers simply run: `docker compose -f compose.yaml -d up`, you should then see the containers build and start sequentially.

### Mariadb
The mariadb database provides the storage for the standalone hive metastore. This is initialised first and some user privileges are set that allow the metastore to access mariadb.

### Standalone Hive Metastore
The Hive Metastore is essentially a data catalog that stores and manages information about tables, schemas, partitions, and data locations. Usually the Hive Metastore is deployed with Hive, which is a data warehouse for Hadoop. In this case we're not using Hadoop, but S3 so we don't actually need Hive or Hadoop (except from some specific files that manage the connection to S3). FOr this reason the Hive metastore is 'standalone'.

Ultimately, the Hive metastore is what allows us to query and interact with the data as if it were organized into tables, even when it's stored as file objects in an S3 bucket.

### Trino
Trino is a query engine that can connect to different data sources and query data in lots of formats. It is not itself a database though, instead it relies on connecting to a catalog like the Hive Metastore to access data. Trino can execute queries and return conventionally formatted tabular data via conventional database drivers like python's sqlalchemy, odbc and jdbc.

### Secrets

At present, configuration files that enable trino and hive metastore to connect to S3 both rely on hard-coded, as this presents a risk gitleaks has been enabled as a precommit hook on this repo.

## Testing the Data Connector

To test the data connector once running, connect to trino, create a schema, create a table and execute a select query.

The trino cli is setup within the trino container, you should be able to connect to it directly with:

`docker exec -it trino /usr/local/trino/bin/trino http://localhost:8080`

You should then see a `trino >` prompt. Note that this is the minimal command to access the interative cli, [full options are given in the docs](https://trino.io/docs/current/client/cli.html).

From the trino prompt, if you haven't done so previous you'll need to establish a schema, e.g.

```{sql}
CREATE SCHEMA IF NOT EXISTS hive.test
WITH (location = 's3a://asf-mission-data-tool/test/');
```

Now, create a table against that schema, e.g.

```{sql}
CREATE TABLE hive.test.DeploymentGovernmentScheme (
	installation_quarter varchar,
	year integer,
	start_of_quarter timestamp,
	end_of_quarter timestamp,
	government_scheme varchar,
	installations integer
	) WITH (
	external_location = 's3a://asf-mission-data-tool/test/heat_pump_deployment_quarterly_statistics/LATEST/Heat_pump_deployment_quarterly_statistics_United_Kingdom_2024_Q4_Table_1_1',
	format = 'PARQUET'
);
```

Finally, execute a query against that table, e.g.

```{sql}
SELECT * from hive.test.DeploymentGovernmentScheme LIMIT 15;
```

You should see a table printed to the terminal. Trino cli uses the [less pager](https://en.wikipedia.org/wiki/Less_(Unix)) to display data, which may be unfamiliar at first.