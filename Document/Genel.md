# Ubuntu Üzerinde KVM + QEMU ile Yüksek Performanslı Windows Kullanımı

  

Bu dokümanın amacı, **dual boot kullanmadan**, **kapalı kaynak sanallaştırma çözümlerine (VirtualBox, VMware vb.) bulaşmadan**, Ubuntu üzerinde **donanıma en yakın performansla** bir Windows sistemi çalıştırmaktır.

  

Burada anlatılan yöntem;

- KVM’nin kernel-level sanallaştırma kabiliyetlerini,

- QEMU’nun esnek donanım soyutlamasını,

- VirtIO paravirtual sürücülerini,

- RDP tabanlı modern bir kullanım yaklaşımını

  

bir araya getirerek **günlük işlerde kullanılabilir**, **stabil**, **kontrollü** bir Windows ortamı sunar.

  

---

  

## 1. Neden Bu Yöntem?

  

### 1.1 Dual Boot Neden Tercih Edilmez?

  

- Disk bölme riski

- Veri kaybı ihtimali

- Her OS değişiminde reboot zorunluluğu

- Windows’un diske doğrudan müdahalesi

  

### 1.2 VirtualBox / VMware Neden Değil?

  

- Yazılım seviyesinde sanallaştırma

- Kernel entegrasyonu yok veya sınırlı

- Performans kaybı

- Kapalı kaynak sürücüler

- Host sistemde kalıntı bırakma

  

### 1.3 KVM + QEMU Ne Sağlar?

  

- **Donanımsal sanallaştırma (VT-x / AMD-V)**

- Linux kernel ile doğrudan entegre çalışma

- CPU talimatlarının neredeyse birebir iletilmesi

- Şeffaf, açık kaynak, kontrol edilebilir yapı

  

Bu sebeple bu dokümanda **KVM + QEMU** tercih edilmiştir.

  

---

  

## 2. Sistem Gereksinimleri

  

### 2.1 Donanım

  

| Bileşen | Minimum | Önerilen |

|------|--------|----------|

| CPU | VT-x / AMD-V destekli | Çok çekirdekli |

| RAM | 8 GB | 16 GB+ |

| Disk | 50 GB boş alan | 100 GB+ SSD |

  

> GPU Passthrough **zorunlu değildir**. Bu doküman CPU passthrough + RDP yaklaşımını temel alır.

  

### 2.2 BIOS / UEFI Ayarları

  

Aşağıdaki ayarlar **aktif olmalıdır**:

  

- Intel Virtualization Technology / SVM

- VT-d / IOMMU (zorunlu değil ama sorun çıkarmaz)

  

Secure Boot Linux tarafında açık veya kapalı olabilir.

  

---

  

## 3. Linux Tarafı Kurulum

  

### 3.1 KVM ve QEMU Kurulumu

  

#### Debian / Ubuntu Tabanlı

```bash

sudo apt install qemu-kvm qemu-utils

sudo usermod -aG kvm $USER

  

```
#### Arch Linux

`sudo pacman -S qemu-base`

#### Gentoo

`sudo emerge -av app-emulation/qemu gpasswd -a kullaniciadi kvm`

> Kullanıcıyı `kvm` grubuna ekledikten sonra **oturumu kapatıp açmak gerekir**.

---

## 4. Disk İmajı Oluşturma

### 4.1 Neden qcow2?

- Dinamik disk kullanımı
    
- Snapshot alma imkanı
    
- Fiziksel disk kadar yer kaplamaz
    

`qemu-img create -f qcow2 ~/windows.qcow2 50G`

---

## 5. Windows ISO Seçimi

### 5.1 Neden Windows 11 Enterprise LTSC?

- Düşük telemetri
    
- Gereksiz servisler yok
    
- Uzun süreli destek
    
- RDP özelliği varsayılan gelir
    

> Home sürümü **kullanılmamalıdır** (RDP yoktur).

---

## 6. UEFI (OVMF) Dosyası

Windows 11 için UEFI gereklidir.

`https://github.com/clearlinux/common/blob/master/OVMF.fd`

Dosyayı `~/OVMF.fd` olarak kaydedin.

---

## 7. İlk Kurulum (Offline)

``qemu-system-x86_64 \   --enable-kvm \   -m 8G \   -smp `nproc` \   -cpu host \   -cdrom ~/Downloads/windows.iso \   -hda ~/windows.qcow2 \   -net none \   -bios ~/OVMF.fd \   -usbdevice tablet``

