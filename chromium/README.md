Please check our Developer Article [Kiosk Mode Browser with Torizon OS] for more details.

[Kiosk Mode Browser with Torizon OS]: https://developer.toradex.com/knowledge-base/kiosk-mode-browser-with-torizon-core

And, for the impatient, you can see below some details on how to get this sample up and running in a Torizon compatible module.

# Technical Details

Torizon provides support for Chromium and Cog.

Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all users to experience the web. In the Chromium container, Chromium uses Ozone/Wayland as a rendering backend and it is not optimized for applications that require hardware acceleration and the GPU.

## Preparing the environment

You should start the wayland server container first (torizon/weston) and the container providing the local UI, if required.
Learn how to [start a Wayland server container on Debian Containers] for Torizon.

[start a Wayland server container on Debian Containers]: https://developer.toradex.com/knowledge-base/debian-container-for-torizon#Debian_With_Weston_Wayland_Compositor

## Running Chromium

The Chromium container needs visibility to some host resources (for accessing the accelerated graphical environment, buffer sharing, and inter-process communication), and the URL of the web UI as a command-line parameter. It also recognizes optional command-line flags (explained ahead).
You can run the following command to start the Chromium container on iMX6 devices:

```bash
$> docker run -eMACHINE -d --rm --name=chromium \
    -v /tmp:/tmp -v /dev/dri:/dev/dri \
    -v /var/run/dbus:/var/run/dbus --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    torizon/chromium:$CT_TAG_CHROMIUM
```

You can run the following command to start the Chromium container on iMX8 devices:

```bash
$> docker run -eMACHINE -d --rm --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    torizon/chromium:$CT_TAG_CHROMIUM
```

### Optional command line flags

It's possibile to start Chromium in less-secure ways (secure from the point of view of user being able to run other graphical apps etc.) using command line switches.
- --window-mode : runs the browser inside a maximized window without navigation bar
- --browser-mode : runs the browser in a standard window with navigation bars and all user menus enabled
- --virtual-keyboard : enables a virtual keyboard for text entry

Additionally, it is possible to pass flag or options directly to Chromium binary when invoking Chromium container, for example:

```bash
$> docker run -eMACHINE -d --rm --name=chromium \
    -v /tmp:/tmp -v /dev/dri:/dev/dri \
    -v /var/run/dbus:/var/run/dbus --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb  \
    torizon/chromium:$CT_TAG_CHROMIUM --disable-pinch \
    --virtual-keyboard --user-data-dir=/tmp
```

#### GPU Hardware Acceleration flags

By default Chromium runs with GPU hardware acceleration for all devices except iMX7 and iMX6ULL. Following flags affect this feature:

- --disable-gpu-compositing : Disables GPU compositing only. May increase performance for some applications at the cost of increased CPU utilization. Reduces the performance of WebGL applications.
- --disable-gpu : Disables GPU hardware acceleration completely.
