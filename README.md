# Headwind-MDM-Docker

![Build, scan & push](https://github.com/tommytran732/Headwind-MDM-Docker/actions/workflows/build.yml/badge.svg)

[Headwind MDM](https://h-mdm.com) is an open source mobile device management software for Android 
devices. 

### Notes
- Prebuilt images are available at `ghcr.io/tommytran732/headwind-mdm`.
- Don't trust random images: build yourself if you can.

### Features & usage
- Drop-in replacement for the [official image](https://github.com/h-mdm/hmdm-docker).
- Use the latest tomcat9 image.
- Daily rebuilds keeping the image up-to-date.
- Comes with various minor improvements - to be upstreamed at a later date.
- Comes with the [hardened memory allocator](https://github.com/GrapheneOS/hardened_malloc) built from the latest tag, protecting against some heap-based buffer overflows.