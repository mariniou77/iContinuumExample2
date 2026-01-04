# iContinuumExample2

## First adjustment

The first thing I adjust is the `Example2/inventory.ini`. There I setted up the IP addresses of the VMs in my GCP account and adjusted the variables.

## Second adjustment

The second adjustment was in `Example2/topology.sh.j2`. There, I made the mininet topology command a bit more precise by addidng the ablolute path and adding the internal_ip of onos_machine instead of the external. Additionally, before adding the switched, I am now checking if there is already some of them, so that in case I run the playbook agin, not to crush. Finally, I changed the agent `eno1` to `ens4` because that's what GCP uses.
