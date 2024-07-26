apacheInstall:
  pkg.installed:
    - name: httpd
    - skip_verify: True
    - allow_updates: True

htmlFileManage:
  file.managed:
    - name: /var/www/html/index.html
    - source: salt://apache/files/index.html
    - user: apache
    - group: apache
    - makedirs: Ture

apacheStart:
  service.running:
    - name: httpd
    - enable: True
    - reload: True
    - watch:
      - file: /var/www/html/index.html
