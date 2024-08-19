{% set state_id_prefix = "oracle_grid" %}

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
    
{{ state_id_prefix }}_grid_dir:
  file.directory:
    - name: /u01/app/oracle/product/23.0.0/grid
    - user: grid
    - group: oinstall
    - mode: 0755
    - makedirs: True


{{ state_id_prefix }}_grid_archive_file:
  archive.extracted:
    - unless: ls /u01/app/oracle/product/23.0.0/grid/bin
    - name: /u01/app/oracle/product/23.0.0/grid
    - source: ### ###
    - user: grid
    - group: oinstall
    - enforce_toplevel: False

{{ state_id_prefix }}_asmcmd_set:
  cmd.run:
    - names:
      - "./asmcmd afd_label DATA1 /dev/sdb --init"
      - "./asmcmd afd_label DATA2 /dev/sdc --init"
      - "./asmcmd afd_label DATA3 /dev/sdd --init"
      - runas: root
      - cwd: "/u01/app/oracle/product/23.0.0/grid/bin"
      - env:
        - ORACLE_HOME: "/u01/app/oracle/product/23.0.0/grid"
        - ORACLE_BASE: "/tmp"

{{ state_id_prefix }}_asmcmd_verify:
  cmd.run:
    - names:
      - "./asmcmd afd_lslbl /dev/sdb "
      - "./asmcmd afd_lslbl /dev/sdc "
      - "./asmcmd afd_lslbl /dev/sdd "
      - runas: root
      - cwd: "/u01/app/oracle/product/23.0.0/grid/bin"
      - env:
        - ORACLE_HOME: "/u01/app/oracle/product/23.0.0/grid"
        - ORACLE_BASE: "/tmp"
















{{ state_id_prefix }}_dp_dir:
  file.directory:
    - name: {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/db
    - user: {{ map["oracle_db_user"] }}
    - group: {{ map["oracle_db_group"] }}
    - mode: 0755
    - makedirs: True


{{ state_id_prefix }}_db_archive_file:
  archive.extracted:
    - unless: ls {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/db/bin
    - name: {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/db
    - source: /data/stage/LINUX.X64_{{ map["oracle_db_version_long"] }}_db_home.zip
    - user: {{ map['oracle_db_user'] }}
    - group: {{ map['oracle_db_group'] }}
    - enforce_toplevel: False


{{ state_id_prefix }}_install_file:
  file.managed:
    - name: {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/db/db_install.rsp
    - user: {{ map["oracle_db_user"] }}
    - group: {{ map["oracle_db_group"] }}
    - mode: 0600
    - source: salt://oracle/files/oracle_db.rsp

{#

{{ state_id_prefix }}-orachk-command:
  cmd.run:
    - name: {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/grid/suptools/orachk/orachk -u -o pre -profile clusterware,asm

{{ state_id_prefix }}-runcluvfy-command:
  cmd.run:
    - name: {{ map["oracle_install_dir"] }}/{{ map["oracle_db_version"] }}/grid/runcluvfy.sh stage -pre hacfg -fixup -verbose
    - runas: {{ map["oracle_grid_user"] }}
    - env:
      - CV_ASSUME_DISTID: "OL7"

#}

{{ state_id_prefix }}_sysctl_file:
  file.managed:
    - name: /etc/sysctl.d/98-oracle.conf
    - user: root
    - group: root
    - mode: 0644
    - source: salt://oracle/files/98_oracle.j2


{{ state_id_prefix }}_limits_file:
  file.managed:
    - name: /etc/security/limits.d/oracle-database-preinstall-19c.conf
    - user: root
    - group: root
    - mode: 0644
    - source: salt://oracle/files/oracle_database_preinstall.j2


{{ state_id_prefix }}_firewalld_service:
  service.dead:
    - name: firewalld
    - enable: False


{{ state_id_prefix }}_selinux_mode:
  selinux.mode:
    - name: permissive


{{ state_id_prefix }}_setenv.sh_file:
  file.managed:
    - name: /home/oracle/scripts/setEnv.sh
    - user: {{ map['oracle_db_user'] }}
    - group: {{ map['oracle_db_group'] }}
    - mode: 0644
    - makedirs: True
    - source: salt://oracle/files/setenv.j2

