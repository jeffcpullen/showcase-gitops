FROM quay.io/devfile/universal-developer-image:ubi8-d071837

WORKDIR /home/user
USER 10001

# podman-compose & docker-compose
RUN pip3 install podman-compose
USER 0
RUN mv  ~/.local/bin/podman-compose ~/.local/bin/podman-compose-orig
RUN curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o ~/.local/bin/docker-compose
RUN chmod +x ~/.local/bin/docker-compose
RUN chgrp -R 0 ~/.local/bin && chmod -R g=u /etc/passwd /etc/group ~/.local/bin
USER 10001
COPY podman-compose /home/user/.local/bin/podman-compose
USER 0
RUN chgrp -R 0 /home/user/.local/bin/podman-compose && chmod -R g=u /etc/passwd /etc/group /home/user/.local/bin/podman-compose
RUN chmod +x /home/user/.local/bin/podman-compose

USER 10001