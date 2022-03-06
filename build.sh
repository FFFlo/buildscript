#!/bin/bash

### SETTINGS ###
# Warn of uninitialized variables
set -u
#exit on error
set -e
#CPU cores
NUM_CORES_PLUS_ONE=$(expr $(nproc) + 1)
#jump to upper folder from the build.sh
cd ../"$(dirname "$0")"

# set this to your sites git
SITESURL=https://github.com/Freifunk-Siegerland/sites.git
# set this to ur signingkeyfile
KEYFILE=~/.signkey/key.secret

### INPUTCHECK ###
#check if arguments empty
if [[ $# -eq 0 ]]; then
	echo "Run this script with the following arguments:"
	echo "./build.sh <1> <2> <3> <4> <n>"
	echo "1: GLUON_AUTOUPDATER_BRANCH for manifest: s=stable, b=beta, e=experimental"
	echo "2: GLUON_RELEASE: in format XX.XX(.??)"
	echo "3: GLUON_VERSION to build from: in format 'v20XX.?X.?X', example v2017.1.8"
	echo "4-n: Site XXXX to build for. Example 'sihb'"
	exit 1;
fi

#GLUON_AUTOUPDATER_BRANCH format check
case "${1}" in
	"")						echo "!!!!! No GLUON_AUTOUPDATER_BRANCH option was specified. !!!!!"; 	exit 1 ;;
	stable)				echo "----- GLUON_AUTOUPDATER_BRANCH = stable -----"; export GLUON_AUTOUPDATER_BRANCH=$1 ;;
	beta)					echo "----- GLUON_AUTOUPDATER_BRANCH = beta -----"; export GLUON_AUTOUPDATER_BRANCH=$1  ;;
	experimental)	echo "----- GLUON_AUTOUPDATER_BRANCH = experimental -----"; export GLUON_AUTOUPDATER_BRANCH=$1 ;;
	*)						echo "!!!!! Unknown GLUON_AUTOUPDATER_BRANCH !!!!!"; 					exit 1 ;;
esac

#GLUON_RELEASE format check
if [[ $2 == 'date' ]]; then
	export GLUON_RELEASE="$(date +%Y%m%d%H%M)"
else
	if [[ $2 == [0-9][0-9].[0-9][0-9].+([0-9]) ]] || [[ $2 == [0-9][0-9].[0-9][0-9] ]]; then
		echo "----- GLUON_RELEASE = "$2" -----"
		export GLUON_RELEASE=$2
	else
		echo "!!!!! GLUON_RELEASE not format XX.XX(.??) !!!!!"
		exit 1;
	fi
fi

#GLUON_VERSION format check
if [[ $3 == v20[0-9][0-9].+([0-9]).+([0-9]) ]]; then
	echo "----- GLUON_VERSION = "$3" -----"
else
	echo "!!!!! GLUON_VERSION format 'v20XX.?X.?X', example v2017.1.8 !!!!!"
	exit 1;
fi

#check/clone site git
if [[ -d sites ]]; then
	echo "----- found an existing sites folder -----"
else
	echo "----- cloneing sites from $SITESURL -----"
	git clone -c advice.detachedHead=false $SITESURL sites -b $3
fi

#check given sites exist
for SITE in "${@:4}"
do
	if [[ -d sites/$SITE ]]; then
		echo "----- will build for "$SITE" -----"
	else
		echo "!!!!! $SITE site not found !!!!!"
		exit 1;
	fi
done

#check for Secretkey exist and/or empty
if [[ -f $KEYFILE ]]; then
	if [[ -s $KEYFILE ]]; then
		echo "----- Manifest will be signed with keyfile $KEYFILE -----"
		read LESECRETKEY < $KEYFILE
	else
		echo "----- Found empty keyfile at $KEYFILE, will not sign manifest -----"
		LESECRETKEY=""
	fi
