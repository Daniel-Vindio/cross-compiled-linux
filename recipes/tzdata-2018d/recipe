program="tzdata"
version="2018d"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz


description="
Time Zone Database (IANA)

The Time Zone Database (often called tz or zoneinfo) contains code and 
data that represent the history of local time for many representative 
locations around the globe. It is updated periodically to reflect 
changes made by political bodies to time zone boundaries, UTC offsets, 
and daylight-saving rules. Its management procedure is documented 
in BCP 175: Procedures for Maintaining the Time Zone Database.
---
"

build() {

unpack "${tardir}/$tarname"
cd "$srcdir"
echo -e "----------------------------XXXXX $PWD"
echo -e "---------------------------->>>>> $srcdir"

ZONEINFO=${destdir}/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

mkdir -pv ${destdir}/etc/localtime
cp -v ${destdir}/usr/share/zoneinfo/Europe/Madrid ${destdir}/etc/localtime

}











