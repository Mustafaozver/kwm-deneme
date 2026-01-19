
Windows işletim sistemini QEMU üzerinde kurmak için aşağıdaki adımları takip edebilirsiniz. Bu rehber, adım adım ilerleyerek gerekli hazırlıkları ve ayarları içermektedir.

---

## Hazırlık 🛠️

1. **QEMU Kurulumu**: Eğer QEMU yüklü değilse, sistemine uygun komutu kullanarak kurabilirsiniz:
```sh
#Debian tabanlı sistemlerde remmina kurulumu için:
sudo apt install qemu-kvm

#Arch tabanlı sistemlerde remmina kurulumu:
sudo pacman -S qemu-base 

#Gentoo tabanlı sistemlerde remmina kurulumu:
sudo emerge -av app-emulation/qemu
gpasswd -a kullaniciadi kvm #ile kullanıcınızı kvm içinne ekleyin(sadece gentoo için)
```

2. **Boş Alan Ayırma**: En az **50 GB** boş alan ayırın. Bu, Winodws'un düzgün çalışması için idealdir. 💾

3. **Windows ISO İndirme**: Windows'un LTSC sürümünü [indirin](https://archive.org/details/windows_11_enterprise_ltsc_2024). Bu sürüm, gereksiz bileşenlerden kaçınmanıza yardımcı olur. 📥


---

## Disk İmajı Hazırlanması 💽

Disk imajı oluşturmak için aşağıdaki komutu kullanın:
```sh
# Disk imajı oluşturun
qemu-img create -f qcow2 ~/winzort.qcow 50G
```
| Parça            | Açıklama                                                                                                                                                                                               |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `qemu-img`       | QEMU’nun disk yönetim aracıdır. Disk oluşturma, dönüştürme, yeniden boyutlandırma gibi işlemleri yapar.                                                                                                |
| `create`         | Yeni bir disk imajı oluşturacağımızı belirtir.                                                                                                                                                         |
| `-f qcow2`       | Disk formatını belirtir. `qcow2`, QEMU’nun kendi formatıdır (QEMU Copy-On-Write 2). Bu format, **anlık görüntü (snapshot)**, **veri sıkıştırma** ve **dinamik alan kullanımı** gibi avantajlar sağlar. |
| `~/winzort.qcow` | Oluşturulacak dosyanın ismi ve konumu. Burada `~` kullanıcının ev dizinidir.                                                                                                                           |
| `50G`            | Diskin sanal kapasitesi. Yani sanal olarak 50 GB görünecek. Ancak qcow2 dinamik çalıştığı için gerçekten 50 GB yer kaplamaz, sadece kullanılan kadar alan ayırır. 💾                                   |

---

## Windows Kurulumu 🏗️

Windows kurulumunu başlatmak için aşağıdaki komutu kullanın. Bu komut, ISO dosyasını ve disk imajını göstererek internetsiz bir kurulum yapmanızı sağlar. UEFI kurulumunu gerçekleştirmek için OVMF dosyasını indirmeniz gerekecek.

