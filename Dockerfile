# Specify a different Prometheus version as needed
ARG PROMETHEUS_VERSION=2.52.0

# Use the official Prometheus base image
FROM prom/prometheus:v${PROMETHEUS_VERSION}

# Apply this repo's prometheus.yml file
ADD prometheus.yml /etc/prometheus/
ADD web.yml /etc/prometheus/

# Sets the Render service name in prometheus.yml
# using the RENDER_SERVICE_NAME environment variable
ARG RENDER_SERVICE_NAME
RUN sed -i "s/RENDER_SERVICE_NAME/${RENDER_SERVICE_NAME}/g" /etc/prometheus/prometheus.yml

ARG GRAFANA_USERNAME
ARG GRAFANA_PASSWORD
RUN sed -i "s/GRAFANA_USERNAME/${GRAFANA_USERNAME}/g" /etc/prometheus/prometheus.yml
RUN sed -i "s/GRAFANA_PASSWORD/${GRAFANA_PASSWORD}/g" /etc/prometheus/prometheus.yml

ARG THEIRSTACK_API_METRICS_ENDPOINT_USERNAME
ARG THEIRSTACK_API_METRICS_ENDPOINT_PASSWORD
RUN sed -i "s/THEIRSTACK_API_METRICS_ENDPOINT_USERNAME/${THEIRSTACK_API_METRICS_ENDPOINT_USERNAME}/g" /etc/prometheus/prometheus.yml
RUN sed -i "s/THEIRSTACK_API_METRICS_ENDPOINT_PASSWORD/${THEIRSTACK_API_METRICS_ENDPOINT_PASSWORD}/g" /etc/prometheus/prometheus.yml

ARG PROMETHEUS_PUSHGATEWAY_USERNAME
ARG PROMETHEUS_PUSHGATEWAY_PASSWORD
RUN sed -i "s/PROMETHEUS_PUSHGATEWAY_USERNAME/${PROMETHEUS_PUSHGATEWAY_USERNAME}/g" /etc/prometheus/prometheus.yml
RUN sed -i "s/PROMETHEUS_PUSHGATEWAY_PASSWORD/${PROMETHEUS_PUSHGATEWAY_PASSWORD}/g" /etc/prometheus/prometheus.yml

# Run as a forwarding-only Prometheus Agent: scrape + remote_write to Grafana
# Cloud, with no local block storage. Grafana Cloud is the query backend (the
# remote_write target), so this instance never needs to serve queries or keep a
# local TSDB. Agent mode keeps only a small WAL that is truncated as soon as
# samples are shipped, which removes the multi-GB head/WAL that was OOM-killing
# the server-mode setup on every boot.
#
# The leading `rm` is a one-time cleanup of the TSDB left by the old server-mode
# config. Without it the first boot would replay that bloated WAL and OOM-loop
# again; afterwards it is a harmless no-op (the directory no longer exists).
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["rm -rf /var/data/prometheus; exec /bin/prometheus \
      --config.file=/etc/prometheus/prometheus.yml \
      --web.config.file=/etc/prometheus/web.yml \
      --enable-feature=agent \
      --storage.agent.path=/var/data/agent"]
