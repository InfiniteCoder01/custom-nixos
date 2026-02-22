{ pkgs, ... }:
{
  config = {
    environment.systemPackages = [ pkgs.systemd ];
    rootfs.links."/init" = "${pkgs.systemd}/bin/init";
    environment.etc."systemd/system/default.target".text = ''
[Unit]
Description=Default target
Requires=shell.service
    '';
    environment.etc."systemd/system/shell.service".text = ''
[Unit]
Description=Login shell
DefaultDependencies=no

[Service]
StandardInput=tty
StandardOutput=tty
ExecStart=/usr/bin/bash
Restart=always
    '';
    # environment.etc."systemd/system/default.target.wants/shell.service".link = "../shell.service";
    environment.etc."machine-id".text = "";
  };
}
