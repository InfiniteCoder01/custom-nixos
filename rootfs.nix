{ config, pkgs, lib, ... }:
{
  options = {
    rootfs.links = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      example = lib.literalExpression ''{ "/bin/bash" = "\${pkgs.bash}/bin/bash" }'';
      description = ''
        Symlinks in the final rootfs
      '';
    };
  };

  config = {
    system.build.mkRootfs = {
      links ? config.rootfs.links,
    }: pkgs.stdenv.mkDerivation rec {
      name = "rootfs";
      __structuredAttrs = true;
      unsafeDiscardReferences.out = true;
      buildCommandPath = ./rootfs.sh;

      targets = lib.attrNames links;
      sources = lib.attrValues links;
      closureInfo = pkgs.closureInfo {
        rootPaths = sources;
      };
    };
    system.build.rootfs = config.system.build.mkRootfs {};
  };
}
