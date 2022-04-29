# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import nifi with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}


nifi-package-install-dependency-tar:
  pkg.installed:
    - name: tar

{% if nifi.systemdconfig.user != 'root' %}
nifi-user:
  user.present:
    - name: {{nifi.systemdconfig.user}}
    - shell: /bin/false
    - createhome: false
{% endif %}


nifi-package-install-pkg-installed:
  archive.extracted:
    - name: {{ nifi.pkg.installdir }}/nifi-{{ nifi.pkg.version }}
    - source: {{ nifi.pkg.downloadurl }}
    - user: {{ nifi.systemdconfig.user }}
    - group: {{ nifi.systemdconfig.group }}
    - if_missing: {{ nifi.pkg.installdir }}/nifi-{{ nifi.pkg.version }}
    - skip_verify: True
    - keep_source: False
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - enforce_ownership_on: {{ nifi.pkg.installdir }}/nifi-{{ nifi.pkg.version }}
    - require:
      - pkg: nifi-package-install-dependency-tar

{% if pillar.nifi.nifi['web.https.host'] != '' %}
copy-truststore:
  file.managed:
    - name: {{ nifi.pkg.installdir }}/nifi-{{ nifi.pkg.version }}/conf/truststore.p12
    - source: {{ files_switch(['truststore.p12'],
                              lookup='copy-truststore'
                 )
              }}
    - user: {{ nifi.systemdconfig.user }}
    - group: {{ nifi.systemdconfig.group }}

{% set keystore=grains['fqdn']+'_keystore.p12' %}
copy-keystore:
  file.managed:
    - name: {{ nifi.pkg.installdir }}/nifi-{{ nifi.pkg.version }}/conf/keystore.p12
    - source: {{ files_switch([keystore],
                              lookup='copy-keystore'
                 )
              }}
    - user: {{ nifi.systemdconfig.user }}
    - group: {{ nifi.systemdconfig.group }}
{% endif %}
