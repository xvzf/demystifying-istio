# Experiments

## Circuit breaking

Health-check endpoint: `curl -v whoami.127.0.0.1.nip.io:8080/health`
Set faulty health-check: `curl -v -XPOST -d501 whoami.127.0.0.1.nip.io:8080/health`

Test load distribution: `hey -c 2 -n 30 http://whoami.127.0.0.1.nip.io:8080/health` -> we have one backend now serving 5xx -> we should see the split ratio

