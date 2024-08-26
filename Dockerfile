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

# Sets the storage path to your persistent disk path,
# plus other config
CMD [ "--storage.tsdb.path=/var/data/prometheus", \
      "--web.config.file=/etc/prometheus/web.yml", \
      "--config.file=/etc/prometheus/prometheus.yml", \
      "--web.console.libraries=/usr/share/prometheus/console_libraries", \
      "--web.console.templates=/usr/share/prometheus/consoles" ]
