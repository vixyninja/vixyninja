# Services

Configuration for self-hosted services running on the Ubuntu homelab. These files are
the source of truth; the host copies are deployed from here.

## glance

`services/glance/glance.yml` — dashboard layout: pages, widgets, theme, and the feeds
each column renders.

Glance reads it from `/app/config/glance.yml` inside the container, so the usual mapping
is a bind mount:

```yaml
volumes:
  - ./services/glance/glance.yml:/app/config/glance.yml:ro
```

`theme.custom-css-file` points at `/app/config/custom.css`, a container-side path — mount
that file too if you use it.

Previously `home/glance.yml`, which filed it as a dotfile. It is service configuration
and belongs with the other services.

## nginx

`services/nginx/conf.d/default.conf` — catch-all server on port 80, proxying to
`127.0.0.1:8080` and forwarding `Host` and `X-Real-IP`.

`services/nginx/snippets/security.conf` — response-header hardening, included by the
server block.

Copy into `/etc/nginx/` on the host, keeping the layout:

```bash
sudo cp services/nginx/conf.d/default.conf     /etc/nginx/conf.d/
sudo cp services/nginx/snippets/security.conf  /etc/nginx/snippets/
sudo nginx -t && sudo systemctl reload nginx
```

Adjust `server_name` and the upstream port per host; the committed values are the
default-server fallback, not a production vhost.

## Secrets

None of these files hold credentials, and none should. TLS keys, basic-auth files, and
upstream tokens live on the host outside this repository.
