# CTRL+ALT+G imleci kurtarır

## qemu-img create -f qcow2 ./Asset/ISODENEME.qcow 100G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom ./Asset/archlinux-x86_64.iso \
  -hda ./QCOW/ISODENEME.qcow \
  -usbdevice tablet  \
  -net user,hostfwd=tcp::3389-:3389 -net nic
  -bios ./BIOS/OVMF.fd