else
	echo "----- Pleas type in ur manifest signingkey or leave empty for no manifest signing -----"
	echo "----- The key will be saved in '$KEYFILE' -----"
	read -s -p 'Secretkey: ' LESECRETKEY
	if [[ $LESECRETKEY = "" ]]; then
		echo "----- will not sign Manifest -----"
		while true; do
			read -p "Create an empty file at "$KEYFILE" so this script doesnt ask again? [y/n]? " -n 1 -r
			echo    # (optional) move to a new line
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo "----- ^ done -----"
				touch $KEYFILE
				break
			else
				echo "----- No empty file created -----"
				break
			fi
		done
	else
		echo "----- writeing key in '$KEYFILE' -----"
		[[ ! -d $(dirname "$KEYFILE") ]] && mkdir $(dirname "$KEYFILE")
		#touch $KEYFILE
		echo "$LESECRETKEY" > $KEYFILE
	fi
fi

### check/clone gluon ###
#if [[ -s gluon/GLUON_VERSION ]]; then
#	if [[ "$3" != "$(cat gluon/GLUON_VERSION)" ]]; then
#		while true; do
#			echo "----- GLUON_VERSION does not match the allready cloned one -----"
#			read -p "Delete and clone "$3" [y/n]? " -n 1 -r
#			echo    # (optional) move to a new line
#			if [[ $REPLY =~ ^[Yy]$ ]]; then
#				rm -rf gluon
#				echo "----- gluon folder deleted -----"
#				echo "----- clone git "$3" -----"
#				git clone -c advice.detachedHead=false https://github.com/freifunk-gluon/gluon.git gluon -b $3
#				echo "$3" > gluon/GLUON_VERSION
#				break
#			else
#				echo "----- gluon folder not deleted -----"
#				exit 0;
#			fi
#		done
#	else
#		echo "----- GLUON_VERSION "$3" allready cloned -----"
#	fi
#else
#	[[ -d gluon/ ]] && rm -rf gluon/
#	echo "----- clone git "$3" -----"
#	git clone -c advice.detachedHead=false https://github.com/freifunk-gluon/gluon.git gluon -b $3
#	echo "$3" > gluon/GLUON_VERSION
#fi

#PATCHEN
#[[ ! -d gluon ]] && git clone -c advice.detachedHead=false https://github.com/freifunk-gluon/gluon.git gluon -b $3
#cd gluon
#git remote set-url origin https://github.com/freifunk-gluon/gluon.git
#git fetch origin
#rm -rf packages
#git checkout -q --force $3
#git clean -fd;
#[ `git branch --list patched` ] && git branch -D patched
#git checkout -B patching
#if [[ -d ../sites/patches ]]; then
#	echo "----- apply patches -----"
#	git apply --ignore-space-change --ignore-whitespace --whitespace=nowarn --verbose ../sites/patches/*.patch
#	git clean -fd
#	git checkout -B patched
#	git branch -D patching
#fi
#git branch -M patched
#cd ..

