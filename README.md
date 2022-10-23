# macOS-Setup

by [Scott Smitelli](mailto:scott@smitelli.com)

```bash
export SET_HOSTNAME=macbeth
bash -c "$(curl -fsSL https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/setup.sh)"
```

## Environment Variables

* `SET_HOSTNAME`: Defaults to the current hostname. Used to name the system on the network, and used as the base label name for the root disk.
* `CAPITALIZE_DISK`: Default `true` if the existing root disk name looks to be capitalized already, otherwise `false`. If true, the first letter of the hostname is capitalized for use as the disk's label name. Otherwise the hostname is used unchanged.
* `INCLUDE_WORKTOOLS`: Defaults to `false`. If true, installs work tools as well.

## License

MIT, except for the stuff under the `data/` directory.
