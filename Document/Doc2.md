# Ubuntu Üzerinde KVM + QEMU ile Yüksek Performanslı Linux Sanal Makine Kullanımı

Bu dokümanın amacı, Ubuntu ana sistem (host) üzerinde **dual boot yapmadan**, **masaüstü sanallaştırma yazılımlarına (VirtualBox, VMware) ihtiyaç duymadan**, **donanıma çok yakın performansla** bir Linux misafir (guest) işletim sistemi çalıştırmaktır.

Bu yaklaşım özellikle:
- Farklı Linux dağıtımlarını test etmek,
- İzole geliştirme ortamları oluşturmak,
- Sunucu / servis simülasyonu yapmak,
- Günlük masaüstü kullanımını bozmadan ikinci bir Linux ortamı çalıştırmak

isteyen kullanıcılar için uygundur.

---

## 1. Neden KVM + QEMU ile Linux?

### 1.1 Dual Boot Neden Tercih Edilmez?

- Disk bölme riski
- Bootloader karmaşası
- Reboot zorunluluğu
- Ana sistemin bütünlüğünün bozulması

### 1.2 VirtualBox / VMware Neden Değil?

- Kernel dışı sanallaştırma
- Daha yüksek latency
- Performans kaybı
- Kapalı kaynak bileşenler

### 1.3 KVM + QEMU Avantajları

- Linux kernel ile **doğrudan entegrasyon**
- Donanım sanallaştırma (VT-x / AMD-V)
- Açık kaynak, denetlenebilir yapı
- Sunucu tarafında da kullanılan endüstri standardı

---

## 2. Sistem Gereksinimleri

### 2.1 Donanım Gereksinimleri

| Bileşen | Minimum | Önerilen |
|------|--------|----------|
| CPU | VT-x / AMD-V | Çok çekirdekli |
| RAM | 8 GB | 16 GB+ |
| Disk | 20 GB | 50 GB+ SSD |

> GPU passthrough **zorunlu değildir**. Bu doküman yazılım tabanlı grafik + VirtIO yaklaşımını esas alır.

### 2.2 BIOS / UEFI Ayarları

- Virtualization Technology: **Açık**
- IOMMU: Opsiyonel
- Secure Boot: Açık veya kapalı olabilir

---

## 3. Host (Ubuntu) Tarafı Kurulum

### 3.1 KVM ve QEMU Kurulumu

#### Debian / Ubuntu
```bash
sudo apt install qemu-kvm qemu-utils virt-manager
sudo usermod -aG kvm $USER
```


Arch Linux

sudo pacman -S qemu-base virt-manager

    Kullanıcı kvm grubuna eklendikten sonra oturum kapatılıp açılmalıdır.

4. Disk İmajı Oluşturma
4.1 Disk Formatı Seçimi

    qcow2 önerilir:

        Dinamik disk kullanımı

        Snapshot alma

        Daha esnek yapı

qemu-img create -f qcow2 ~/linux.qcow2 40G

5. Linux ISO Seçimi

Bu yöntem neredeyse tüm modern Linux dağıtımları ile uyumludur.

Örnekler:

    Ubuntu Desktop / Server

    Debian

    Fedora

    Arch Linux

    Alpine Linux

ISO dosyasını resmi sitesinden indirmeniz önerilir.
6. UEFI (OVMF) Kullanımı

Modern Linux dağıtımları UEFI ile sorunsuz çalışır.

https://github.com/clearlinux/common/blob/master/OVMF.fd

Dosyayı:

~/OVMF.fd

konumuna yerleştirin.
7. Linux Kurulumu (İlk Başlatma)

qemu-system-x86_64 \
  --enable-kvm \
  -m 8G \
  -smp `nproc` \
  -cpu host \
  -cdrom ~/Downloads/linux.iso \
  -hda ~/linux.qcow2 \
  -boot d \
  -bios ~/OVMF.fd \
  -vga virtio \
  -device usb-tablet

