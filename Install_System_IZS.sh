
# CTRL+ALT+G imleci kurtarır
ISOFILE="./Asset/kubuntu-24.04-desktop-amd64.iso"
HDDFILE="./QCOW/IZSHDD.qcow"

qemu-img create -f qcow2 $HDDFILE 25G

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom $ISOFILE \
  -hda $HDDFILE \
  -bios ./BIOS/OVMF.fd \
  -usbdevice tablet
