awk '
/-----BEGIN CERTIFICATE-----/ {n++; file=sprintf("/tmp/ca-%d.crt",n)}
file {print > file}
/-----END CERTIFICATE-----/ {close(file); file=""}
' STAR_cita_utoronto_ca.ca-bundle

cat cita-wildcard.crt /tmp/ca-3.crt /tmp/ca-2.crt > fullchain.pem

echo " # of certs in infullchain.pem"
echo "=============================="

grep -c 'BEGIN CERTIFICATE' fullchain.pem

echo "Verify certificate chain"
echo "=============================="
cat /tmp/ca-3.crt /tmp/ca-2.crt > /tmp/intermediate-chain.crt

openssl verify \
  -CAfile /tmp/ca-1.crt \
  -untrusted /tmp/intermediate-chain.crt \
  cita-wildcard.crt
