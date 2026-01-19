#!/usr/bin/env bash

set -e

### GENEL DEĞİŞKENLER ###
APP_NAME="myguiapp"
APP_VERSION="1"
PROJECT_DIR="$HOME/dockerGUI"
DOCKERFILE_PATH="$PROJECT_DIR/Dockerfile"

echo "==> Docker GUI kurulumu başlatılıyor..."

### ROOT KONTROLÜ ###
if [[ $EUID -eq 0 ]]; then
  echo "Bu script root olarak çalıştırılmamalıdır."
  exit 1
fi

### SUDO KONTROLÜ ###
if ! sudo -v; then
  echo "Sudo yetkisi gerekli."
  exit 1
fi

### DOCKER KURULU MU KONTROL ###
if ! command -v docker &> /dev/null; then
  echo "==> Docker kuruluyor..."

  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
else
  echo "==> Docker zaten kurulu."
fi

### DOCKER SERVİSİ ###
echo "==> Docker servisi başlatılıyor..."
sudo systemctl enable docker
sudo systemctl start docker

### KULLANICIYI DOCKER GRUBUNA EKLE ###
if ! groups $USER | grep -q docker; then
  echo "==> Kullanıcı docker grubuna ekleniyor..."
  sudo usermod -aG docker $USER
  echo "!! Oturumu kapatıp açmanız önerilir !!"
fi

### PROJE DİZİNİ ###
echo "==> Proje dizini hazırlanıyor..."
mkdir -p "$PROJECT_DIR"

### DOCKERFILE OLUŞTUR ###
if [[ ! -f "$DOCKERFILE_PATH" ]]; then
  echo "==> Dockerfile oluşturuluyor..."
  cat <<EOF > "$DOCKERFILE_PATH"
FROM jess/firefox
ENV DISPLAY=:0
CMD ["firefox"]
EOF
else
  echo "==> Dockerfile zaten mevcut."
fi

### IMAGE BUILD ###
echo "==> Docker imajı oluşturuluyor..."
docker build -t ${APP_NAME}:${APP_VERSION} "$PROJECT_DIR"

### X SERVER YETKİ ###
echo "==> X Server erişimi veriliyor..."
xhost +local:docker

### KONTEYNER ÇALIŞTIR ###
echo "==> GUI uygulama başlatılıyor..."
docker run -it --rm \
  -e DISPLAY=\$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  ${APP_NAME}:${APP_VERSION}

### TEMİZLİK ###
echo "==> X Server erişimi geri alınıyor..."
xhost -local:docker

echo "==> İşlem tamamlandı."
