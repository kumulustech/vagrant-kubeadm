# A Vagrantfile to deploy a multi-node ansible with kubeadm

Vagrantfile supports only ubuntu and virtualbox at the moment
it's based on the Vagrantfile from the kubernetes git repository.

You can adjust the number of client nodes by changing the NUM_NODES
environment variable.

To launch the environment, just do:

  vagrant up

Once the system has launched, you should be able to verify
the kubernetes environment by logging into the master node

  vagrant ssh master
  kubectl get nodes