### BUILDING ###
for SITE in "${@:4}"
do
	#clean gluon folders
	[[ -d gluon/site ]] && rm -rf gluon/site
	[[ -d gluon/output/images ]] && rm -rf gluon/output/*

	#create folders
	mkdir -p gluon/site

	echo "----- copy site "$SITE" -----"
	cp -r sites/$SITE/* gluon/site/

	cd gluon

	echo "----- make update -----"
	make update

	#set GLUON_TARGETs
	case $3 in
	v2017*)
		BUILDARRAY=(\
			"ar71xx-generic" \
			"ar71xx-tiny" \
			"ar71xx-nand" \
			#"brcm2708-bcm2708" \
			#"brcm2708-bcm2709" \
			"mpc85xx-generic" \
			"ramips-mt7621" \
			#"x86-generic" \
			#"x86-geode" \
			#"x86-64" \
		)
		;;

	v2018*)
		BUILDARRAY=(\
			"ar71xx-generic" \
			"ar71xx-tiny" \
			"ar71xx-nand" \
			#"brcm2708-bcm2708" \
			#"brcm2708-bcm2709" \
			"mpc85xx-generic" \
			"mpc85xx-p1020" \
			"ramips-mt7621" \
			#"sunxi-cortexa7" \
			#"x86-generic" \
			#"x86-geode" \
			#"x86-64" \
		)
		;;

	v2021*)
		BUILDARRAY=(\
			"ar71xx-generic" \
			"ar71xx-tiny" \
			"ar71xx-nand" \
			"ath79-generic" \
			#"brcm2708-bcm2708" \
			#"brcm2708-bcm2709" \
			"ipq40xx-generic" \
			"ipq806x-generic" \
			"lantiq-xrx200" \
			"lantiq-xway" \
			"mpc85xx-generic" \
			"mpc85xx-p1020" \
			"ramips-mt7620" \
			"ramips-mt7621" \
			"ramips-mt76x8" \
			"ramips-rt305x" \
			#"sunxi-cortexa7" \
			#"x86-generic" \
			#"x86-geode" \
			#"x86-legacy" \
			#"x86-64" \
		)
		;;
	esac

	for NOWBUILDING in "${BUILDARRAY[@]}"
	do
		echo "----- cleaning $NOWBUILDING -----"
		make clean GLUON_TARGET=$NOWBUILDING
		echo "----- building $GLUON_AUTOUPDATER_BRANCH $NOWBUILDING for $SITE -----"
		make -j $NUM_CORES_PLUS_ONE GLUON_TARGET=$NOWBUILDING
	done

	TMP_GLUON_AUTOUPDATER_BRANCH=$GLUON_AUTOUPDATER_BRANCH

	export GLUON_AUTOUPDATER_BRANCH=stable
	echo "----- generating "$GLUON_AUTOUPDATER_BRANCH" manifest for "$SITE" -----"
	make manifest
	export GLUON_AUTOUPDATER_BRANCH=beta
	echo "----- generating "$GLUON_AUTOUPDATER_BRANCH" manifest for "$SITE" -----"
	make manifest
	export GLUON_AUTOUPDATER_BRANCH=experimental
	echo "----- generating "$GLUON_AUTOUPDATER_BRANCH" manifest for "$SITE" -----"
	make manifest

	export GLUON_AUTOUPDATER_BRANCH=$TMP_GLUON_AUTOUPDATER_BRANCH

	#zu bauen Pfad springen
	cd ..

	if ! [[ $LESECRETKEY = "" ]]; then
		echo "----- signing "$GLUON_AUTOUPDATER_BRANCH" manifest for "$SITE" -----"
		gluon/contrib/sign.sh $KEYFILE gluon/output/images/sysupgrade/$GLUON_AUTOUPDATER_BRANCH.manifest
	else
		echo "----- NOT signing "$GLUON_AUTOUPDATER_BRANCH" manifest for "$SITE" -----"
	fi

	OUTPUTPATH=outputs/$SITE/$GLUON_AUTOUPDATER_BRANCH

	[[ ! -d $OUTPUTPATH ]] && mkdir -p $OUTPUTPATH

	#output kopieren ohne backup
	echo "----- copying "$GLUON_AUTOUPDATER_BRANCH" images to ../"$OUTPUTPATH"/ -----"
	rsync -av --remove-source-files gluon/output/images/ $OUTPUTPATH/

	#copy .htaccess for hideing the manifest from all
	echo "----- copying .htaccess to ../"$OUTPUTPATH"/sysupgrade/ -----"
	cp -r buildscript/.htaccess  $OUTPUTPATH/sysupgrade/

	#copy logs and infos
	[[ ! -d $OUTPUTPATH/.infos ]] && mkdir -p $OUTPUTPATH/.infos
	cp -r gluon/site $OUTPUTPATH/.infos/
	cp -r buildscript/build.sh $OUTPUTPATH/.infos/
	echo "$GLUON_RELEASE" > $OUTPUTPATH/.infos/GLUON_RELEASE
	echo "$3" > $OUTPUTPATH/.infos/GLUON_VERSION
	echo "----- FINISHED building "$GLUON_AUTOUPDATER_BRANCH" firmware for "$SITE" -----"

done
