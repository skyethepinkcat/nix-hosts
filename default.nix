{
  local_domain ? "local",
}:
{
  asticassia = {
    mainUser = "skye";
    fqdn = [
      "asticassia.${local_domain}"
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
  honnoji = {
    mainUser = "skye";
    system = "x86_64-linux";
    fqdn = [ "honnoji.${local_domain}" ];
    tags = [
      "server"
    ];
  };
  lydian = {
    mainUser = "skye";
    system = "aarch64-darwin";
    fqdn = [ "lydian.${local_domain}" ];
    tags = [
      "desktop"
    ];
  };
  yubiwa = {
    mainUser = "ii69854";
    system = "aarch64-darwin";
    fqdn = [ "yubiwa.${local_domain}" ];
    tags = [
      "desktop"
      "work"
    ];
  };
}
