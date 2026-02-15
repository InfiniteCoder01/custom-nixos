{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hello bash busybox
  ];
}
