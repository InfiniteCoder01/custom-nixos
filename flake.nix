{
  inputs = {};
  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in rec {
    custom-nixos = pkgs.callPackage ./create-os {
      modules = [
        ./configuration.nix
      ];
    };
  
    gen-img = pkgs.writeShellScriptBin "gen-img" ''
      dd if=/dev/null of=image.img bs=1M seek=1024
      ${pkgs.e2fsprogs}/bin/mkfs.ext4 image.img
      ${pkgs.lkl.out}/bin/cptofs -t ext4 -i image.img ${custom-nixos.config.system.build.rootfs}/* /
    '';

    kernel = pkgs.fetchFromGitHub { # Dirty: Get a kernel with devtmpfs mounted from someone's LFS build
      owner = "felipeagger";
      repo = "linux-from-scratch";
      rev = "d6503d059310f5889f36bc6c931589bbc5aa2b03";
      hash = "sha256-g9w5igpoCVYsgsLYRS0qx0ZQo+xmVHYGesLJiIKiiYI=";
    };

    qemu = pkgs.writeShellScriptBin "run-qemu" ''
      ${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -drive format=raw,file=image.img -kernel ${kernel}/x86_64/bzImgKernel6LLVMx8664 -nographic -append "root=/dev/sda console=ttyS0 init=/init" 
    '';
  };
}