### Kritik Parametreler

- `--enable-kvm`: Donanım sanallaştırma
    
- `-cpu host`: Fiziksel CPU özelliklerini birebir geçirir
    
- `-net none`: Microsoft hesabı ve telemetriyi engeller
    
- `-usbdevice tablet`: Fare senkronizasyonu
    

---

## 8. Windows 11 TPM & Secure Boot Bypass

Kurulum ekranında:

**Shift + F10** → `regedit`

`HKEY_LOCAL_MACHINE\SYSTEM\Setup`

Yeni anahtar:

`LabConfig`

İçine 3 adet DWORD (32-bit):

|İsim|Değer|
|---|---|
|BypassTPMCheck|1|
|BypassSecureBootCheck|1|
|BypassRAMCheck|1|

---

## 9. Microsoft Hesabı Bypass (OOBE)

Kurulum sırasında:

**Shift + F10**

`OOBE\BYPASSNRO`

Sistem reboot olur ve **internetsiz kurulum** seçeneği gelir.

> Kullanıcı adı **İngilizce, bitişik ve sade** olmalıdır.

---

## 10. VirtIO Sürücüleri

### 10.1 VirtIO Nedir?

VirtIO, sanal makine ile host arasında **paravirtual** bir köprü kurar.  
Disk, ağ ve giriş/çıkış performansının asıl artışı buradan gelir.

### 10.2 VirtIO ISO

`https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/`

ISO’yu CD-ROM olarak bağlayın ve:

- `virtio-win-guest-tools`
    
- 64-bit sürücüler
    

kurulumu yapın.

---

## 11. Windows Temizliği (Debloat)

### 11.1 Defender Kaldırma (Opsiyonel)

⚠️ Güvenlik sorumluluğu kullanıcıya aittir.

`https://github.com/ionuttbara/windows-defender-remover`

### 11.2 Windows Debloat Script

Yönetici PowerShell:

`& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))`

Önerilen:

- Default mode
    
- Microsoft Store **kalsın**
    

---

## 12. RDP Kullanımı (Önerilen)

### 12.1 Neden RDP?

- Full HD / yüksek çözünürlük
    
- Daha stabil input
    
- Düşük latency
    
- Font rendering daha düzgün
    

### 12.2 RDP Açma

Windows Ayarlar → Uzak Masaüstü → Açık

Port:

`3389`

---

## 13. Nihai Çalıştırma Script’i (run.sh)

``qemu-system-x86_64 \   --enable-kvm \   -m 8G \   -smp `nproc` \   -cpu host \   -drive file=windows.qcow2,format=qcow2,cache=writeback,aio=native \   -rtc base=localtime \   -bios ~/OVMF.fd \   -display none \   -net user,hostfwd=tcp::3389-:3389 -net nic``

---

## 14. Remmina ile Bağlantı

`sudo apt install remmina remmina-plugin-rdp`

Sunucu:

`127.0.0.1:3389`

Çözünürlük:

`1920x1080`

---

## 15. Dosya Paylaşımı (rclone WebDAV)

### 15.1 Host Tarafı

`sudo apt install rclone rclone serve webdav --addr 127.0.0.1:8000 $HOME`

### 15.2 Windows Tarafı

Ağ sürücüsü bağla:

`http://10.0.2.2:8000`

> `10.0.2.2` QEMU’nun host adresidir.

---

## 16. Font ve Klavye Sorunları

### 16.1 ClearType

Başlat → ClearType → Ayarla

### 16.2 Türkçe Klavye Kalıcı Yapma

Startup klasörüne `TR.reg`:

`Windows Registry Editor Version 5.00  [HKEY_USERS\.DEFAULT\Keyboard Layout\Preload] "1"="0000041F"`

---

## 17. Sonuç

Bu yapı ile:

- Disk bölmeden
    
- Reboot atmadan
    
- Kapalı kaynak çözümler kullanmadan
    
- Yüksek performanslı
    

bir Windows ortamı elde edilmiş olur.

Linux ana sistem olarak kalır,  
Windows ise **kontrollü bir araç** haline gelir.

---

## 18. Kapsam Dışı Bırakılanlar

- GPU Passthrough
    
- Oyun / ağır 3D kullanım
    
- USB IOMMU senaryoları
    

Bu konular **ayrı ve daha ileri seviye** başlıklardır.

---

**Bitti.**