# Weekly Chaos Drill - 2026-03-22

## Summary
- Status: **FAILED**
- Start (UTC): 2026-03-22T03:30:28Z
- End (UTC): 2026-03-22T03:30:43Z
- Total runtime: 15s
- Target service: jaeger
- Planned disruption: 12s stop/restart

## Outcome
- Drill exit code: 0
- Integrity check exit code: 1

## Chaos KPIs (Last 7 Days)
- Experiments started: 1
- Experiments recovered: 1
- Experiment failures: 0
- Avg recovery time (s): 13.0

## Drill Command Output
```
Grafana annotation created: CHAOS START
CHAOS_EVENT phase=start id=exp-20260322T033028Z-15951 kind=stop target=jaeger status=injected duration_sec=12 delay_ms=0 elapsed_sec=0
Stopping jaeger for 12s
Grafana annotation created: CHAOS END
CHAOS_EVENT phase=end id=exp-20260322T033028Z-15951 kind=stop target=jaeger status=recovered duration_sec=12 delay_ms=0 elapsed_sec=13
Recovered jaeger
```

## Integrity Check Snapshot
```
OK   backstage mount /app/app-config.yaml <- /home/sidhant/backstage/app-config.yaml
OK   backstage mount /app/catalog <- /home/sidhant/backstage/catalog
OK   backstage mount /repo <- /home/sidhant/homelab
OK   backstage-postgres mount /var/lib/postgresql/data <- /mnt/data/backstage-postgres
OK   goalert-postgres mount /var/lib/postgresql/data <- /mnt/data/goalert-postgres
OK   cadvisor mount /sys <- /sys
OK   cadvisor mount /var/lib/docker <- /var/lib/docker
OK   cadvisor mount /dev/disk <- /dev/disk
OK   cadvisor mount /rootfs <- /
OK   cadvisor mount /var/run <- /var/run
OK   alertmanager mount /etc/alertmanager/alertmanager.yml <- /home/sidhant/observability/alertmanager.yml
OK   alertmanager mount /alertmanager <- /mnt/data/alertmanager

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
OK   backstage no critical log lines
OK   backstage-postgres no critical log lines
OK   goalert no critical log lines
OK   goalert-postgres no critical log lines
OK   cadvisor no critical log lines
OK   alertmanager no critical log lines

Summary: BAD=2 WARN=0
```

## Grafana
- Chaos Control Center: https://grafana.homelabdev.space/d/chaos-center/chaos-control-center
- Chaos Reporting: https://grafana.homelabdev.space/d/chaos-reporting/chaos-reporting
