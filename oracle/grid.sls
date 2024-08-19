{% set state_id_prefix = "oracle_grid" %}
    
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
    - source: salt://oracle/files/.zip
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

