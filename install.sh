sudo curl -o /etc/systemd/system/shutdown-timer.service -L -O https://raw.githubusercontent.com/joshbav/systemdtimer/master/shutdown-timer.service

sudo curl -o /etc/systemd/system/shutdown-timer.timer -L -O https://raw.githubusercontent.com/joshbav/systemdtimer/master/shutdown-timer.timer

sudo systemctl daemon-reload
sudo systemctl enable shutdown-timer.timer
sudo systemctl start shutdown-timer.timer
sudo systemctl status shutdown-timer.timer

