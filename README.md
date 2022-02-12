# sites
Site Configurations der Städte im Bereich Siegerland.

## Zuordnung der Städte zu den Kürzeln

Die Kürzel der Städte sind im [Freifunk-Wiki](http://wiki.freifunk.net/Namenskonventionen_im_Kreis_Siegen-Wittgenstein) hinterlegt.

## build.sh anleitung
mkdir bauen<br />
cd bauen<br />
git clone https://github.com/Freifunk-Siegerland/sites.git -b v2018.2.4<br />
cd sites<br />
chmod +x build.sh<br />
rm -rf ../outputs/*<br />
./build.sh stable 18.02.4 v2018.2.4 sihb sisi sifb<br />
./build.sh beta 18.02.4 v2018.2.4 sihb sisi sifb<br />
./build.sh experimental 18.02.4 v2018.2.4 sihb sisi sifb<br />

## Beispiel  Ordnerstruktur
~/bauen/sites/        #SiWi-sites git clon enthält die build.sh<br />
~/bauen/gluon/        #gluon git clon (wird von build.sh erstellt)<br />
~/bauen/outputs/      #output für Firmware Images & Logs<br />
