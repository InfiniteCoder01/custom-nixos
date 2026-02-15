{ config, pkgs, lib, ... }:
{
  options = {
    environment.systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "[ pkgs.firefox pkgs.thunderbird ]";
      description = ''
        The set of packages that appear in /usr.
        These packages are automatically available
        to all users, and are automatically updated
        every time you rebuild the system configuration.
      '';
    };
    
    environment.etc = lib.mkOption {
      default = {};
      example = lib.literalExpression ''
        { "systemd/system/default.target".text = "..." }
      '';
      description = ''
        Set of files that have to be linked in {file}`/etc`.
      '';
    };
  };

  config = {
    system.build.system-path = pkgs.buildEnv {
      name = "system-path";
      paths = config.environment.systemPackages;
    };
    rootfs.links."/usr" = config.system.build.system-path;
    rootfs.links."/etc" = pkgs.linkFarm "etc" (lib.mapAttrsToList (name: value: {
      inherit name;
      path = pkgs.writeText name value.text;
    }) config.environment.etc);
  };
}

