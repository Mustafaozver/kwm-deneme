# CTRL+ALT+G imleci kurtarır

ISOFILE="./Asset/Win10_11_AIO_4in1_12.12.2024.iso"
HDDFILE="./QCOW/WINDOWSHDD.qcow"

#qemu-img create -f qcow2 $HDDFILE 100G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom $ISOFILE \
  -hda $HDDFILE \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet


qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -cdrom ./Asset/virtio-win-0.1.285.iso \
  -hda $HDDFILE \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet