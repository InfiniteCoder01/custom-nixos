{ pkgs, ... }:
{
  config = {
    environment.systemPackages = [ pkgs.systemd ];
    rootfs.links."/init" = "${pkgs.systemd}/bin/init";
    environment.etc."systemd/system/default.target".text = ''
[Unit]
AllowIsolate=yes

[Service]
Type=simple
ExecStart=/usr/bin/bash
Restart=on-failure
    '';
  };
}
