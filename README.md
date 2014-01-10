Orient Mobile Insurance
========================

version: 1.1
------------
1. Always run [rake data:deprecate_devices] after upgrading catalogue version

Installation
------------

1. Clone this repo.
2. Copy config/application.example.yml to config/application.yml
    1. Replace the corresponding (last 3) lines with:
    2. DEBUG_DEVICE_ATLAS: true
    3. DEBUG_DEVICE_ATLAS_MODEL: T3
    4. DEBUG_DEVICE_ATLAS_VENDOR: Tecno
3. Comment out the file app/admin/policies.rb
4. Copy database.example.yml to database.yml and edit database.yml appropriately.
4. run ```rake db:migrate```
5. Uncomment app/admin/policies.rb
5. Start server ```rails server```

After install
--------------
- Import devices by: log in to admin -> refernce data -> Devices -> Import devices -> /path/to/app/doc/data/patches/Orient Mobile Catalogue January.xlsx

- Import dealers portal users (used in outlet collecting and veryfying claim) through: log in to admin -> reference data -> agents -> import agents /path/to/app/doc/data/patches/simba_telecom_agents.csv

You have to create users for use with Sercive Portal (SP) and Claims Portal (CP) manually by: log in to admin -> reference data -> agents -> New agent who the super admin will go on to add as users who can later log in to the Claims Portal or Service Portal.
________________________

License
