
# CTRL+ALT+G imleci kurtarır

## qemu-img create -f qcow2 ./Asset/WINDOWSHDD.qcow 100G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom ./Asset/Win10_11_AIO_4in1_12.12.2024.iso \
  -hda ./QCOW/WINDOWSHDD.qcow \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet


qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -cdrom ./Asset/virtio-win-0.1.285.iso \
  -hda ./QCOW/WINDOWSHDD.qcow \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet