FROM alpine:3.6

# 1 Install Rclone
RUN apk add --no-cache openssl

# 3. Install Rclone
RUN wget https://downloads.rclone.org/v1.39/rclone-v1.39-linux-amd64.zip
RUN unzip /rclone-v1.39-linux-amd64.zip
RUN rm /rclone-v1.39-linux-amd64.zip
RUN mv /rclone-v1.39-linux-amd64/rclone /usr/bin


# Add scripts
ADD sync.sh /root/sync.sh
RUN chmod +x /root/sync.sh

ADD docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

ADD crontab crontab 
RUN /usr/bin/crontab crontab
RUN rm crontab

# Squashing using multistage
FROM alpine:3.6
COPY --from=0 / /

# We run cron in foreground to update the certificates
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/crond", "-f"]