```sh
# OVMF.fd dosyasını indirin
# https://github.com/clearlinux/common/blob/master/OVMF.fd
qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -cdrom ~/Downloads/en-us_windows_10_consumer_editions_version_22h2_updated_feb_2023_x64_dvd_c29e4bb3.iso \
  -hda ~/winzort.qcow \
  -net none \
  -bios ~/OVMF.fd \
  -usbdevice tablet

```
| Satır                            | Açıklama                                                                                                                                              |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `qemu-system-x86_64`             | 64-bit sanal makine oluşturmak için QEMU’nun ana çalıştırıcısıdır.                                                                                    |
| `--enable-kvm`                   | Donanımsal sanallaştırmayı (KVM) etkinleştirir. Böylece sanal makine, işlemcinin gerçek gücünü kullanabilir. Bu, **performansı 5–10 kat arttırır**.   |
| `-m 8G`                          | Sanal makineye 8 GB RAM verir. Windows kurulumları için ideal minimum miktardır.                                                                      |
| `-smp \`nproc``                  | Tüm çekirdekleri kullan demektir. `nproc` komutu mevcut çekirdek sayısını döndürür. Böylece sanal makine, fiziksel CPU’nun tüm çekirdeklerine erişir. |
| `-cpu host`                      | Sanal CPU’yu, fiziksel işlemciyle aynı özelliklerde çalıştırır. Bu da performans artışı sağlar.                                                       |
| `-cdrom ~/Downloads/windows.iso` | ISO dosyasını CD-ROM olarak bağlar. Bu dosya kurulum medyasıdır.                                                                                      |
| `-hda ~/winzort.qcow`            | Birinci sabit disk olarak oluşturduğumuz sanal diski bağlar.                                                                                          |
| `-net none`                      | Kurulum sırasında interneti kapatır. Bu, Windows’un gereksiz güncellemeler veya Microsoft hesabı istemesini engeller.                                 |
| `-bios ~/OVMF.fd`                | Sanal makine BIOS’u yerine UEFI (OVMF) kullanır. Modern sistemlerde zorunludur.                                                                       |
| `-usbdevice tablet`              | Fare girişinin sanal ortamda düzgün çalışması için “tablet” tipinde USB cihazı ekler. Bu, imleç senkronizasyonu sağlar.                               |


Kurulum sırasında diskin tamamını kullanın ve oturum açmayın. 🚫


### TPM ve Secure Boot Hatası Çözümü

Windows 11 kurulumunda TPM ve Secure Boot hatası alıyorsanız, aşağıdaki adımları izleyerek bu sorunu çözebilirsiniz. 🚀

1. **Kuruluma başlamadan önce** `Shift + F10` tuşlarına basın.
2. **Regedit** uygulamasını açın: `regedit.exe` yazın ve Enter'a basın.
3. **HKEY_LOCAL_MACHINE\SYSTEM\Setup** yoluna gidin.
4. Sağ tıklayıp **Yeni** kısmından **LabConfig** adında bir anahtar oluşturun ve içine girin.
5. **BypassTPMCheck**, **BypassSecureBootCheck**, **BypassRAMCheck** adında 3 tane **DWORD (32-bit)** oluşturun ve değerini **1** yapın.
6. Kuruluma devam edin. 🎉


### Format Sonrası İnternetsiz Kurulum Yapmak 

Windows11'i diske kurduktan sonra bizden tam kurulumu yapmak için geldiğimiz noktada hesap açmamamız bizim için en sağlıklı yöntem bunun için
1. **Başlangıç ayarları kısmında internet kısmına kadar geliyoruz** `Shift + F10` tuşlarına basıyoruz
2. **Açılan Terminal penceresine**
```reg
OOBE\BYPASSNRO
```
3. **Yazıyor ve sistemi kapatıp açıyoruz**
4. **İnternetsiz kuruluma devam edip sadece İngilizce latin harfleri ve rakamlar içeren kullanıcı adı ve şifre seçiyoruz**

Kurulum tamamen tamamlandıktan sonra `-net none` parametresine artık ihtiyaç duymayacaksınız.

---



## Virtio Yükleme 🚀

Virtio sürücülerini yüklemek, çözünürlük ve performans sorunlarını gidermek için önemlidir.

1. **Sanal Makineyi Kapatın**. 📴
2. **Virtio ISO'sunu İndirin**: Aşağıdaki bağlantıdan uygun sürümün ISO dosyasını indirin ve CD-ROM olarak bağlayın:
   [Virtio Sürücü İndirme](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/)
3. **Windows'u Başlatın** ve sürücüleri ve misafir araçlarını yükleyin. 💻
4. **Sanal Makinayı Yeniden Başlatın**. 🔄

---

## Edge, Defender ve Gereksiz Programları Kaldırma ❌

Windows Defender, ve diğer servis ve programlar performansı olumsuz etkileyebilir. Bu nedenle kapatılması önerilir. Defender'ı kaldırmak için aşağıdaki bağlantıyı kullanabilirsiniz:
[Defender Silici](https://github.com/ionuttbara/windows-defender-remover)


Ayrıca, Edge tarayıcısını kaldırıp Firefox yüklemek için şu bağlantıyı kullanabilirsiniz:
[Edge Silici](https://github.com/ShadowWhisperer/Remove-MS-Edge)

Gereksiz programları kaldırmak için aşşağıdaki scipti yönetici olarak açtığınız Terminalde Çalıştırın:

```sh
& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
```

---

## RDP Ayarlama 🔧

Windows'un ayarlarından RDP (Uzak Masaüstü Protokolü) servisini açın. Ayarlardan arama kutusunda "Uzak Masaüstü" yazarsanız çıkacaktır.

---

## Sanal Makinenin Nihai Parametreleri ile Başlatma 🎉

Sanal makinayı başlatmak için `run.sh` adında bir dosya oluşturun ve aşağıdaki komutları ekleyin:

```sh
qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -drive id=disk0,format=qcow2,file=winzort.qcow,cache=writeback,aio=native,cache.direct=on \
  -rtc base=localtime \
  -bios ~/OVMF.fd \
  -vga virtio \
  -display none \
  -net user,hostfwd=tcp::3389-:3389 -net nic

