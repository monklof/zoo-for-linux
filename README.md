# zoo-for-linux

Zoo for linux, mainly some useful shell scripts that I use.

* `security/send-login-report-through-email.sh`  
    A tool that scan `/var/log/auth.log`, figure out who logged in yesterday and send the report to my email. Used in my blog server to monitor login activity for security reason.

* `openvpn/openvpn-install.sh`  
    OpenVPN installer for Debian, Ubuntu and CentOS, forked from [openvpn-install](https://github.com/Nyr/openvpn-install)

* `redis/redis-rps.sh`  
    Display the RPS(Requests Per Second)/QPS of redis (localhost:6379)
