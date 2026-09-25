# Changelog

All notable changes to **HyperOS Ultimate Edition** will be documented in this file.

The project follows a device- and kernel-focused development model for:

* Redmi Note 10 Pro — `sweet`
* Redmi Note 10 Pro Max — `sweetin`
* Primary kernel — **SuperRyzeNS Kernel**

---

## [Unreleased]

Development version.

### Planned

* Core module implementation
* SuperRyzeNS kernel/environment detection
* Device detection for `sweet` and `sweetin`
* Adaptive thermal management
* Gaming thermal profile
* Battery optimization layer
* Smoothness and responsiveness tuning
* WebUI foundation
* Logging and diagnostics
* Safe restoration of temporary changes

---

## Development Principles

HyperOS Ultimate Edition development may follow relevant changes introduced by the SuperRyzeNS Kernel.

Kernel changelogs may be reviewed for changes involving:

* CPU frequency management
* Thermal management
* Scheduler functionality
* I/O
* Memory management
* Network behavior
* Power management
* Kernel interfaces

A kernel feature will **not automatically be duplicated inside the module**.

Each change will be evaluated to determine whether the module should:

1. Use the kernel feature directly
2. Add module-side support
3. Adapt an existing configuration
4. Leave the feature entirely to the kernel

This approach is intended to prevent conflicting or redundant tweaks.

---

## Versioning

HyperOS Ultimate Edition follows a simple versioning scheme:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.0.0
1.1.0
1.1.1
```

### MAJOR

Large architectural or behavioral changes.

### MINOR

New features or significant improvements.

### PATCH

Bug fixes, compatibility fixes and small adjustments.

---

## Release Notes

Detailed release notes will be added with each public release.

Each release should document:

* Supported SuperRyzeNS Kernel versions
* Supported Android/ROM environment
* New features
* Changed behavior
* Removed features
* Bug fixes
* Known issues
* Compatibility notes

---

## Compatibility Policy

The primary development target remains:

```text
Redmi Note 10 Pro / Pro Max
sweet / sweetin
SuperRyzeNS Kernel
```

Other kernels are not guaranteed to be compatible.

If a SuperRyzeNS Kernel update changes a required interface or behavior, a corresponding HyperOS Ultimate Edition update may be required.

---

## Disclaimer

Changelog entries describe project changes and development status. They do not guarantee a specific performance, temperature or battery-life improvement on every device.
