{% set state_id_prefix = 'salt_master' %}

{{ state_id_prefix }}_install_salt:
  pkg.installed:
    - pkgs:
      - salt-master
      - salt-cloud

{{ state_id_prefix }}_manage_master_conf:
  file.managed:
    - name: /etc/salt/master
    - source: salt://salt_master/files/master.conf
    - user: root
    - group: root
    - template: jinja
    - mode: 0644

{% if 'master' in grains['id'] %}
{% if '1' in grains['id'] %}
{{ state_id_prefix }}_set_cron:
  cron.present:
    - name: "salt-cp --chunked salt_master_2 /etc/salt/pki/ /etc/salt/"
    - user: root
    - minute: 5
    - hour: "*"
    - daymonth: "*"
    - month: "*"
    - dayweek: "*"
{% endif %}
{% endif %}

{{ state_id_prefix }}_start_salt_master:
  service.running:
    - name: salt-master
    - enable: True
