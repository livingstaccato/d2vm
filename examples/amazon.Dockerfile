FROM {{ .Image }}

USER root

RUN dnf update -y && \
    dnf group install -y --allowerasing onprem

RUN dnf install -y --allowerasing \
    kernel \
    grub2-pc \
    grub2-pc-modules \
    grub2-efi-x64-modules \
    grub2-efi-x64-ec2 \
    http://sjc.mirror.rackspace.com/fedora/releases/38/Everything/x86_64/os/Packages/q/qemu-guest-agent-7.2.0-6.fc38.x86_64.rpm \
    zstd \
    shadow-utils \
    systemd-networkd

RUN systemctl unmask systemd-remount-fs.service && \
    systemctl unmask getty.target && \
    systemctl set-default multi-user.target

#systemctl preset-all && \

RUN base64 -d <<< "IyBMZWF2ZSBvdXQgbW9kdWxlcyB0aGF0IGFyZW4ndCBuZWNlc3NhcnkgaW4gRUMyLiAgVHlwaWNhbGx5IHRoaXMKIyBtZWFucyBtb2R1bGVzIHRoYXQgYXNzdW1lIGNvbnNvbGUgYWNjZXNzIChzZXJpYWwgb3IgdmlkZW8pIG9yCiMgdmFyaW91cyBibG9jayBkZXZpY2UgY29uZmlndXJhdGlvbnMgdGhhdCBtYXkgYmUgdXNlZCBpbiBvdGhlciBlbnZpcm9ubWVudHMuCm9taXRfZHJhY3V0bW9kdWxlcys9IiBpMThuIHBseW1vdXRoIGNyeXB0IHFlbXUgdGVybWluZm8ga2VybmVsLW1vZHVsZXMtZXh0cmEga2VybmVsLW1vZHVsZXMgbnZkaW1tICIKCiMgQ29tbW9uIHJvb3QgZmlsZXN5c3RlbSB0eXBlcy4gIEFtYXpvbiBMaW51eCB1c2VzIFhGUyBieSBkZWZhbHQsIGFuZAojIGV4dDQgaXMgdXNlZCBmcmVxdWVudGx5IGVub3VnaCB0byBqdXN0aWZ5IGxlYXZpbmcgaXQgZW5hYmxlZC4KZmlsZXN5c3RlbXMrPSIgeGZzIGV4dDQgIgoKIyBJbnRlcmFjdGl2ZSBmc2NrIGluIHRoZSBpbml0cmFtZnMgaXMgbm90IHRlcnJpYmx5IGVhc3kvdXNlZnVsIGluIHRoZSBjbG91ZAojIFJlbHkgb24gb3RoZXIgaW5zdGFuY2VzIGJlaW5nIGFibGUgdG8gYWNjZXNzIHRoZSBibG9jayBkZXZpY2UgYW5kIHJlcGFpcgojIG91dCBvZiBiYW5kIGlmIG5lZWRlZC4Kbm9mc2Nrcz0ieWVzIgoKIyB6c3RkIGlzIHF1aWNrZXIgdG8gZGVjb21wcmVzcwpjb21wcmVzcz0ienN0ZCIK" > /etc/dracut.conf.d/ec2.conf && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "datasource_list: [ NoCloud, AltCloud, ConfigDrive, OVF, None ]" > /etc/cloud/cloud.cfg.d/02-onprem.cfg

#{{- if .Luks }}
#RUN dracut --no-hostonly --regenerate-all --force --install="/usr/sbin/cryptsetup"
#{{- else }}
RUN dracut --no-hostonly --regenerate-all --force
#{{ end }}

#COPY /home/tim.perkins/code/al2023/d2vm/templates/amazon/systemd/ /etc/

RUN echo "ec2-user:ec2-user" | chpasswd

{{- if .Password }}RUN echo "root:{{ .Password }}" | chpasswd {{ end }}

{{- if not .Grub }}
RUN cd /boot && \
    mv $(find . -name 'vmlinuz-*') /boot/vmlinuz && \
    mv $(find . -name 'initramfs-*.img') /boot/initrd.img
{{- else }}
RUN find /boot -type l -exec rm {} \;
{{- end }}

RUN dnf clean all && \
    rm -rf /var/cache/dnf
