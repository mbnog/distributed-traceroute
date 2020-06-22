BEGIN { PROTO="ICMP"; OLDOFS=OFS; }
/^Start:/ { ST=$2 }
/^HOST:/ { PH=$2 }
$1 ~ /^[0-9]*\.$/ { gsub(/\./,"",$1); gsub(/AS/,"",$2); gsub(/\?\?\?/,"0",$2); gsub(/\?\?\?/,"0.0.0.0",$3); gsub("%","",$4); print " INSERT INTO pingdata VALUES ("; OFS=","; print "'"ST"'","'"PH"'","'"TGT"'","'"PROTO"'",$1,$2,"'"$3"'",$4,$5,$6,$7,$8,$9,$10; OFS=OLDOFS; print ");" }
