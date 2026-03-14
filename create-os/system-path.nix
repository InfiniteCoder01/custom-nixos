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

  config = let
    etc-extras = (pkgs.stdenv.mkDerivation {
      name = "environment-etc";
      __structuredAttrs = true;
      buildCommand = ''
        mkdir -p "$out/etc"
        for ((i = 0; i < ''${#text_names[@]}; i++)); do
            mkdir -p "$(dirname "$out/etc/''${text_names[$i]}")"
            echo "''${text_values[$i]}" > "$out/etc/''${text_names[$i]}"
        done
        for ((i = 0; i < ''${#link_names[@]}; i++)); do
            mkdir -p "$(dirname "$out/etc/''${link_names[$i]}")"
            ln -s "''${link_values[$i]}" "$out/etc/''${link_names[$i]}"
        done
      '';

      text_names = lib.filter (x: x != null) (lib.mapAttrsToList (name: value: if value ? text then name else null) config.environment.etc);
      text_values = lib.filter (x: x != null) (lib.mapAttrsToList (name: value: if value ? text then value.text else null) config.environment.etc);
      link_names = lib.filter (x: x != null) (lib.mapAttrsToList (name: value: if value ? source then name else null) config.environment.etc);
      link_values = lib.filter (x: x != null) (lib.mapAttrsToList (name: value: if value ? source then value.source else null) config.environment.etc);
    });
  in {
    environment.systemPackages = [
      # etc-extras
    ];
    system.build.system-path = pkgs.buildEnv {
      name = "system-path"; 
      paths = [ etc-extras (pkgs.buildEnv { name = "system-path-raw"; paths = config.environment.systemPackages; }) ];
      ignoreCollisions = true;
    };
    rootfs.links."/usr" = config.system.build.system-path;
  };
}

