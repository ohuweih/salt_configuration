base:
  '*':
    - core
  "role:salt_master":
    - match: grain
    - salt_master
    - salt-cloud
  "application:apache":
    - match: grain
    - apache
