juniper_sslvpn_log_parser
=========================

A real-time Juniper SSL-VPN log file parser.

Sample syslog format
--------------------
* **Login** messages

        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[User_Role] - Login succeeded for xxx@xxx.xxx.xxx/Users (session:00000000) from 000.000.000.000.
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[User_Role] - Remote address for user xxx@xxx.xxx/Users changed from 000.000.000.000 to 000.000.000.000. Access denied.
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - Login failed using auth server Radius (Radius Server).  Reason: Short Password
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - Login failed using auth server Radius (Radius Server).  Reason: Failed
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - Radius Server Radius: Login failed for xxx@xxx.xxx because host 000.000.000.000:1812 is unreachable.

* **Tunneling** messages

        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - VPN Tunneling: Session started for user with IP 000.000.000.000,  hostname XXX-XXX-XXX
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - VPN Tunneling: Session ended for user with IP 000.000.000.000
        Feb 27 15:00:00 vpn-001 Juniper: 2013-02-27 15:00:00 - ive - [000.000.000.000] SAMPLE::xxx@xxx.xxx(Users)[] - Session timed out for xxx@xxx.xxx.xxx/Users (session:00000000) due to inactivity (last access at 13:59:31 2013/02/27). Idle session identified during routine system scan.

Usage - Normal log file
-----------------------
    # ./ae_vpn_log_parser.pl [SYSLOG-FILE]
    
Usage - FIFO file
-----------------
    # mkfifo /var/log/fifo_log
    # vim /etc/rsyslog.conf
    local7.*        |/var/log/fifo_log

    # ./ae_vpn_log_parser.pl /var/log/fifo_log

Result
------
* **Login** messages

        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ) succeeded
        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ) denied     000.000.000.000 => 000.000.000.000
        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ) failed     Failed
        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ) failed     Short Password

* **Tunneling** messages

        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ) started    000.000.000.000
        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ] ended      000.000.000.000
        2013-02-27 15:00:00 [000.000.000.000  ] (xxx@xxx.xxx                 ] timeout    1 hour and 2 minutes

Author
------
    SHIE, Li-Yi <lyshie@mx.nthu.edu.tw>
