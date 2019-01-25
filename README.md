# vmware-cloud-deploy

Deploy OVA images using cloudinit to a VMWare ESXi instance. This is purely a script tying together other components, but I had to do a bit of digging and trial and error to get this working so here it is for everyone.  

Tested with:
- VMWare ESXi 6.7.0
- VMware ovftool 4.3.0 (build-10104578)
- genisoimage 1.1.11 (Linux)
- Common OVF Tool (COT), version 2.1.0

Image:
- bionic-server-cloudimg-amd64.ova
    

### Dependencies:

genisoimage - Widely available, install from your distros package manager  
ovftool - VMWare OVFTool - Get this from VMWare  
cot - Common OVF Tool - Get this from https://github.com/glennmatthews/cot

### How to use it
1. Download a cloudinit OVA (such as Ubuntu cloud image)
1. Create your cloudinit meta-data and user-data files
1. Run the tool which builds an ISO, with your data, attaches it to the VM and deploys it to the ESXi server. 
