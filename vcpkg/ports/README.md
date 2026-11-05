# Overlay ports

Custom or patched vcpkg ports live here, one folder per port (`<port>/portfile.cmake`, `<port>/vcpkg.json`).
They take precedence over the default registry. Use this for:

- private/third-party libraries that are not in the vcpkg catalog,
- temporary patches of an upstream port.

See <https://learn.microsoft.com/vcpkg/concepts/overlay-ports>.
