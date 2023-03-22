{ config, pkgs, lib, ... }:

{

  time = {
    timeZone = "America/New_York"; # Change time-zone, run timedatectl list-timezones if you're unsure
  };
  
  services.timesyncd = {
    enable = true;
    servers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8"; # Change locale 
}
