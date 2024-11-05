{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.user.gui.browser.firefox;
  passffHost= {
    home.packages = with pkgs; [
      passff-host
    ];
    home.file = {
      ".mozilla/native-messaging-hosts/passff.json" = {
        text = ''
          {
            "name": "passff",
            "description": "Host for communicating with zx2c4 pass",
            "path": "${pkgs.passff-host}/share/passff-host/passff.py",
            "type": "stdio",
            "allowed_extensions": [ "passff@invicem.pro" ]
          }
        '';
      };
    };
    assertions =
    let
      pinentry = config.services.gpg-agent.pinentryPackage;
    in
    [
      {
        assertion = pinentry != pkgs.pinentry-curses || pinentry != pkgs.pinentry-tty;
        message = "Firefox plugin passff requires graphical pinentry";
      }
    ];
  };

in
{
  options.modules.user.gui.browser.firefox = { enable = mkEnableOption "Enable Firefox browser"; };
  config = mkIf cfg.enable (passffHost // {
    programs.firefox = {
      enable = true;
      profiles = {
        "${config.user.name}" = {
          isDefault = true;
          bookmarks = config.user.bookmarks;

          search = {
            force = true;
            default = "Google";
            engines = {
              "Startpage" = {
                urls = [{
                  template = "https://www.startpage.com/sp/search?q={searchTerms}";
                }];
                iconUpdateURL = "https://www.startpage.com/sp/cdn/favicons/favicon--default.ico";
              };
            };
          };

          containersForce = true;
          containers = {
            Personal = {
              color = "blue";
              icon = "fingerprint";
              id = 1;
            };
            Work = {
              color = "yellow";
              icon = "briefcase";
              id = 2;
            };
            Banking = {
              color = "green";
              icon = "dollar";
              id = 3;
            };
            Social = {
              color = "red";
              icon = "chill";
              id = 4;
            };
            Shopping = {
              color = "purple";
              icon = "cart";
              id = 5;
            };
            Google = {
              color = "orange";
              icon = "vacation";
              id = 6;
            };
          };

          settings = {
            "layout.spellcheckDefault" = 0;
            "ui.key.menuAccessKeyFocuses" = false;
            "signon.rememberSignons" = false;
            "extensions.pocket.enabled" = false;
            "extensions.autoDisableScopes" = 0;

            # May break extensions due to Nix
            "extensions.enabledScopes" = 5;

            # May break stuff but increases privacy
            #"extensions.webextensions.restrictedDomains" = "";
            #"privacy.resistFingerprinting" = true;
            #"privacy.resistFingerprinting.letterboxing" = true;
            #"privacy.resistFingerprinting.block_mozAddonManager" = true;

            "browser.startup.homepage_override.mstone" = "ignore";

            "browser.aboutConfig.showWarning" = false;
            "browser.startup.page" = 0;
            "browser.formfill.enable" = false;
            "places.history.enabled" = false;

            "browser.urlbar.suggest.history" = false;
            "browser.urlbar.suggest.topsites" = false;
            "browser.urlbar.sponsoredTopSites" = false;
            "browser.urlbar.autoFill" = false;
            "browser.urlbar.suggest.pocket" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "browser.toolbars.bookmarks.showOtherBookmarks" = false;
            "browser.aboutwelcome.showModal" = false;
            "browser.migrate.content-modal.about-welcome-behavior" = "";

            "browser.newtabpage.enabled" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.default.sites" = "";

            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.shopping.experience2023.enabled" = false;

            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;

            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.coverage.opt-out" = false;
            "toolkit.coverage.endpoint.base" = "";

            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;

            "app.shield.optoutstudies.enabled" = false;
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";

            "breakpad.reportURL" = false;
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

            "captivedetect.canonicalURL" = "";
            "network.captive-portal-service.enabled" = false;
            "network.connectivity-service.enabled" = false;

            "browser.safebrowsing.downloads.remote.enabled" = false;

            "network.prefetch-next" = false;
            "network.dns.disablePrefetch" = true;
            "network.predictor.enabled" = false;
            "network.predictor.enable-prefetch" = false;
            "network.http.speculative-parallel-limit" = 0;
            "network.http.speculativeConnect.enabled" = false;

            "network.proxy.sock_remote_dns" = true;
            "network.file.disable_unc_paths" = true;
            "network.gio.supported-protocols" = "";

            "browser.urlbar.speculativeConnect.enabled" = false;
            "browser.search.suggest.enabled" = false;
            "browser.urlbar.suggest.searches" = false;

            "browser.urlbar.clipboard.featureGate" = false;
            "browser.urlbar.richSuggestions.featureGate" = false;
            "browser.urlbar.trending.featureGate" = false;
            "browser.urlbar.addons.featureGate" = false;
            "browser.urlbar.pocket.featureGate" = false;
            "browser.urlbar.weather.featureGate" = false;
            "browser.urlbar.yelp.featureGate" = false;
            "browser.urlbar.suggest.engines" = false;

            "signon.autofillForms" = false;
            "signon.formlessCapture.enabled" = false;

            "network.auth.subresource-http-auth-allow" = 1;

            "browser.privatebrowsing.forceMediaMemoryCache" = true;
            "media.memory_cache_max_size" = 65536;
            "browser.sessionstore.privacy_level" = 2;
            "browser.shell.shortcutFavicons" = false;

            "security.ssl.require_safe_negotiation" = true;
            "security.tls.enable_0rtt_data" = false;
            "security.OCSP.enabled" = true;
            "security.OCSP.require" = true;

            "security.cert_pinning.enforcement_level" = 2;
            "security.remote_settings.crlite_filters.enabled" = true;
            "security.pki.crlite_mode" = 2;

            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_send_http_background_request" = false;

            "security.ssl.treat_unsafe_negotiation_as_broken" = true;
            "browser.xul.error_pages.expert_bad_cert" = true;

            "network.http.referer.XOriginTrimmingPolicy" = 2;

            "privacy.userContext.enabled" = true;
            "privacy.userContext.ui.enabled" = true;

            "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
            "media.peerconnection.ice.default_address_only" = true;

            "dom.disable_window_move_resize" = true;

            "browser.download.start_downloads_in_tmp_dir" = false;
            "browser.helperApps.deleteTempFileOnExit" = true;
            "browser.uitour.enabled" = false;

            "devtools.debugger.remote-enabled" = false;
            "permissions.manager.defaultsUrl" = "";
            "webchannel.allowObject.urlWhitelist" = "";
            "network.IDN_show_punycode" = true;

            "pdfjs.disabled" = false;
            "pdfjs.enableScripting" = false;

            "browser.tabs.searchclipboardfor.middleclick" = false;
            "browser.contentanalysis.default_allow" = false;

            "browser.download.useDownloadDir" = true;
            "browser.download.alwaysOpenPanel" = true;
            "browser.download.manager.addToRecentDocs" = false;
            "browser.download.always_ask_before_handling_new_types" = true;
            "extensions.postDownloadThirdPartyPrompt" = true;

            "browser.contentblocking.category" = "strict";

            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.clearOnShutdown.cache" = true;
            "privacy.clearOnShutdown_v2.cache" = true;
            "privacy.clearOnShutdown.downloads" = true;
            "privacy.clearOnShutdown.formdata" = true;
            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;

            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown.offlineApss" = true;
            "privacy.clearOnShutdown.sessions" = true;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

            "privacy.clearSiteData.cache" = true;
            "privacy.clearSiteData.cookiesAndStorage" = false;
            "privacy.clearSiteData.historyFormDataAndDownloads" = true;

            "privacy.cpd.cache" = true;
            "privacy.clearHistory.cache" = true;
            "privacy.cpd.formdata" = true;
            "privacy.cpd.history" = true;
            "privacy.clearHistory.historyFormDataAndDownloads" = true;
            "privacy.cpd.cookies" = false;
            "privacy.cpd.sessions" = true;
            "privacy.cpd.offlineApps" = false;
            "privacy.clearHistory.cookiesAndStorage" = false;

            "privacy.sanitize.timeSpan" = 0;

            "privacy.window.maxInnerWidth" = 1600;
            "privacy.window.maxInnerHeight" = 900;

            "privacy.spoof_english" = 1;

            "browser.display.use_system_colors" = false;
            "widget.non-native-theme.enabled" = true;

            "browser.link.open_newwindow" = 3;
            "browser.link.open_newwindow.restriction" = 0;
            "browser.chrome.site_icons" = false;
            "browser.download.forbid_open_with" = true;

            "extensions.blocklist.enabled" = true;
            "network.http.referer.spoofSource" = false;
            "security.dialog_enable_delay" = 1000;
            "privacy.firstparty.isolate" = false;
            "extensions.webcompat.enable_shims" = true;
            "security.tls.version.enable-deprecated" = false;
            "extensions.webcompat-reporter.enabled" = false;
            "extensions.quarantinedDomains.enabled" = true;

            "media.videocontrols.picture-in-picture.enabled" = false;
          };

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            vimium
            #darkreader
            greasemonkey
            clearurls
            passff
          ];
        };
      };
    };
  });
}
