# macOS-Setup

by [Scott Smitelli](mailto:scott@smitelli.com)

```bash
export HOSTNAME=macbeth
bash -c "$(curl -fsSL https://raw.githubusercontent.com/smitelli/macos-setup/HEAD/setup.sh)"
```

## Environment Variables

* `SET_HOSTNAME`: Defaults to the current hostname. Used to name the system on the network, and used as the base label name for the main disk.
* `CAPITALIZE_DISK`: Default `true`. If true, the first letter of the hostname is capitalized when used as a disk label name. Otherwise the hostname is used unchanged.

## License

MIT, except for the stuff under the `data/` directory.
