# Specify a different Prometheus version as needed
ARG PROMETHEUS_VERSION=2.52.0

# Use the official Prometheus base image
FROM prom/prometheus:v${PROMETHEUS_VERSION}

# Add the prometheus.yml file
ADD prometheus.yml /etc/prometheus/prometheus.yml.template

# Substitute environment variables in prometheus.yml
ARG GRAFANA_USERNAME
ARG GRAFANA_PASSWORD
ENV GRAFANA_USERNAME=${GRAFANA_USERNAME}
ENV GRAFANA_PASSWORD=${GRAFANA_PASSWORD}

# Use a shell script to substitute environment variables
RUN sh -c 'envsubst < /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml'

# Sets the storage path to your persistent disk path,
# plus other config
CMD [ "--storage.tsdb.path=/var/data/prometheus", \
      "--config.file=/etc/prometheus/prometheus.yml", \
      "--web.console.libraries=/usr/share/prometheus/console_libraries", \
      "--web.console.templates=/usr/share/prometheus/consoles" ]