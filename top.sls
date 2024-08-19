base:
  '*':
    - core
  "role:salt_master":
    - match: grain
    - salt_master
    - salt-cloud
  "role:apache":
    - match: grain
    - apache
  "role:oracle":
    - match: grain
    - oracle
