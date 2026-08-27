{
  local_domain ? "local", # Kept as "local" to avoid leaking tailnet
  pkgs ? <nixpkgs>,
}:
let
  inherit (pkgs) lib;
  inherit (builtins) elem;
  inherit (lib) filterAttrs mapAttrsToList lists;

  # Checks if the given subset is a subset of list
  subset =
    subset: list:
    (lists.all (x: x) # Check that all values of the list are true
      # Map each value in subset to the value true if its in the list or false if it isn't
      (map (v: (elem v list)) subset)
    );
  mkHost =
    {
      name,
      system,
      hardware ? null,
      extraFQDNs ? [ ],
      tags ? [ ],
      primaryUser ? "skye",
    }:
    {
      inherit
        name
        system
        primaryUser
        hardware
        ;
      # Add system as a tag
      tags = [ system ] ++ tags;
      fqdn = [ "${name}.${local_domain}" ] ++ extraFQDNs;
    };
in
rec {
  hosts = {
    asticassia = mkHost {
      primaryUser = "skye";
      extraFQDNs = [
        "skyenet.online"
        "skyejonke.com"
      ];
      system = "x86_64-linux";
      tags = [
        "server"
        "low power"
        "public"
      ];
    };
    honnoji = mkHost {
      primaryUser = "skye";
      system = "x86_64-linux";
      tags = [
        "server"
        "monitoring"
        "builder"
      ];
    };
    lydian = mkHost {
      primaryUser = "skye";
      system = "aarch64-darwin";
      tags = [
        "desktop"
      ];
    };
    yubiwa = mkHost {
      primaryUser = "ii69854";
      system = "aarch64-darwin";
      tags = [
        "desktop"
        "work"
      ];
    };
  };
  withTags = tags: (filterAttrs (_: host: subset tags host.tags) hosts);
  hostHasTag = host: tag: (elem tag hosts.${host}.tags);
  hostHasTags = host: tag: (subset hosts.${host}.tags tag);
}
