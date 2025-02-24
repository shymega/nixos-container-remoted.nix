# Syntax

```nix
  nix build --override-input nixos-cfg \
    $URL_TO_NIXOS_FLAKE \
    --override-input output-type \
    file+file:///<(printf %s "$YOUR_OUTPUT_FORMAT") \
    --override-input nixos-system \
    file+file:///<(printf %s "$YOUR NIXOSCONFIGURATIONS OUTPUT") \
    .#generate
```
