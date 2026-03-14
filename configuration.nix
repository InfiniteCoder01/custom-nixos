{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hello bash busybox
    sway swaybg dbus mesa mesa-demos
  ];
  environment.etc."dbus-1".source = (pkgs.makeDBusConf.override {
    # dbus = pkgs.dbus-broker;
  }).outPath;
}
