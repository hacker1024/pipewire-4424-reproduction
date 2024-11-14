# PipeWire issue #4424 reproduction

This repository contains a VM designed to reproduce [pipewire#4424](https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/4424).

## Usage

1. Install [Nix](https://nixos.org/download) (not the OS - just the package manager, which can be installed on any Linux distribution).

2. Build the VM:

   ```console
   $ nix-build
   ```

   _To use the exact Nixpkgs revision available at the time of writing, add `-I nixpkgs=https://github.com/NixOS/nixpkgs/archive/4633a7c72337ea8fd23a4f2ba3972865e3ec685d.tar.gz`._

3. Launch the VM:

   ```console
   $ result/bin/run-nixos-vm
   ```

4. Open qpwgraph and Audacity (the password is `root`):

   ```console
   $ ssh -Y root@localhost -p 2022 'qpwgraph & audacity'
   ```

5. Start recording in Audacity.

6. Note that the recording is visibly and audibly choppy.

7. In qpwgraph, connect Audacity to the microphone directly rather than the echo
   cancellation module. Note that the recording is now fine.

8. Rebuild the VM with a `default.clock.rate` of at least 96 kHz, and note that
   there is no longer a problem.