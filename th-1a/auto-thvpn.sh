#!/usr/bin/env bash
depend_pkgs=('icedtea-web' 'iproute2' 'sed' 'firefox' 'curl')
depend_file='sslvpn_jnlp.cgi' #change SvpnUid, get by firefox

IF_list=(eth0 wlan0 lo)

usage() {
    cat <<EOF
$0 -f /path/to/sslvpn_jnlp.cgi [-d] [-i] [-m]

  -h        show this help
  -p        print mode info
  -d        download jars of ssl vpn
  -f < >    set config file
  -i < >    set a network interface before
            the default list '${IF_list[@]}'
            useful for mode 2
  -m [1|2]  set mode number
EOF
}

mode_info() {
    cat <<EOF
# mode 1 (default)

TH-1A-LN1:22 -> TH-1A-LN1:2222
TH-1A-LN2:22 -> TH-1A-LN2:2222
TH-1A-LN3:22 -> TH-1A-LN3:2222
TH-1A-LN8:22 -> TH-1A-LN8:2222
TH-1A-LN9:22 -> TH-1A-LN9:2222
TH-1A-ns1:22 -> TH-1A-ns1:2222

##H3C8042HJJMTW ADD
127.0.0.2 TH-1A-LN1
127.0.0.3 TH-1A-LN2
127.0.0.4 TH-1A-LN3
127.0.0.5 TH-1A-LN8
127.0.0.6 TH-1A-LN9
127.0.0.7 TH-1A-ns1

# mode 2

network interface IP: netIP
TH-1A-LN1:22 -> netIP:2221
TH-1A-LN2:22 -> netIP:2222
TH-1A-LN3:22 -> netIP:2223
TH-1A-LN8:22 -> netIP:2228
TH-1A-LN9:22 -> netIP:2229
TH-1A-ns1:22 -> netIP:2231

IF_list=(${IF_list[@]})

EOF
}

add_mode2_ssh_config() {
    local newIP="$1"
    if grep '#### add by thvpn script ####' ~/.ssh/config 2>&1 >/dev/null; then
        echo "==> Edit ~/.ssh/config ..."
        echo " -> change HostName to new IP: $newIP"
        sed -i "/#### add by thvpn script ####/ {
            :a;
            N;
            /#### end by thvpn script ####/ {
                s/\(HostName\)[ ]*[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/\1 $newIP/g;
                b
            };
            ba
        }" ~/.ssh/config
    else
        echo "==> Add th1aln[12389].local th1ans1.local to ~/.ssh/config"
        cat >> ~/.ssh/config <<EOF
#### add by thvpn script ####
Host    th1aln1.local
    HostName $newIP
    Port     2221 
Host    th1aln2.local
    HostName $newIP
    Port     2222
Host    th1aln3.local
    HostName $newIP
    Port     2223
Host    th1aln8.local
    HostName $newIP
    Port     2228
Host    th1aln9.local
    HostName $newIP
    Port     2229
Host    th1ans1.local
    HostName $newIP
    Port     2231
#### end by thvpn script ####
EOF
    fi
}

while getopts 'df:i:m:hp' arg; do
    case "$arg" in
        d) _download='yes';;
        f) _config_file="$OPTARG" ;;
        i) _IF="$OPTARG" ;;
        m) _mode="$OPTARG" ;;
        p) mode_info; exit 0 ;;
        h|*) usage; exit 0 ;;
	esac
done

RUNPATH=/tmp/sslvpn4th1a

if [ ! -d $RUNPATH ]; then
    mkdir -pv $RUNPATH
    _download='yes'
fi

_config_file=${_config_file:-./sslvpn_jnlp.cgi}
if [ ! -f $_config_file ]; then
    echo "!!! lost jnlp file(sslvpn_jnlp.cgi): $_config_file, get by firefox."
    usage
    exit 1
fi
cp $_config_file $RUNPATH/sslvpn.jnlp

_mode=${_mode:-1}

for netif in $_IF ${IF_list[@]}; do
    if [[ x$_mode == 'x1' ]]; then
        netif='Local Loopback'
        _myIP='127.0.0.[234567]'
        break
    fi
    if [[ $netif == 'lo' ]]; then
        _myIP='127.0.0.1'
        break
    fi
    if [ -f /sys/class/net/$netif/operstate ]; then
        if [[ $(cat /sys/class/net/$netif/operstate) == 'up' ]]; then
            _myIP=$(ip addr show $netif | sed -n 's/^[ \t].*inet \(.*\)\/.*brd.*$/\1/p')
            break
        fi
    fi
done
echo "==> Using network interface: $netif ($_myIP)"

_RET=1
if [ x$_download == 'xyes' ]; then
    #download jars
    jars=$(sed -n '/href.*jar/ s/^.*="\(.*\)".*$/\1/ p' $RUNPATH/sslvpn.jnlp)
    codebase=$(sed -n '/codebase="/ s/^.*codebase="\(.*\)".*$/\1/ p' $RUNPATH/sslvpn.jnlp)
    [ -d $RUNPATH/sslvpn ] && rm -r $RUNPATH/sslvpn/
    mkdir -pv $RUNPATH/sslvpn/{linux,mac,windows}
    _RET=0
    for jar in $jars; do
        curl -fLC - --retry 3 --retry-delay 3 -k -o $RUNPATH/sslvpn/$jar "$codebase$jar" || _RET=1
    done
    if [[ $_RET == 1 ]]; then
        rm -r $RUNPATH/sslvpn/
    fi
fi
if [ $_RET == 0 -o -d $RUNPATH/sslvpn ]; then
    echo '==> Use local codebase.'
    sed -i 's|\(^.*codebase="\).*\(".*$\)|\1file:./sslvpn/\2|' $RUNPATH/sslvpn.jnlp
else
    echo '==> Warnning: No download sslvpn jars.'
fi

if [[ x$_mode == 'x1' ]]; then
    sed -i -e 's/local=TH-1A-LN[12389]:22/&22/g' \
           -e 's/local=TH-1A-ns1:22/&22/g' $RUNPATH/sslvpn.jnlp
elif [[ x$_mode == 'x2' ]]; then
    sed -i -e "s/local=TH-1A-LN\([12389]\):22/local=$_myIP:222\1/g" \
           -e "s/local=TH-1A-ns1:22/local=$_myIP:2231/g" $RUNPATH/sslvpn.jnlp
    add_mode2_ssh_config $_myIP
else
    echo '!!! Illegal mode.'
    usage
    exit 3
fi

## Run
cd $RUNPATH/
javaws sslvpn.jnlp
