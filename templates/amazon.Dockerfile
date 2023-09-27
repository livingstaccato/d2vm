FROM {{ .Image }}

USER root

RUN dnf update -y

RUN dnf groupinstall -y --allowerasing onprem onprem-minimal

RUN dnf install -y --allowerasing \
  kernel \
  grub2-pc \
  grub2-pc-modules \
  grub2-efi-x64-modules \
  grub2-efi-x64-ec2 \
  zstd \
  systemd-networkd

RUN systemctl unmask systemd-remount-fs.service && \
    systemctl unmask getty.target && \
    systemctl preset-all && \
    systemctl set-default multi-user.target

RUN echo "datasource_list: [ NoCloud, AltCloud, ConfigDrive, OVF, None ]" > /etc/cloud/cloud.cfg.d/02-onprem.cfg

{{- if .Luks }}
RUN dracut --no-hostonly --regenerate-all --force --install="/usr/sbin/cryptsetup"
{{- else }}
RUN dracut --no-hostonly --regenerate-all --force
{{ end }}

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
