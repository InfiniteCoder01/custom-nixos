{
  inputs = {};
  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    test = pkgs.callPackage ./create-os.nix {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
