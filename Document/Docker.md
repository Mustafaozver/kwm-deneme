# Docker Üzerinde GUI Tabanlı Linux Uygulamalarını Native Gibi Çalıştırma Rehberi

Bu dokümanın amacı, Docker kullanarak **grafik arayüzlü (GUI) Linux uygulamalarını** konteyner içinde çalıştırmak ve bu uygulamaları **kendi masaüstünde, sanki sisteme kurulmuş gibi** kullanabilmektir.

Bu yaklaşım sayesinde:
- Ana sisteminiz kirlenmez
- Bağımlılık çatışmaları yaşanmaz
- Uygulamalar izole çalışır
- Aynı uygulama her makinede aynı davranışı gösterir
- Sanal makine maliyetine girmeden GUI uygulamalar kullanılabilir

---

## 1. Docker ve GUI Konteyner Mantığı

### 1.1 Docker Nedir?

Docker, bir uygulamayı:
- Kodları
- Bağımlılıkları
- Sistem kütüphaneleri
- Çalışma ayarları

ile birlikte **konteyner** adı verilen izole bir ortamda çalıştırır.

Konteynerler:
- Host sistemin kernel’ini paylaşır
- Sanal makinelere göre çok daha hafiftir
- Saniyeler içinde başlar

---

### 1.2 GUI Konteyner Nedir?

Standart Docker konteynerleri genelde **CLI (komut satırı)** uygulamaları çalıştırır.  
GUI konteynerler ise:

- Firefox
- Gedit
- LibreOffice
- Grafik araçlar

gibi **pencere açan uygulamaların**, host sistemin **X Server / Wayland** altyapısını kullanarak **ekranda görünmesini** sağlar.

Bunun için konteyner ile host arasında:
- Görüntü soketleri
- Ortam değişkenleri
- Yetkilendirme

paylaşılır.

---

## 2. GUI Uygulamaları Docker’da Neden Çalıştırılır?

Docker’da GUI uygulamaları çalıştırmanın başlıca sebepleri:

- 📦 **Bağımlılık izolasyonu**  
  Uygulamanın ihtiyaç duyduğu tüm kütüphaneler konteyner içindedir.

- 🔁 **Taşınabilirlik**  
  Aynı Docker imajı her Linux sistemde aynı şekilde çalışır.

- 🧪 **Güvenli test ortamı**  
  Ana sistemi etkilemeden uygulama denenebilir.

- 🖥️ **Native deneyim**  
  Uygulama doğrudan masaüstünde açılır, VM hissi yoktur.

- ⚡ **Düşük kaynak tüketimi**  
  Sanal makinelere kıyasla çok daha az RAM ve CPU kullanır.

---

## 3. Ubuntu Üzerinde Docker Kurulumu

### 3.1 Docker GPG Anahtarını Doğrulama

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --show-keys --with-fingerprint
```

Beklenen parmak izi (kontrol edilmelidir):

`9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`

---

### 3.2 GPG Anahtarını Sisteme Ekleme

`sudo mkdir -p /etc/apt/keyrings curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg sudo chmod a+r /etc/apt/keyrings/docker.gpg`

---

### 3.3 Docker Deposu Ekleme

`sudo nano /etc/apt/sources.list.d/docker.list`

İçine şunu ekleyin:

`deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable`

---

### 3.4 Docker Paketlerini Kurma

`sudo apt update && sudo apt upgrade sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin`

---

### 3.5 Docker’ı Sudo’suz Kullanma

`sudo adduser $USER docker`

> Oturumu kapatıp tekrar giriş yapmanız gerekir.

Kontrol:

`docker --version`

---

## 4. Docker Servisini Çalıştırma

`sudo systemctl start docker sudo systemctl enable docker sudo systemctl status docker`

---

## 5. GUI Uygulaması İçin Proje Yapısı

`mkdir dockerGUI cd dockerGUI`

---

## 6. Dockerfile Oluşturma (GUI Uygulaması)

### 6.1 Firefox Örneği

`nano Dockerfile`

`FROM jess/firefox ENV DISPLAY=:0 CMD ["firefox"]`

Bu Dockerfile:

- Firefox hazır imajını kullanır
    
- DISPLAY değişkenini ayarlar
    
- Konteyner başladığında Firefox’u açar
    

---

### 6.2 Alternatif: Gedit Örneği

`FROM ubuntu:22.04 RUN apt-get update && apt-get install -y gedit ENV DISPLAY=:0 CMD ["gedit"]`

---

## 7. Docker İmajını Oluşturma

`docker build -t myguiapp:1 .`

---

## 8. X Server Yetkilendirmesi (Kritik Adım)

Docker konteynerinin ekranınıza erişebilmesi için:

`xhost +local:docker`

> Bu işlem **geçici** yetki verir. İşiniz bitince geri alınmalıdır.

---

## 9. GUI Uygulamasını Native Gibi Çalıştırma

`docker run -it --rm \   -e DISPLAY=$DISPLAY \   -v /tmp/.X11-unix:/tmp/.X11-unix \   myguiapp:1`

### Bu komut ne yapar?

- `DISPLAY`: Host ekranını konteynere aktarır
    
- `/tmp/.X11-unix`: X Server soketini paylaşır
    
- `--rm`: Uygulama kapanınca konteyneri siler
    

Sonuç:  
Uygulama **masaüstünüzde normal bir program gibi açılır**.

---

## 10. Güvenlik: X Server Yetkisini Geri Alma

İşiniz bittikten sonra:

`xhost -local:docker`

Bu adım **önemlidir**.

---

## 11. Wayland Kullanan Sistemler İçin Not

Wayland kullanıyorsanız:

- XWayland aktif olmalıdır
    
- Bazı uygulamalar sorun çıkarabilir
    

X11 oturumu GUI konteynerler için **daha stabildir**.

---

## 12. Kullanım Senaryoları

Bu yöntemle:

- Tarayıcıyı konteynerde çalıştırabilirsiniz
    
- Riskli uygulamaları izole edebilirsiniz
    
- Farklı Linux sürümlerine ait GUI araçları deneyebilirsiniz
    
- Ana sisteminizi kirletmeden test yapabilirsiniz
    

---

## 13. Sınırlamalar

- Donanım hızlandırmalı GPU kullanımı sınırlıdır
    
- Wayland uyumluluğu uygulamaya göre değişir
    
- Windows host’ta ek X Server yazılımları gerekir
    

---

## 14. Sonuç

Docker ile GUI uygulamaları çalıştırmak:

- Sanal makineye gerek bırakmaz
    
- Performanslıdır
    
- Temiz ve kontrollüdür
    

Doğru yapılandırıldığında, kullanıcıya **tamamen native bir masaüstü deneyimi** sunar.