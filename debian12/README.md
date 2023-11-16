### Deploy Debian 12 with Terraform

With Xorg, XFCE, lightdm and working mousepointer under virt-manager with injected "input.xsl" configuration.


### Requirements

1. Install packages (here: for Arch Linux)
```
sudo pacman -S virt-manager, libguestfs, guestfs-tools, qemu-desktop, libvirt, edk2-ovmf, dnsmasq, iptables-nft, terraform, cdrkit -y
```

2. Download Debian 12 Cloudimage
```
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
```

3. Resize qcow2 to desired size (here: `20G`)

```
sudo qemu-img resize debian-12-genericcloud-amd64.qcow2 20G
```

4. Modify configure files as needed (e.g. hostname, username, SSH keyfile, paths etc.)

5. Finish
```
terraform init
terraform plan
terraform apply
```
