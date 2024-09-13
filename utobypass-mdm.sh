{\rtf1\ansi\ansicpg1252\cocoartf2757
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs26 \cf0 \expnd0\expndtw0\kerning0
#!/bin/bash\
\
RED='\\033[1;31m'\
GREEN='\\033[1;32m'\
BLUE='\\033[1;34m'\
YELLOW='\\033[1;33m'\
PURPLE='\\033[1;35m'\
CYAN='\\033[1;36m'\
NC='\\033[0m'\
\
echo -e "$\{CYAN\}*-------------------*---------------------*$\{NC\}"\
echo -e "$\{YELLOW\}* Check MDM - Skip MDM Auto for MacOS by  *$\{NC\}"\
echo -e "$\{RED\}*             SKIPMDM.COM                 *$\{NC\}"\
echo -e "$\{RED\}*            Phoenix Team                 *$\{NC\}"\
echo -e "$\{CYAN\}*-------------------*---------------------*$\{NC\}"\
echo ""\
\
PS3='Please enter your choice: '\
options=("Autoypass on Recovery" "Check MDM Enrollment" "Reboot" "Exit")\
\
select opt in "$\{options[@]\}"; do\
	case $opt in\
	"Autoypass on Recovery")\
		echo -e "\\n\\t$\{GREEN\}Bypass on Recovery$\{NC\}\\n"\
\
		# Mount Volumes\
		echo -e "$\{BLUE\}Mounting volumes...$\{NC\}"\
		systemVolumePath="/Volumes/Macintosh HD"\
		dataVolumePath="/Volumes/Macintosh HD - Data"\
\
		if [ ! -d "$systemVolumePath" ]; then\
			diskutil mount "Macintosh HD"\
		fi\
\
		if [ ! -d "$dataVolumePath" ]; then\
			diskutil mount "Macintosh HD - Data"\
		fi\
\
		echo -e "$\{GREEN\}Volume preparation completed$\{NC\}\\n"\
\
		# Create User\
		echo -e "$\{BLUE\}Checking user existence$\{NC\}"\
		dscl_path="$dataVolumePath/private/var/db/dslocal/nodes/Default"\
		localUserDirPath="/Local/Default/Users"\
		defaultUID="501"\
		if ! dscl -f "$dscl_path" localhost -list "$localUserDirPath" UniqueID | grep -q "\\<$defaultUID\\>"; then\
			echo -e "$\{CYAN\}Create a new user / T\uc0\u7841 o User m\u7899 i$\{NC\}"\
			echo -e "$\{CYAN\}Press Enter to continue, Note: Leaving it blank will default to the automatic user / Nh\uc0\u7845 n Enter \u273 \u7875  ti\u7871 p t\u7909 c, L\u432 u \'fd: c\'f3 th\u7875  kh\'f4ng \u273 i\u7873 n s\u7869  t\u7921  \u273 \u7897 ng nh\u7853 n User m\u7863 c \u273 \u7883 nh$\{NC\}"\
			echo -e "$\{CYAN\}Enter Full Name (Default: Apple) / Nh\uc0\u7853 p t\'ean User (M\u7863 c \u273 \u7883 nh: Apple)$\{NC\}"\
			read -rp "Full name: " fullName\
			fullName="$\{fullName:=Apple\}"\
\
			echo -e "$\{CYAN\}Nh\uc0\u7853 n Username$\{NC\} $\{RED\}WRITE WITHOUT SPACES / VI\u7870 T LI\u7872 N KH\'d4NG D\u7844 U$\{NC\} $\{GREEN\}(M\u7863 c \u273 \u7883 nh: Apple)$\{NC\}"\
			read -rp "Username: " username\
			username="$\{username:=Apple\}"\
\
			echo -e "$\{CYAN\}Enter the User Password (default: 1234) / Nh\uc0\u7853 p m\u7853 t kh\u7849 u (m\u7863 c \u273 \u7883 nh: 1234)$\{NC\}"\
			read -rsp "Password: " userPassword\
			userPassword="$\{userPassword:=1234\}"\
\
			echo -e "\\n$\{BLUE\}Creating User / \uc0\u272 ang t\u7841 o User$\{NC\}"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UserShell "/bin/zsh"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" RealName "$fullName"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" UniqueID "$defaultUID"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" PrimaryGroupID "20"\
			mkdir "$dataVolumePath/Users/$username"\
			dscl -f "$dscl_path" localhost -create "$localUserDirPath/$username" NFSHomeDirectory "/Users/$username"\
			dscl -f "$dscl_path" localhost -passwd "$localUserDirPath/$username" "$userPassword"\
			dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"\
			echo -e "$\{GREEN\}User created$\{NC\}\\n"\
		else\
			echo -e "$\{BLUE\}User already created$\{NC\}\\n"\
		fi\
\
		# Block MDM hosts\
		echo -e "$\{BLUE\}Blocking MDM hosts...$\{NC\}"\
		hostsPath="$systemVolumePath/etc/hosts"\
		blockedDomains=("deviceenrollment.apple.com" "mdmenrollment.apple.com" "iprofiles.apple.com")\
		for domain in "$\{blockedDomains[@]\}"; do\
			echo "0.0.0.0 $domain" >>"$hostsPath"\
		done\
		echo -e "$\{GREEN\}Successfully blocked host / Th\'e0nh c\'f4ng ch\uc0\u7863 n host$\{NC\}\\n"\
\
		# Remove config profiles\
		echo -e "$\{BLUE\}Remove config profiles$\{NC\}"\
		configProfilesSettingsPath="$systemVolumePath/var/db/ConfigurationProfiles/Settings"\
		touch "$dataVolumePath/private/var/db/.AppleSetupDone"\
		rm -rf "$configProfilesSettingsPath/.cloudConfigHasActivationRecord"\
		rm -rf "$configProfilesSettingsPath/.cloudConfigRecordFound"\
		touch "$configProfilesSettingsPath/.cloudConfigProfileInstalled"\
		touch "$configProfilesSettingsPath/.cloudConfigRecordNotFound"\
		echo -e "$\{GREEN\}Config profiles removed$\{NC\}\\n"\
\
		echo -e "$\{GREEN\}------ Autobypass SUCCESSFULLY / Autobypass HO\'c0N T\uc0\u7844 T ------$\{NC\}"\
		echo -e "$\{CYAN\}------ Exit Terminal. Reboot Macbook and ENJOY ! ------$\{NC\}"\
		break\
		;;\
\
	"Check MDM Enrollment")\
		if [ ! -f /usr/bin/profiles ]; then\
			echo -e "\\n\\t$\{RED\}Don't use this option in recovery$\{NC\}\\n"\
			continue\
		fi\
\
		if ! sudo profiles show -type enrollment >/dev/null 2>&1; then\
			echo -e "\\n\\t$\{GREEN\}Success$\{NC\}\\n"\
		else\
			echo -e "\\n\\t$\{RED\}Failure$\{NC\}\\n"\
		fi\
		;;\
\
	"Reboot")\
		echo -e "\\n\\t$\{BLUE\}Rebooting...$\{NC\}\\n"\
		reboot\
		;;\
\
	"Exit")\
		echo -e "\\n\\t$\{BLUE\}Exiting...$\{NC\}\\n"\
		exit\
		;;\
\
	*)\
		echo "Invalid option $REPLY"\
		;;\
	esac\
done}