# kwm-deneme

```
# OVMF.fd dosyasını indirin
# https://github.com/clearlinux/common/blob/master/OVMF.fd
```

```bash
sudo apt install qemu-kvm -y

sudo apt install remmina remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice -y

sudo apt install rclone -y

# rclone serve webdav --addr 127.0.0.1:8000 $HOME
# rclone serve webdav --addr 127.0.0.1:8000 ./Asset/
rclone serve webdav --addr 127.0.0.1:8000 /home/mustafa/

qemu-img create -f qcow2 ./Asset/denemeHDD3.qcow 50G

sh ./Install_System.sh

sh ./Run_System.sh


```
