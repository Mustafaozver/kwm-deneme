# CTRL+ALT+G imleci kurtarır

ISOFILE="./Asset/kubuntu-24.04-desktop-amd64.iso"
HDDFILE="./QCOW/ISODENEME.qcow"

qemu-img create -f qcow2 $HDDFILE 100G

qemu-system-x86_64 --enable-kvm -m 12G -smp `nproc` \
  -cpu host \
  -net none \
  -cdrom $ISOFILE \
  -hda $HDDFILE \
  -usbdevice tablet  \
  -device qemu-xhci,id=xhci -device usb-host,vendorid=0x0951,productid=0x1666  \
  -net user,hostfwd=tcp::3389-:3389 -net nic \
  -bios ./BIOS/OVMF.fd



# -device qemu-xhci,id=xhci -device usb-host,vendorid=0x0781,productid=0x1666

# lsusb
# - Bus 002 Device 002: ID 0951:1666 Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50 Kyson 2
# - Bus 001 Device 012: ID 0951:1666 Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50 Kyson 1
# - Bus 001 Device 007: ID 0781:5567 SanDisk Corp. Cruzer Blade
# - Bus 001 Device 002: ID 14cd:1212 Super Top microSD card reader (SY-T18)