{% set state_id_prefix = "oracle_common" %}

{{ state_id_prefix }}_install_packages:
  pkg.installed:
    - pkgs:
      - binutils 
      - compat-libcap1 
      - compat-libstdc++ 
      - gcc 
      - gcc-c++ 
      - glibc 
      - glibc-devel 
      - ksh 
      - libgcc 
      - libstdc++ 
      - libstdc++-devel 
      - libaio 
      - libaio-devel 
      - make 
      - sysstat
      - oracleasmlib
      - oracleasm-support
      - oracle-database-preinstall


{{ state_id_prefix }}_oinstall_group:
  group.present:
    - name: oinstall
    - gid: 501


{% for id, config in pillar["oracle_users"].items() %}
{{ state_id_prefix }}_{{ id }}_user:
  user.present:
    - name: {{ config["name"] }}
    - uid: {{ config["uid"] }}
    - gid: {{ config["gid"] }}
{% endfor %}


{% for id, config in pillar["oracle_groups"].items() %}
{{ state_id_prefix }}_{{ id }}_group:
  group.present:
    - name: {{ config["name"] }}
    - gid: {{ config["gid"] }}
    - members:
      - {{ map["oracle_db_user"] }}
      - {{ map["oracle_grid_user"] }}
{% endfor %}


{{ state_id_prefix }}_oracle_dir:
  file.directory:
    - name: /u01/app/oracle
    - user: oracle
    - group: oinstall
    - mode: 0755
    - makedirs: True


{{ state_id_prefix }}_oraInventory_dir:
  file.directory:
    - name: /u01/app/oraInventory
    - user: oracle
    - group: oinstall
    - mode: 0755
    - makedirs: True
