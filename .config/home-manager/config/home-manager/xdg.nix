{ config, ... }: {
  xdg.enable     = true;
  xdg.configHome = "${config.home.homeDirectory}/.config";
  xdg.dataHome   = "${config.home.homeDirectory}/.local/share";
  xdg.cacheHome  = "${config.home.homeDirectory}/.cache";
}
