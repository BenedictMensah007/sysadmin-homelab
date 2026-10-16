# Incident Write-up: Ubuntu Server VM Would Not Boot, and How I Rebuilt It

## Summary

My Ubuntu Server VM in the lab stopped booting. Every GRUB entry failed, including the older kernel. I spent several hours diagnosing it, ruled out the common causes, and then chose to rebuild the server instead of repairing it. The rebuild brought back the domain join, group based login, sudo rights and the file server mount, and it now survives a reboot.

I did not find the root cause. This write-up covers what I checked, the mistakes that cost me time, and the process I would follow next time.

## Environment

- Windows host running Hyper-V
- DC-2025: Windows Server domain controller (lab.local) running AD DS, DNS, DHCP and the file server
- Ubuntu Server 26.04.1 LTS VM, Generation 2, joined to the domain
- Internal virtual switch for the lab network
- File share `Departments` on the DC, mounted on Ubuntu with CIFS

## Symptoms

1. First error at boot: `bad shim lock signature, you need to load kernel first`, on kernel 7.0.0-38-generic.
2. I turned Secure Boot off in the VM settings and confirmed it with `Get-VMFirmware`. It reported `SecureBoot : Off`.
3. The VM still returned to the GRUB menu every time. Editing the boot line (`nomodeset`) made no difference.
4. Every kernel in the Advanced options menu failed the same way. The firmware reported `EFI_LOAD_ERROR` from `start_image()`, so the failure happens before Ubuntu starts.

## What I checked

| Check | Result |
|---|---|
| Secure Boot | Off, confirmed in PowerShell |
| Older kernel | Failed the same way |
| Boot partition space | `/boot` 11 percent used, root 52 percent used |
| Kernel files | Both kernels, their initramfs files and the symlinks were present at normal sizes |
| EFI partition | Shim and GRUB files present |
| LVM | Volume group activated cleanly from a live ISO |

To inspect the disk I booted the Ubuntu Server ISO, opened the installer shell, ran `vgchange -ay`, and mounted the root volume, `/boot` and the EFI partition under `/mnt`. Nothing was changed on the disk during this step.

## Problems along the way

- The Hyper-V console and the installer shell both froze or stopped showing what I typed. Giving the live ISO more memory and switching to SSH helped. Connecting over SSH to the live installer worked, but the shell there also froze later, so I could not finish the chroot repair.
- The VM had a checkpoint that was created at 9:36, about one minute after the first error. Restoring it brought back the same failure, because the checkpoint was taken after the damage.
- The VM disk was a differencing disk (`.avhdx`) sitting on top of the original, so copying that one file would have been useless as a backup. `Export-VM` captures the whole chain.

## Decision: rebuild, do not repair

I decided to rebuild because:

- The important lab data lived on the DC and in this repo. Only a small amount of configuration lived on the Ubuntu VM.
- The rebuild is repeatable, and the repair was open ended.
- A clean install would give me known good checkpoints from the start.

Before deleting anything I ran `Export-VM` on the old VM (about 9 GB), and I kept it as a safety copy.

## Rebuild steps

1. Deleted the old VM and its files, after checking the export existed.
2. Deleted the old `UBUNTU` computer account in AD (`OU=Servers,OU=Corp`) so the new join would not clash with it.
3. Created a new Generation 2 VM with 4 GB static memory, 2 CPUs, the Microsoft UEFI Certificate Authority Secure Boot template, and checkpoints disabled during the install.
4. Installed Ubuntu Server with the name `ubuntu`, a static IP, and OpenSSH. I set the static IP in the installer because DHCP lives on the DC, and the DC was off.
5. Added a second network adapter on the Default Switch to give the server internet access, and enabled it with a separate netplan file so the lab network stayed untouched.
6. Installed `realmd`, `sssd`, `sssd-tools`, `adcli`, `samba-common-bin`, `krb5-user`, `oddjob`, `oddjob-mkhomedir`, `libnss-sss`, `libpam-sss`, `packagekit` and `cifs-utils`.
7. Pointed DNS at the DC with a netplan file, then confirmed with `realm discover lab.local`.
8. Joined the domain into the right OU:
   ```
   sudo realm join --computer-ou="OU=Servers,OU=Corp,DC=lab,DC=local" -U Administrator lab.local
   ```
9. Restricted logins to one AD group and gave that group sudo:
   ```
   sudo realm deny --all
   sudo realm permit -g gg_it@lab.local
   echo '%gg_it@lab.local ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/gg_it
   sudo chmod 440 /etc/sudoers.d/gg_it
   sudo visudo -cf /etc/sudoers.d/gg_it
   ```
10. Mounted the file share with a root only credentials file and made it permanent in `/etc/fstab` with `nofail` and `x-systemd.automount`, so a missing DC can never block the boot.

## Verification

- `realm list` shows `configured: kerberos-member`.
- `getent group gg_it@lab.local` returns the group and its members.
- An AD user can log in over SSH and use `sudo`.
- The share mounts, a test file can be created in the department folder, and the file shows the right owner and group.
- The share is still mounted after a reboot.
- I took a Hyper-V checkpoint after each stage: clean install, packages installed, domain joined, and lab fully rebuilt.

## Lessons learned

1. A checkpoint only helps if it was taken before the problem. I now take one after every working stage.
2. A checkpoint is not a backup. It lives next to the VM disk. A real backup is `Export-VM` copied to another drive.
3. A copy of an `.avhdx` file alone is not a backup of a VM that has checkpoints.
4. When the console freezes, work over SSH from PowerShell, where pasting and typing are reliable.
5. Keep a written rebuild process. The domain join, group login, sudo rules and CIFS mount took minutes once I had the steps in order.
6. Give VMs enough memory. A live ISO with too little memory behaves in confusing ways.
7. Do not trust a DHCP dependency on a machine that may be off. A static address removed that problem.

## Next steps

- Copy the exported VM to a second drive.
- Update the Ubuntu packages and keep the Default Switch adapter for updates.
- Investigate the root cause if it happens again, starting with the update logs in `/var/log/apt` and `/var/log/dpkg.log` on a mounted copy of the old disk.
