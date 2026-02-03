
ISOFILE="./Asset/kubuntu-24.04-desktop-amd64.iso"
HDDFILE="./QCOW/IZSHDD.qcow"

qemu-system-x86_64 --enable-kvm -m 8G -smp `nproc` \
  -cpu host \
  -drive id=disk0,format=qcow2,file=$HDDFILE,cache=writeback,aio=native,cache.direct=on \
  -rtc base=localtime \
  -bios ./BIOS/OVMF.fd \
  -net user,hostfwd=tcp::3389-:3389 \
  -net nic



# kalıcı UEFI BIOS'u kullanmak için;
# -drive file=./BIOS/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=./BIOS/OVMF_VARS.fd,if=pflash,format=raw,unit=1 "

# USB HUB'u kullanmak için;
# -device qemu-xhci,id=xhci -device usb-host,vendorid=0x0781,productid=0x1666

# lsusb
# - Bus 002 Device 002: ID 0951:1666 Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50 Kyson 2
# - Bus 001 Device 012: ID 0951:1666 Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50 Kyson 1
# - Bus 001 Device 007: ID 0781:5567 SanDisk Corp. Cruzer Blade
# - Bus 001 Device 002: ID 14cd:1212 Super Top microSD card reader (SY-T18)