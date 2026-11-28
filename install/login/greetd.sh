# greetd shows the login screen (default/splash/greeter). Who it signs in, and
# whether boot signs them in by itself, is the ISO's to set through
# omarchy-system-login, since it knows whether the target is encrypted; until
# then it offers the first person's account.
omarchy-system-login --reset
systemctl enable greetd.service
