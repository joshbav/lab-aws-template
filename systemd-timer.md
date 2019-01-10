This is a systemd timer and unit to shut down a node after 6 hours. It's for lab use.
Has only been tested on centos7.   

The purpose is to avoid accidentally leaving the node running in a cloud provider and running up a big bill. 

A 20 min warning will be provided at the 6 hour point.
Do sudo shutdown -c to cancel the scheduled shutdown within the 20 minutes.
Do sudo systemctl stop shutdown-timer.timer  to stop the timer, but remember to restart it. A reboot will restart it.  

To install it:  
sudo curl -o /tmp/install.sh -L -O https://raw.githubusercontent.com/joshbav/systemdtimer/master/install.sh && bash /tmp/install.sh  
  

