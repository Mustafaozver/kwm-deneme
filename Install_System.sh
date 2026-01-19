
# CTRL+ALT+G imleci kurtarır

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom ./Asset/ISO.iso \
  -hda ./Asset/denemeHDD.qcow \
  -bios ~/Asset/OVMF.fd \
  -usbdevice tablet


qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -cdrom ./Asset/VirtIO.iso \
  -hda ./Asset/denemeHDD.qcow \
  -bios ~/Asset/OVMF.fd \
  -usbdevice tablet