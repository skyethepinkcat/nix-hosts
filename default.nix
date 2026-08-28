{
  local_domain ? "local", # Kept as "local" to avoid leaking tailnet
  lib ? <nixpkgs>.lib,
}:
let
  inherit lib;
  inherit (builtins) elem attrValues;
  inherit (lib)
    lists
    toList
    ;

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
      fqdn ? "${name}.${local_domain}",
      extraFQDNs ? [ ],
      tags ? [ ],
      primaryUser ? "skye",
      exporters ? [ ],
    }:
    let
      input_tags = tags;
      input_exporters = exporters;
    in
    rec {
      inherit
        name
        system
        primaryUser
        fqdn
        hardware
        ;
      exporters = input_exporters ++ lib.optionals (subset ["server"] input_tags) [
        "node"
        "tailscale"
      ];
      # Add system as a tag
      tags = [ (toString system) ] ++ input_tags ++ (map (v: "exporter-${v}") exporters);
      fqdns = [ "${name}.${local_domain}" ] ++ extraFQDNs;
      hasTags = i_tags: (subset (toList i_tags) tags);
      hasExporters = i: (subset (toList i) exporters);
      hasTag = throw "You probably meant 'hasTags'";
      # Helper functions to determine OS
      inherit (lib.systems.elaborate system)
        isDarwin
        isLinux
        isx86
        isAarch
        ;
    };
in
rec {

  hosts = {
    asticassia = mkHost {
      name = "asticassia";
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
      exporters = [
        "exportarr-sonarr"
        "exportarr-radarr"
        "nginx"
      ];
    };
    honnoji = mkHost {
      name = "honnoji";
      primaryUser = "skye";
      system = "x86_64-linux";
      tags = [
        "server"
        "monitoring"
        "builder"
        "podman"
      ];
      exporters = [
        "zfs"
      ];
    };
    lydian = mkHost {
      name = "lydian";
      primaryUser = "skye";
      system = "aarch64-darwin";
      tags = [
        "desktop"
      ];
    };
    yubiwa = mkHost {
      name = "yubiwa";
      primaryUser = "ii69854";
      system = "aarch64-darwin";
      tags = [
        "desktop"
        "work"
      ];
    };
  };
  withTags = tags: (builtins.filter (host: host.hasTags tags) (attrValues hosts));
  hostHasTag = host: tag: (elem tag hosts.${host}.tags);
  hostHasTags = host: tag: (subset hosts.${host}.tags tag);
}
