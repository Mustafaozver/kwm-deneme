
# CTRL+ALT+G imleci kurtarır

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom ./Asset/kubuntu-24.04-desktop-amd64.iso \
  -hda ./Asset/denemeHDD2.qcow \
  -bios ./Asset/OVMF.fd \
  -usbdevice tablet
