# prometheus-buildpack

Deploy your prometheus configuration to Cloud Foundry.

## Usage

Put your config in a file called `prometheus.yml`.  Set this as your
last buildpack.

Prometheus will be started to listen on `$PORT` rather than 9090.

### Configuration

You can specify the following environment variables:
 - AUTO_DB_SETUP  default is false , if set true it will try to configure prometheus with influx db automatically
 - PROMETHEUS_DB_SERVICE_NAME , default is null/not defined, if  you set this variable , it will configure prometheus to use named influxdb service
 - `PROMETHEUS_FLAGS` - a string containing any command-line flags
   you'd like to provide to prometheus.  For example:
   `--web.external-url=https://prometheus.example.com`.

 - supports runtime.txt in which, you can sepcify desired prometheus version to be installed 
 - supports prometheus.yml with environment variables

### Influxdb support

If you bind a service of type `influxdb` to your prometheus app, the
buildpack will detect this and automatically append `remote_read` and
`remote_write` sections to your prometheus.yml file before starting
prometheus.  This is done in a very naive way.  For this reason, if
you bind an `influxdb` service, you should not set your own
`remote_read` or `remote_write` configuration or the resulting YAML
file will be invalid with duplicate keys.
