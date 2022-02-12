# build.sh anleitung
mkdir bauen<br />
cd bauen<br />
git clone https://github.com/OETiger/buildscript.git buildscript <br />
cd buildscript<br />
chmod +x build.sh<br />
rm -rf ../outputs/*<br />
./build.sh stable 18.02.4 v2018.2.4 sihb sisi sifb<br />
./build.sh beta 18.02.4 v2018.2.4 sihb sisi sifb<br />
./build.sh experimental 18.02.4 v2018.2.4 sihb sisi sifb<br />

## Beispiel  Ordnerstruktur
~/bauen/buildscript	#build.sh path
~/bauen/sites/		#SiWi-sites git clon (wird von build.sh erstellt)<br />
~/bauen/gluon/		#gluon git clon (wird von build.sh erstellt)<br />
~/bauen/outputs/	#output für Firmware Images & Logs<br />
