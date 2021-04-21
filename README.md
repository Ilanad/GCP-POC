# td-poc

Simple blueprints prepared for PoC for TD. 

- A deployment of `blueprint-openstack.yaml` creates all required infrastructure resources and networking and configures them to spin up a simple VM running a hello-world web-application.
- A deployment of `blueprint-vsphere-nsx-t.yaml` does the same but on VMWare vSphere + NSX-T software.

The application part is shared between the two parts for both VIMs and is vendor-agnostic.
