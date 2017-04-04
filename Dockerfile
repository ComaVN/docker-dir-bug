FROM busybox
RUN mkdir -p /bar
RUN rm -rf /bar ; mkdir -p /bar ; touch /bar/foo
RUN ls -ila /bar
RUN rm -rf /bar ; ls -ila /bar ; mkdir -p /bar ; ls -ila /bar
RUN ls -ila /bar
