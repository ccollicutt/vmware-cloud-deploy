# vmware-cloud-deploy


### Dependencies:

genisoimage - Widely available, install from your distros package manager  
ovftool - VMWare OVFTool - Get this from VMWare  
cot - Common OVF Tool - Get this from https://github.com/glennmatthews/cot

### What it does:

Allows you to use command line to deploy images using cloudinit to VMWare ESXi

### How to use it
1. Download a cloudinit OVA (such as Ubuntu cloud image)
1. Create your cloudinit meta-data and user-data files
1. Run the tool which builds an ISO, with your data, attaches it to the VM and deploys it to the ESXi server. 
