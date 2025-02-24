{
  description = "A very basic flake";

  inputs = {
    nixos-cfg.url = "github:shymega/nix-cfg-dummy";
    nixpkgs.follows = "nixos-cfg/nixpkgs";
    nixos-system = {
      url = "file+file:///dev/null";
      flake = false;
    };
    generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    output-type = {
      url = "file+file:///dev/null";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-cfg,
    nixos-system,
    generators,
    output-type,
    ...
  } @ inputs: let
    outputType = builtins.readFile output-type.outPath;

    targetCfg = nixos-cfg.nixosConfigurations."${builtins.readFile nixos-system.outPath}".extendModules {
      modules =
        [generators.nixosModules.all-formats]
        ++ inputs.nixpkgs.lib.optional (outputType == "lxc" || outputType == "docker") {
          networking.useHostResolvConf = false;
        };
    };
    inherit (targetCfg.pkgs) system;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
    with pkgs; {
      packages.${system} = {
        toplevel = targetCfg.config.system.build.toplevel;
        default = self.packages.${system}.${outputType};
        generate = self.packages.${system}.${outputType};
        "${outputType}" = targetCfg.config.formats."${outputType}";
      };
    };
}
