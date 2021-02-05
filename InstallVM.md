## Make a virtual machine with VMware

---

One main problem is that your keyboard is qwerty whereas it's an azerty.  

If you want to change that in , you to do updates, but you need an internet connexion.  

Also you need to install open-vm-tools, open-vm-desktop, to copy paste stuffs between host and guest, and have a full screen for the linux guest.


1.How to setup Internet Connection for Virtual Machines in VMWare

Check this video to install the network correctly.  

> https://www.youtube.com/watch?v=H2j3nyl4muQ&ab_channel=IT%26Software  

You then look into Proxy.
You chose manual.

You will use proxywsg.crlc.intra:3128

Now you should access internet by browser but you still can't update apt packages.

2.How to setup Internet Connection for APT packages updates

https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-set-the-proxy-for-apt-for-ubuntu-18-04/

_**Proxy**_ :

```shell
	sudo touch /etc/apt/apt.conf.d/proxy.conf
	sudo nano /etc/apt/apt.conf.d/proxy.conf
}
```
Acquire {
HTTP::proxy "http://proxywsg.crlc.intra:3128";
HTTPS::proxy "http://proxywsg.crlc.intra:3128";
}

Note : When your are home. In windows, disable proxy. Do the same in linux (in Network)
But for packages you need to change /etc/apt/apt.conf.d/proxy.conf

>Acquire {
  HTTP::proxy ""false";";
  HTTPS::proxy "false";";
}


2.Keyboard Configuration

You go region and langage and you chose French (azerty) . Reboot.
Change at the top right the icon of keyboard. English is the one by default. Select french.

4. Install open-vm-tools

In order to have full screen to copy past stuffs.

```shell
	sudo apt update
	nano apt upgrade
	sudo apt install open-vm-tools
	sudo apt install open-vm-tools-desktop
}
```

3. Connect to server

CONNECT : 
ssh villemin@compute0.crlc.intra
Mount SERVER :
ssftp villemin@compute0.crlc.intra

sudo apt-get install sshfs
https://www.tecmint.com/sshfs-mount-remote-linux-filesystem-directory-using-ssh/

You will need to share file between windows and ubuntu.

/usr/bin/vmhgfs-fuse .host:/ /home/user1/shares -o subtype=vmhgfs-fuse,allow_other	


Download R-studio

https://rstudio.com/products/rstudio/download/#download

sudo apt -y install r-base
sudo apt install gdebi-core rstudio-1.4.1103-amd64.deb

Download Conda

https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html

bash Anaconda3-2020.11-Linux-x86_64.sh

# Install Eclipse
# Prob with proxy
https://mkyong.com/web-development/how-to-configure-proxy-settings-in-eclipse/

sudo apt install default-jre
sudo snap set system proxy.http="http://proxywsg.crlc.intra:3128"
sudo snap set system proxy.https="http://proxywsg.crlc.intra:3128"
# You need to do that in order TO DO THAT :
sudo snap install --classic eclipse

Windows NetWork Connection > Select Manuel and set proxy for http and https (not SOCKS)
Check for  Updates
http://www.pydev.org/updates

Click and drag to recognise Eclipse
https://marketplace.eclipse.org/content/statet-r

# Prob with proxy when installing packages
Sys.getenv(https_proxy) is empty
Sys.setenv(https_proxy="http://proxywsg.crlc.intra:3128")

Modify some stuffs to use 4.0 R version not 3.4.4
sudo nano /etc/apt/sources.list
ADD at the end deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/
sudo apt update
sudo apt-get install r-base


if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install()

Install a package :  
> BiocManager::install(c("edgeR"))

https://askubuntu.com/questions/29284/how-do-i-mount-shared-folders-in-ubuntu-using-vmware-tools
sudo vmhgfs-fuse .host:/SharedData /mnt/hgfs/ -o allow_other -o uid=1000

vmware-hgfsclient
my-shared-folder is SharedData
$ sudo vmhgfs-fuse .host:/SharedData /mnt/hgfs/ -o allow_other -o uid=1000
# Close shell and reopen
If you want to set up on startup
If you want them mounted on startup, update /etc/fstab with the following:
# Use shared folders between VMWare guest and host
.host:/SharedData    /mnt/hgfs/    fuse.vmhgfs-fuse    defaults,allow_other,uid=1000     0    0

Connect remote serveur

ssh villemin@compute0 

Mount remote serveur

You can create a rsa key.  
Add it to the remote server in autorized key and then connect without password confirmation each time.
NB : Eric the IT guy dit it for me but you can do it by yourself on bionfio0.


/home/jp/Desktop/serveur
sshfs villemin@compute0:/data/ /home/jp/Desktop/serveur
sudo umout /home/jp/Desktop/serveur/

Auto-Mount (TODO)
villemin@compute0:/data/ /home/jp/Desktop/serveur fuse.sshfs defaults,_netdev,IdentityFile=/home/jp/.ssh/id_rsa,allow_other   0   0
sudo mount -av (will mount every thing and ask for password)


# Proxy for wget
nano /etc/wgetrc
https_proxy = http://proxywsg.crlc.intra:3128 
http_proxy = http://proxywsg.crlc.intra:3128
#ftp_proxy = http://proxywsg.crlc.intra:3128

# Chrome under Linux with proxy (Dead end)
sudo -H nautilus
--proxy-server="http://proxywsg.crlc.intra:3128"

See markdown if chrome doesn't work (Firefox has a bug to visualise md from file)
Use Sublime Text
Configure proxy
Preferences >> Package Settings >> Package Control >> Settings – User: // Proxy Settings "http_proxy": "your. proxy
Select Preferences , Package Control : Install Pacakge , select MarkdownPreview 