```

Bağlanmak için [Remmina](https://remmina.org/) kullanacağız.

Sanal makinenizi başarıyla başlattıktan sonra, Windows'un keyfini çıkarabilir ve ihtiyaçlarınıza göre özelleştirebilirsiniz.

```sh
#Debian tabanlı sistemlerde remmina kurulumu için:
sudo apt install remmina remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice

#Arch tabanlı sistemlerde remmina kurulumu:
sudo pacman -S remmina

#Gentoo tabanlı sistemlerde remmina kurulumu:
sudo emerge -av net-misc/remmina
```
## RDP oturumundaki dil ayarlarını kalıcı yapma:

1. **RDP ile oturum aç.**
2. **Ardından şu dizine git:**
```path
C:\Users\<kullanıcı_adı>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
```
3. **Yeni bir TR.reg dosyası oluştur ve şunu kaydet:**
```reg
Windows Registry Editor Version 5.00

[HKEY_USERS\.DEFAULT\Keyboard Layout\Preload]
"1"="0000041F"
```
**🔹 Bu kod “Türkçe Q klavye”yi sistem varsayılanı yapar.**

## Fontların görünüşlerini düzenleme:

Kullanırken fark edeceksiniz ki fontlar epey bozuk ve göz yoran cinste.
İşte Bunu düzeltmek için ilk olarak;
1. **Windows'ta arama kısmına ClearType yazıyoruz**
2. **Ardından gösterilen seçeneklerde en okunaklı olanlarını seçip işemleri tamamlıyoruz**

Bunu birden fazla deneme yanılma ile en iyisini yakalayabilirsiniz font çözünürlüklerinin tam oturması için reboot gerekebilir.


---

## Dosya Paylaşımı 🚀

Ana makinada **rclone** kullanarak WebDAV sunucusu başlatabilirsiniz. Sanal makinanızın **10.0.2.2** IP adresi ile ana makinayla ağ bağlantısı bulunmaktadır.

```sh
# Debian tabanlı bir sistemde rclone yüklemek için:
sudo apt install rclone

#Arch tabanlı sistemlerde rclone kurulumu:
sudo pacman -S rclone

#Gentoo tabanlı sistemlerde rclone
sudo emerge -av net-misc/rclone
```

```sh
# WebDAV sunucusunu başlatmak için:
rclone serve webdav --addr 127.0.0.1:8000 $HOME
# 127.0.0.1 yerine 0.0.0.0 yazarsanız, tüm IP adreslerinden bağlantı kabul edilir.
```

### Windows'tan WebDAV'a Bağlanmak için: 🖥️
1. Klasörler penceresinden Bilgisayar'a sat tıklayın
2. "Map Network Drive" tuşuna basın.
3. Adres kısmına `http://10.0.2.2:8000` yazın.
4. Kaydedin ve bağlantınızı oluşturun! 🎉

Artık dosyalarınıza kolayca erişebilir ve paylaşabilirsiniz! 😊


## USB Bağlama 🔌

1. Önce USB'yi takın. 💻
   - Örneğin, bir USB bellek veya harici bir disk takabilirsiniz.

2. `lsusb` komutunu kullanarak vendor ve product ID'sini bulun. 🆔
   - Terminalde şu komutu çalıştırın:
     ```
     lsusb
     ```
   - Çıktı örneği:
     ```
     Bus 002 Device 003: ID 3131:6969 Example Corp. USB Device
     ```
   - Burada **vendor ID** `0x3131` ve **product ID** `0x6969`'dir.

3. QEMU'ya aşağıdaki parametreyi ekleyin: 
   ```
   -device qemu-xhci,id=xhci -device usb-host,vendorid=0x3131,productid=0x6969
   ```
   - Bu parametre, USB cihazınızı QEMU sanal makinesine bağlamak için kullanılır. 🛠️