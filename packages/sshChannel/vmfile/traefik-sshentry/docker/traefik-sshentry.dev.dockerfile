# MAINTAINER BwayCer (https://github.com/BwayCer/image.docker)


FROM traefik:v2.3

WORKDIR /app

COPY ./buildRepo/ /tmp/buildRepo/

RUN passwd -d root && \
    apk add --no-cache openssh-server

# 創建安全殼密鑰文件
RUN for typeName in rsa dsa ecdsa ed25519; do \
      ssh-keygen -t "$typeName" -f "/etc/ssh//ssh_host_${typeName}_key" -P ""; \
    done
# 修改安全殼設定文件
#   登入權限
#     https://blog.tankywoo.com/linux/2013/09/14/ssh-passwordauthentication-vs-challengeresponseauthentication.html
#     二者皆為 "no" 才算完全禁用密碼登入
#     ```
#     PasswordAuthentication no            # 是否允許密碼登入
#     ChallengeResponseAuthentication no   # 是否允許交互式密碼登入
#     ```
#   轉發設定
#     ```
#     AllowAgentForwarding yes   # 使否允許代理轉發
#     GatewayPorts yes           # 使否允許外部連接到轉發的端口 (0.0.0.0)
#     AllowTcpForwarding yes
#     ```
RUN /tmp/buildRepo/tool/insertSshdConfig.sh "PasswordAuthentication" "no" && \
    /tmp/buildRepo/tool/insertSshdConfig.sh "ChallengeResponseAuthentication" "no" && \
    /tmp/buildRepo/tool/insertSshdConfig.sh "AllowAgentForwarding" "yes" && \
    /tmp/buildRepo/tool/insertSshdConfig.sh "GatewayPorts" "yes" && \
    /tmp/buildRepo/tool/insertSshdConfig.sh "AllowTcpForwarding" "yes"

RUN cp /tmp/buildRepo/sshentry/docker-entrypoint.sh /entrypoint.sh

RUN rm -rf /tmp/buildRepo/

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["traefik"]

