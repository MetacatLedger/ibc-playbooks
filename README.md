# ibc-playbooks
Playbook to spin up an IBC node

# How to run
Create a new linux VM with Ubuntu 18.04 (using an existing one should work, but I haven't tested that)

first add the go playbook with ansible-galaxy

```ansible-galaxy install andrewrothstein.go```

Then modify the host ip in the hosts file and run `./ibc-test`. This will install two cosmos chains on that server. 

After this run (password is 12345678)

```
sudo su - ibc1
# script to connect to two chains
./connect.sh 
# script to transfer funds
./xfer.sh
```

If you change the variables in the playbook, make sure to check the connect and xfer scritps as well

# Contact
This playbook was build by @tyrion70 of ChainLayer. For info reach out on Telegram
