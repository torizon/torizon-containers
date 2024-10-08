# Debian Base Container Documentation

## Switch from Neofetch to Fastfetch

Major 4 containers were released with neofetch installed, but we followed
Torizon's decision to move to fastfetch since neofetch has been archived by its
upstream developer.

In order to not disrupt the behaviour of our containers, we are providing a
symlink in `/usr/local/bin/neofetch` to `/usr/bin/fastfetch`. This way, one can
continue to use neofetch in scripts or CLI but have fastfetch working behind
the curtains. If one really wants neofetch, simply removing the symlink
and installing Debian's version will be enough.
