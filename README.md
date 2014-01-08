Orient Mobile Insurance
========================

version: 1.1
------------
1. Always run [rake data:deprecate_devices] after upgrading catalogue version

Installation
------------

1. Clone this repo.
2. Copy config/application.example.yml to config/application.yml
  2.1 Replace the corresponding (last 3) lines with:
    DEBUG_DEVICE_ATLAS: true
    DEBUG_DEVICE_ATLAS_MODEL: T3
    DEBUG_DEVICE_ATLAS_VENDOR: Tecno
3. Comment out the file app/admin/policies.rb
4. Copy database.example.yml to database.yml and edit database.yml appropriately.
4. run rake db:migrate
5. Uncomment app/admin/policies.rb
5. Start server rails server

After install
--------------
Import devices from Orient\ Mobile\ Catalogue.xlxs or a similar file used to verify that a device is insurable.

________________________

License
