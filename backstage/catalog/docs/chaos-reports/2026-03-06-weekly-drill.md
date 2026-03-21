# Weekly Chaos Drill - 2026-03-06

## Summary
- Status: **SUCCESS**
- Start (UTC): 2026-03-06T22:03:16Z
- End (UTC): 2026-03-06T22:03:31Z
- Total runtime: 15s
- Target service: jaeger
- Planned disruption: 12s stop/restart

## Outcome
- Drill exit code: 0
- Integrity check exit code: 0

## Chaos KPIs (Last 7 Days)
- Experiments started: 2
- Experiments recovered: 2
- Experiment failures: 0
- Avg recovery time (s): 10.5

## Drill Command Output
```
Grafana annotation created: CHAOS START
CHAOS_EVENT phase=start id=exp-20260306T220316Z-23371 kind=stop target=jaeger status=injected duration_sec=12 delay_ms=0 elapsed_sec=0
Stopping jaeger for 12s
Grafana annotation created: CHAOS END
CHAOS_EVENT phase=end id=exp-20260306T220316Z-23371 kind=stop target=jaeger status=recovered duration_sec=12 delay_ms=0 elapsed_sec=13
Recovered jaeger
```

## Integrity Check Snapshot
```
OK   jaeger mount /tmp/jaeger <- /mnt/data/jaeger
INFO jaeger mount /tmp <- /var/lib/docker/volumes/6a52c5b3eba6c65cc864c00f006072e11d1db334c4e3b8d30bc438b103774c62/_data (docker-managed path, skipped)
OK   gitea mount /data <- /mnt/data/gitea
OK   gitea mount /etc/timezone <- /etc/timezone
OK   gitea mount /etc/localtime <- /etc/localtime
OK   act-runner mount /data <- /mnt/data/act-runner
OK   act-runner mount /var/run/docker.sock <- /var/run/docker.sock
OK   authelia mount /config <- /mnt/data/authelia
OK   vaultwarden mount /data <- /mnt/data/vaultwarden
OK   vaultwarden mount /run/secrets/admin_token <- /home/sidhant/vaultwarden/admin_token
OK   code-server mount /home/coder/.config/code-server <- /home/sidhant/.config/code-server
OK   code-server mount /home/coder/project <- /home/sidhant
OK   mailserver mount /var/mail <- /mnt/data/mailserver
OK   mailserver mount /tmp/docker-mailserver <- /mnt/data/mailserver/config
OK   promtail mount /var/log <- /var/log
INFO promtail mount /var/lib/docker/containers <- /var/lib/docker/containers (docker-managed path, skipped)
OK   promtail mount /home/sidhant/logs/chaos <- /home/sidhant/logs/chaos
OK   promtail mount /etc/promtail/promtail.yml <- /home/sidhant/observability/promtail.yml

[3/4] Critical application path checks
OK   gitea repositories path exists
OK   gitea repo path exists: /data/git/repositories/sidhant/homelab.git
OK   loki host data path ownership is 10001:10001

[4/4] Recent critical log scan (last 2m)
OK   traefik no critical log lines
OK   minio no critical log lines
OK   prometheus no critical log lines
OK   grafana no critical log lines
OK   loki no critical log lines
OK   jaeger no critical log lines
OK   gitea no critical log lines
OK   act-runner no critical log lines
OK   authelia no critical log lines
OK   vaultwarden no critical log lines
OK   code-server no critical log lines
OK   mailserver no critical log lines
OK   promtail no critical log lines

Summary: BAD=0 WARN=0
```

## Grafana
- Chaos Control Center: https://grafana.homelabdev.space/d/chaos-center/chaos-control-center
- Chaos Reporting: https://grafana.homelabdev.space/d/chaos-reporting/chaos-reporting
