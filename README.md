# prometheus-buildpack

Deploy your prometheus configuration to Cloud Foundry.

## Usage

Put your config in a file called `prometheus.yml`.  Set this as your
last buildpack.

Prometheus will be started to listen on `$PORT` rather than 9090.

### Configuration

You can specify the following environment variables:

 - `PROMETHEUS_FLAGS` - a string containing any command-line flags
   you'd like to provide to prometheus.  For example:
   `--web.external-url=https://prometheus.example.com`.
