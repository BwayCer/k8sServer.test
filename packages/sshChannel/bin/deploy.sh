#!/bin/bash

set -ex

projectDir=$(realpath "$(dirname "$(realpath "$0")")/..")

# 創建命名空間
if ! kubectl get namespaces | sed 1d | awk '{print $1}' | grep ssh-channel ; then
  docker tag local/ssh-channel/dev/traefik-sshentry:v2.3 us.gcr.io/tg-tool/traefik-sshentry:v2.3
  docker push us.gcr.io/tg-tool/traefik-sshentry:v2.3

  kubectl create namespace ssh-channel

  # 創建密鑰
  kubectl -n ssh-channel create secret generic \
    sshfile \
    --from-file=authorized_keys=$projectDir/secretfile/sshfile/authorized_keys

  tmpDeployDirPath="$projectDir/tmp-deploy"
  mkdir -p "$tmpDeployDirPath"
  "$projectDir/../../bin/shTemplate" -t "$projectDir/vmfile/traefik-sshentry/k8s/" -o  "$tmpDeployDirPath/shtt"

  kubectl -n ssh-channel apply -f "$tmpDeployDirPath/shtt/pvc-container.yml"
  kubectl -n ssh-channel apply -f "$tmpDeployDirPath/shtt/traefik-sshentry.yml"
  kubectl -n ssh-channel apply -f "$tmpDeployDirPath/shtt/traefik-sshentry.yml"
  echo kubectl -n ssh-channel cp "$projectDir/mntfile/traefik/..." "<pod>:/app/..."
else
  echo "部署文件並不完善，不建議覆蓋更新。" >&2
  exit 1
fi

