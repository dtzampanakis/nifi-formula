In our pillar file
- We run nifi as a cluster with
cluster.is.node: true.
- We do not run the nifi's embedded zookeeper with
state.management.embedded.zookeeper.start: 'false'
- Use single-user-authorizer/provider in the loginidentityproviders section

Requirments for the example pillar.
- Zookeeper state to be applied first.
- The cert_creation scripts to run before nifi state. When the script runs it will create in nifi-formul/nifi/files/default the p12 keystore need from nifi.
