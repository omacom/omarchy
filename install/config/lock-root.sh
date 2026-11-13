# Leave root without a password. The installer's user is in wheel with full
# sudo, so a root password only adds an su path and a second copy of the user's
# password hash.
usermod -p '!' root
