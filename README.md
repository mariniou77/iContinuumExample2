# iContinuumExample2

## Adjustments before first run

### First adjustment

The first thing I adjust is the `Example2/inventory.ini`. There I setted up the IP addresses of the VMs in my GCP account and adjusted the variables.

### Second adjustment

The second adjustment was in `Example2/topology.sh.j2`. There, I made the mininet topology command a bit more precise by addidng the ablolute path and adding the internal_ip of onos_machine instead of the external. Additionally, before adding the switched, I am now checking if there is already some of them, so that in case I run the playbook agin, not to crush. Finally, I changed the agent `eno1` to `ens4` because that's what GCP uses.

### Third adjustment

The third adjustment was in `Example2/kubernetes.yml`. There I adjusted all the varables retirieved by the `inventory.ini` and more detailed to retrieve the internal IPs of the VMs. Additionally a made some changed to lines like: "Adding OVS Brinde" in order the playbook not to brake in case I run it a second time.

### Forth adjustment

The forth adjustment was in `Example2/deployment.yml.j2`. There I just adjusted the slow_machine IP variable

### Fifth adjustment

The fifth adjustment was in `host-sflow.yml.j2`. There I just adjusted the slow_machine IP variable

### Sixth adjsutment

The sixth adjustment was in `prometheus.yml.j2`. There I just adjusted the slow_machine IP variable

### Seventh adjustment

The seventh adjustment was in `mininet.yml`. There I adjusted the IP variables pointing to the VMs. I also deleted the installation of Python because it was throwing an error and isntalled JAva 17 instead of 11 becas sflow was throwing an incopatible arror with Java 11
