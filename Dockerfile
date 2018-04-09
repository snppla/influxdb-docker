from alpine as build

RUN apk add --update make automake gcc g++ git go

ENV GOPATH=/go
ENV GOBIN=/go/bin
ENV PATH=$PATH:/go/bin

RUN go get -u github.com/influxdata/influxdb

WORKDIR /go/src/github.com/influxdata/influxdb/cmd/influxd
RUN go get
RUN go install

WORKDIR /go/src/github.com/influxdata/influxdb/cmd/influx
RUN go get
RUN go install

########################
FROM alpine as main
RUN apk add --update bash
COPY --from=build /go/bin/influx* /usr/bin/
ADD influxdb.conf /etc/influxdb/influxdb.conf

VOLUME /var/lib/influxdb/

COPY entrypoint.sh /entrypoint.sh
COPY init-influxdb.sh /init-influxdb.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["influxd"]
