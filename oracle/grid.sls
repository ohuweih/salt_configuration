{% set state_id_prefix = "oracle_grid" %}
    
{{ state_id_prefix }}_grid_dir:
  file.directory:
    - name: /u01/app/oracle/product/23.0.0/grid
    - user: grid
    - group: oinstall
    - mode: 0755
    - makedirs: True

{{ state_id_prefix }}_zip_file:
  file.managed:
    - name: /root/grid_home.zip
    - source: https://download.oracle.com/otn/linux/oracle19c/190000/LINUX.X64_193000_grid_home.zip?AuthParam=1724116712_d494ab9534294dc0be93634c3ad1ddbc
    - skip_verify: True
    - user: grid
    - group: oinstall

{{ state_id_prefix }}_grid_archive_file:
  archive.extracted:
    - unless: ls /u01/app/oracle/product/23.0.0/grid/bin
    - name: /u01/app/oracle/product/23.0.0/grid
    - source: /root/grid_home.zip
    - user: grid
    - group: oinstall
    - enforce_toplevel: False


{{ state_id_prefix }}_asmcmd_set:
  cmd.run:
    - unless: "./asmcmd afd_lslbl /dev/sdb "
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


{% if salt['grains.get']('grid_installed') is defined %}
{{ state_id_prefix }}_already_installed:
  cmd.run:
    - name: echo grid is already installed
{% else %}
{{ state_id_prefix }}_install:
  cmd.run:
    - name: "gridSetup.sh -configureStandaloneServer -OSDBA sysdba -OSASM osasm -OSOPER osoper -ORACLE_BASE /u01/app/oracle -dbDiskGroupName DATA -diskList /dev/sdb,/dev/sdc,/dev/sdd -executeConfigTools -executeRootScript -configMethod ROOT -redundancy NORMAL -auSize 8 -diskString /dev/sd* -configureAFD -managementOption NONE -INVENTORY_LOCATION /u01/app/oraInventory
    - runas: grid
    - cwd: "/u01/app/oracle/product/23.0.0/grid/bin"
    - env:
      - ORACLE_HOME: "/u01/app/oracle/product/23.0.0/grid"


{{ state_id_prefix }}_set_success_grain:
  grains.present:
    - name: grid_installed
    - value: True
    - onchanges:
      - cmd: {{ state_id_prefix }}_install
{% endif %}

