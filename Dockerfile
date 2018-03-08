FROM openjdk:8u131-jdk-alpine

# builds to ~475mb

# Immutable ENV vars
ENV ENV="/etc/profile" \
    APP_PACKAGE=stanford-ner-2017-06-09

# install curl and dumb-init
RUN apk --update --no-cache add curl dumb-init && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /app

# install the nlp package
RUN curl https://nlp.stanford.edu/software/${APP_PACKAGE}.zip -o /tmp/${APP_PACKAGE}.zip && \
    unzip /tmp/${APP_PACKAGE}.zip -d /app

# Reset the working directory (convox can only handle one WORKDIR directive)
WORKDIR /app/${APP_PACKAGE}

# Mutable ENV vars
ENV APP_MEMORY=512m \
    APP_PORT=9000 \
    APP_CLASSIFIER=classifiers/english.all.3class.distsim.crf.ser.gz \
    APP_OUTPUT_FORMAT=inlineXML

# expose our service port
EXPOSE $APP_PORT

# start with our PID 1 controller
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD /usr/bin/java -mx${APP_MEMORY} \
    -cp stanford-ner.jar edu.stanford.nlp.ie.NERServer \
    -loadClassifier ${APP_CLASSIFIER} \
    -port ${APP_PORT} -outputFormat ${APP_OUTPUT_FORMAT}