Parametre Açıklamaları

    --enable-kvm: Donanımsal sanallaştırma

    -cpu host: CPU özelliklerini birebir geçirir

    -vga virtio: Yazılım tabanlı ama yüksek performanslı grafik

    -device usb-tablet: Doğru fare senkronizasyonu

8. Linux Kurulum Süreci

Kurulum, seçilen dağıtıma göre değişir ancak genel prensipler aynıdır:

    Disk olarak tamamını kullan

    Swap:

        RAM ≤ 8 GB → önerilir

        RAM ≥ 16 GB → opsiyonel

    Masaüstü kuruluyorsa minimum paket seçimi önerilir

    Linux tarafında TPM, Secure Boot bypass gibi işlemlere ihtiyaç yoktur.

9. VirtIO Sürücüleri ve Performans
9.1 VirtIO Nedir?

VirtIO, misafir sistem ile host arasında paravirtual bir iletişim katmanı sağlar.

Linux çekirdeği VirtIO sürücülerini doğal olarak içerir.

Bu sebeple:

    Ek sürücü kurulumuna gerek yoktur

    Disk ve ağ performansı varsayılan olarak yüksektir

9.2 Kontrol

Misafir Linux içinde:

lsmod | grep virtio

çıktısı alınabiliyorsa sürücüler aktiftir.
10. Grafik Kullanım Yaklaşımı
10.1 QEMU Pencere Modu

    Kurulum ve temel kullanım için yeterlidir

    Düşük gecikme

    Basit yapı

10.2 SPICE / Virt-Viewer (Opsiyonel)

Daha iyi clipboard, çözünürlük ve tam ekran için:

sudo apt install virt-viewer spice-client-gtk

11. Nihai Çalıştırma Script’i (run.sh)

qemu-system-x86_64 \
  --enable-kvm \
  -m 8G \
  -smp `nproc` \
  -cpu host \
  -drive file=linux.qcow2,format=qcow2,cache=writeback,aio=native \
  -rtc base=localtime \
  -bios ~/OVMF.fd \
  -vga virtio \
  -device usb-tablet \
  -net user

Bu script, günlük kullanım için yeterli ve stabildir.
12. Ağ Yapılandırması
12.1 User Network (Varsayılan)

Avantajlar:

    Ek yapılandırma gerekmez

    Güvenlidir

    İnternet erişimi vardır

Misafir IP’si genelde:

10.0.2.x

Host adresi:

10.0.2.2

13. Dosya Paylaşımı (Host ↔ Guest)
13.1 VirtIO-FS (Önerilen)

Host:

sudo apt install virtiofsd

QEMU parametresi:

-object memory-backend-file,id=mem,size=8G,mem-path=/dev/shm,share=on \
-numa node,memdev=mem \
-chardev socket,id=char0,path=/tmp/vfs.sock \
-device vhost-user-fs-pci,chardev=char0,tag=shared

Guest:

sudo mount -t virtiofs shared /mnt

13.2 Alternatif: SSHFS

Basit ve güvenli:

sshfs user@10.0.2.2:/home/user /mnt/host

14. Ses Desteği (Opsiyonel)

-audiodev pa,id=snd0 \
-device ich9-intel-hda \
-device hda-output,audiodev=snd0

15. Klavye ve Dil Ayarları

Misafir Linux içinde:

setxkbmap tr

Kalıcı yapmak için masaüstü ayarları kullanılmalıdır.
16. Snapshot ve Geri Dönüş

qemu-img snapshot -c temiz_kurulum linux.qcow2
qemu-img snapshot -l linux.qcow2
qemu-img snapshot -a temiz_kurulum linux.qcow2

17. Sonuç

Bu yapı ile:

    Ana Linux sistem bozulmaz

    Reboot gerekmez

    Farklı dağıtımlar güvenle denenir

    Sunucu ve masaüstü senaryoları rahatça simüle edilir

Linux, Linux içinde kontrollü ve izole şekilde çalıştırılmış olur.
18. Kapsam Dışı Bırakılanlar

    GPU Passthrough

    PCIe cihaz aktarımı

    Çoklu VM orkestrasyonu

Bu başlıklar ileri seviye konulardır ve ayrı doküman gerektirir.