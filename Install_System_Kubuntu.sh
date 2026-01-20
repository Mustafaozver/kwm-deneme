
# CTRL+ALT+G imleci kurtarır

## qemu-img create -f qcow2 ./Asset/KUBUNTUHDD.qcow 100G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom ./Asset/kubuntu-24.04-desktop-amd64.iso \
  -hda ./QCOW/KUBUNTUHDD.qcow \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet
