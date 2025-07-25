#!/bin/bash
if [ $(uname) = "Darwin" ]; then
	if [ $(uname -p) = "arm" ] || [ $(uname -p) = "arm64" ]; then
		echo "It's recommended this script be ran on macOS/Linux with a clean iOS device running checkra1n."
		read -p "Press enter to continue"
		ARM=yes
	fi
fi

echo "Checkcursus deployment script"
echo "(C) 2020, JPilosoC"

echo ""
echo "Before you begin: This script will install Procursus with Sileo on Checkra1n."
echo "If you're already jailbroken, you can run this script on the checkra1n device."
echo "If you'd rather start clean, please Reset System via the Loader app first."
read -p "Press enter to continue"

if ! which curl >> /dev/null; then
	echo "Error: curl not found"
	exit 1
fi
if [[ "${ARM}" = yes ]]; then
	if ! which zsh >> /dev/null; then
		echo "Error: zsh not found"
		exit 1
	fi
else
	if which iproxy >> /dev/null; then
		iproxy 4444 44 >> /dev/null 2>/dev/null &
	else
		echo "Error: iproxy not found"
		exit 1
	fi
fi
rm -rf checkcursus-tmp
mkdir checkcursus-tmp
cd checkcursus-tmp

echo '#!/bin/zsh' > checkcursus-device-deploy.sh
if [[ ! "${ARM}" = yes ]]; then
	echo 'cd /var/root' >> checkcursus-device-deploy.sh
fi
echo 'if [[ -f "/.bootstrapped" ]]; then' >> checkcursus-device-deploy.sh
echo 'mkdir -p /checkcursus && mv migration /checkcursus' >> checkcursus-device-deploy.sh
echo 'chmod 0755 /checkcursus/migration' >> checkcursus-device-deploy.sh
echo '/checkcursus/migration' >> checkcursus-device-deploy.sh
echo 'rm -rf /checkcursus' >> checkcursus-device-deploy.sh
echo 'else' >> checkcursus-device-deploy.sh
echo 'VER=$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)' >> checkcursus-device-deploy.sh
echo 'if [[ "${VER%.*}" -ge 12 ]] && [[ "${VER%.*}" -lt 13 ]]; then' >> checkcursus-device-deploy.sh
echo 'CFVER=1500' >> checkcursus-device-deploy.sh
echo 'elif [[ "${VER%.*}" -ge 13 ]]; then' >> checkcursus-device-deploy.sh
echo 'CFVER=1600' >> checkcursus-device-deploy.sh
echo 'elif [[ "${VER%.*}" -ge 14 ]]; then' >> checkcursus-device-deploy.sh
echo 'CFVER=1700' >> checkcursus-device-deploy.sh
echo 'else' >> checkcursus-device-deploy.sh
echo 'echo "${VER} not compatible."' >> checkcursus-device-deploy.sh
echo 'exit 1' >> checkcursus-device-deploy.sh
echo 'fi' >> checkcursus-device-deploy.sh
echo 'gzip -d bootstrap_${CFVER}.tar.gz' >> checkcursus-device-deploy.sh
echo 'mount -uw -o union /dev/disk0s1s1' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/profile' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/profile.d' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/alternatives' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/apt' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/ssl' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/ssh' >> checkcursus-device-deploy.sh
echo 'rm -rf /etc/dpkg' >> checkcursus-device-deploy.sh
echo 'rm -rf /Library/dpkg' >> checkcursus-device-deploy.sh
echo 'rm -rf /var/cache' >> checkcursus-device-deploy.sh
echo 'rm -rf /var/lib' >> checkcursus-device-deploy.sh
echo 'tar --preserve-permissions -xkf bootstrap_${CFVER}.tar -C /' >> checkcursus-device-deploy.sh
printf %s 'SNAPSHOT=$(snappy -s | ' >> checkcursus-device-deploy.sh
printf %s "cut -d ' ' -f 3 | tr -d '\n')" >> checkcursus-device-deploy.sh
echo '' >> checkcursus-device-deploy.sh
echo 'snappy -f / -r $SNAPSHOT -t orig-fs' >> checkcursus-device-deploy.sh
echo 'fi' >> checkcursus-device-deploy.sh
echo '/usr/libexec/firmware' >> checkcursus-device-deploy.sh
echo 'mkdir -p /etc/apt/sources.list.d/' >> checkcursus-device-deploy.sh
echo 'echo "Types: deb" > /etc/apt/sources.list.d/checkcursus.sources' >> checkcursus-device-deploy.sh
echo 'echo "URIs: https://jpilosoc.github.io/Checkcursus/" >> /etc/apt/sources.list.d/checkcursus.sources' >> checkcursus-device-deploy.sh
echo 'echo "Suites: ./" >> /etc/apt/sources.list.d/checkcursus.sources' >> checkcursus-device-deploy.sh
echo 'echo "Components: " >> /etc/apt/sources.list.d/checkcursus.sources' >> checkcursus-device-deploy.sh
echo 'echo "" >> /etc/apt/sources.list.d/checkcursus.sources' >> checkcursus-device-deploy.sh
echo 'mkdir -p /etc/apt/preferences.d/' >> checkcursus-device-deploy.sh
echo 'echo "Package: *" > /etc/apt/preferences.d/checkcursus' >> checkcursus-device-deploy.sh
echo 'echo "Pin: release n=checkcursus-ios" >> /etc/apt/preferences.d/checkcursus' >> checkcursus-device-deploy.sh
echo 'echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/checkcursus' >> checkcursus-device-deploy.sh
echo 'echo "" >> /etc/apt/preferences.d/checkcursus' >> checkcursus-device-deploy.sh
echo 'if [[ $VER = 12.1* ]] || [[ $VER = 12.0* ]]; then' >> checkcursus-device-deploy.sh
echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i org.swift.libswift_5.0-electra2_iphoneos-arm.deb' >> checkcursus-device-deploy.sh
echo 'fi' >> checkcursus-device-deploy.sh
echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb' >> checkcursus-device-deploy.sh
echo 'uicache -p /Applications/Sileo.app' >> checkcursus-device-deploy.sh
echo 'echo -n "" > /var/lib/dpkg/available' >> checkcursus-device-deploy.sh
echo '/Library/dpkg/info/profile.d.postinst' >> checkcursus-device-deploy.sh
echo 'touch /.mount_rw' >> checkcursus-device-deploy.sh
echo 'touch /.installed_checkcursus' >> checkcursus-device-deploy.sh
echo 'rm bootstrap*.tar*' >> checkcursus-device-deploy.sh
echo 'rm migration' >> checkcursus-device-deploy.sh
echo 'rm org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb' >> checkcursus-device-deploy.sh
echo 'rm org.swift.libswift_5.0-electra2_iphoneos-arm.deb' >> checkcursus-device-deploy.sh
echo 'rm checkcursus-device-deploy.sh' >> checkcursus-device-deploy.sh

echo "Downloading Resources..."
curl -L -O https://github.com/JPilosoC/Checkcursus/raw/master/bootstrap_1500.tar.gz -O https://github.com/JPilosoC/Checkcursus/raw/master/bootstrap_1600.tar.gz -O https://github.com/JPilosoC/Checkcursus/raw/master/bootstrap_1700.tar.gz -O https://github.com/JPilosoC/Checkcursus/raw/master/migration -O https://github.com/JPilosoC/Checkcursus/raw/master/org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb -O https://github.com/JPilosoC/Checkcursus/raw/master/org.swift.libswift_5.0-electra2_iphoneos-arm.deb
clear
if [[ ! "${ARM}" = yes ]]; then
	echo "Copying Files to your device"
	echo "Default password is: alpine"
	scp -P4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" bootstrap_1500.tar.gz bootstrap_1600.tar.gz bootstrap_1700.tar.gz migration org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb org.swift.libswift_5.0-electra2_iphoneos-arm.deb checkcursus-device-deploy.sh root@127.0.0.1:/var/root/
	clear
fi
echo "Installing Procursus bootstrap and Sileo on your device"
if [[ "${ARM}" = yes ]]; then
	zsh ./checkcursus-device-deploy.sh
else
	echo "Default password is: alpine"
	ssh -p4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "zsh /var/root/checkcursus-device-deploy.sh"
	echo "All Done!"
	killall iproxy
fi
