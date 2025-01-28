Order:
* Get a OpenWRT server (GLI Net is a good choice) but check to make sure it's supported and has a simple way to flash OpenWRT if it's not flashed already (https://openwrt.org/supported_devices)
* I personally like one's with detachable antennas (rp-sma) so I can add high gain antennas, but any with openwrt support should work fine.
* Best recommendation would be the GliNet mt6000 https://www.gl-inet.com/products/gl-mt6000/

Setup running the router from a flashdrive (in cases where the router doesn't have enough space for all the packages (or for ease of accces to collected data)):
* https://openwrt.org/docs/guide-user/storage/usb-drives-quickstart
* https://openwrt.org/docs/guide-user/additional-software/extroot_configuration

Setup Conference Captive Portal:
* Use LuCi to change the wireless settings to make the SSID and password what you want (or use the cli `nano /etc/config/wireless`)
* install opennds in the admin console (or cli (need to ssh first)) `opkg update` & `opkg install opennds` (Note that once you install opennds you will no longer be able to access LuCi from the default IP address)
* change opennds login setting to point to the theme we're going to alter: `uci set opennds.@opennds[0].login_option_enabled='2'` & `uci commit opennds` & `/etc/init.d/opennds restart` or `service opennds restart`
* Replace the default captive portal page with the one in this repo:
    * Using scp (<a href="https://openwrt.org/docs/guide-user/services/nas/sftp.server"> install this package</a>) or cli `opkg install openssh-sftp-server`
        * copy the local theme to the opennds after changing as you'd like: `scp LOCALFILEPATH/theme_user-email-login-basic.sh root@192.168.8.1:/usr/lib/opennds/`
        * copy the local theme to the opennds after changing as you'd like: `scp LOCALFILEPATH/client_params.sh root@192.168.8.1:/usr/lib/opennds/`
    * Using nano
        * CD into the folder with the opennds splash pages: `cd /usr/lib/opennds`
        * Copy to make your own theme: `cp theme_click-to-continue.sh conference.sh`
    * Remember to change the opendns settings to route to your new .sh theme `nano /etc/config/opennds` if you changed the name of the theme
* get the status of the opennds service: `service opennds status`
* view logs in tmp/ `cat /tmp/ndslog/ndslog.log`


<!--
copy a file locally to change: `scp -r root@192.168.8.1:/usr/lib/opennds LOCALFILEPATH\OpenNDSSplash`
-->
