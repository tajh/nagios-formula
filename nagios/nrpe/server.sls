{% from "nagios/map.jinja" import nrpe with context %}

nrpe-server-package:
  pkg.installed:
    - name: {{ nrpe.server }}

nrpe-server-service:
  service.running:
    - name: {{ nrpe.service }}
    - enable: true

{% if grains['os_family'] == 'FreeBSD' %}
/usr/local/etc/nrpe.cfg:
   file.managed:
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: wheel
    - mode: 644
    - watch_in:
      - service: {{ nrpe.service }}
{% else %}
/etc/nagios/nrpe.cfg:
   file.managed:
    - source: salt://nagios/nrpe/files/nrpe.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: {{ nrpe.service }}
{% endif %}

{% if grains['os_family'] == 'Arch' %}
nrpe-group:
  group.present:
    - name: nrpe
    - system: true
    - gid: 31

nrpe-user:
  user.present:
    - name: nrpe
    - shell: /bin/false
    - home: /usr/share/nagios
    - gid_from_name: true
    - system: true
    - uid: 31
    - guid: 31

extend:
  /etc/nagios/nrpe.cfg:
    file:
      - user: nrpe
      - group: nrpe
      - require:
        - user: nrpe-user
        - group: nrpe-group
{% endif %}
