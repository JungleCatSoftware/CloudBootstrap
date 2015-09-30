# CloudBootstrap
Bootstrapping scripts to quickly configure cloud servers

## How to Use
This repository can be included as a Git submodule or packaged with your application, or downloaded as a tarball from GitHub. Both methods are detailed below.

### Submodule
If included as a submodule or packaged with an application, the `scripts/run` script can be called directly. The configuration script location must be set in the `ConfigFile` environment variable (defaults to "github:JungleCatSoftware/CloudConfigs/example/config@master").

### Tarball Download
The config scripts can be downloaded and launched by downloading and executing the `bootstrap.sh` script. As with the Submodule method, the `ConfigFile` environment variable will need to be set (defaults to "github:JungleCatSoftware/CloudConfigs/example/config@master"). The following is an example script that can be used or included into into your boot configs (such as AWS's Instance UserData):
```bash
#!/bin/bash
export ConfigFile='github:JungleCatSoftware/CloudConfigs/example/config@master'
curl -L https://raw.githubusercontent.com/JungleCatSoftware/CloudBootstrap/master/bootstrap.sh | /bin/bash
```

## File Locators
The CloudBootstrap scripts make use of various file locators, which are shorthand for various types of files, such as modules from the Puppet Forge or GitHub. The following are all supported locator prefixes since version 0.0.1:
 - forge:
 - github:
 - http://
 - https://

### Puppet Forge Locator
The Puppet Forge locator refers to a Puppet Module on the public Puppet Forge. This locator is only valid in the `CONFIG_MODULES` variable when using the "puppet" `CONFIG_MANAGER` and cannot be used in any other context. It follows the form "forge:USER-MODULE(@VERSION)" where USER is the name of the account that uploaded the module, MODULE is the name of the module, and VERSION is an optional version to fetch (defaults to the latest). The following are all valid examples:
 - "forge:puppetlabs-stdlib"
 - "forge:jfryman-nginx@0.2.6"

### GitHub Locator
The GitHub locator reference a GitHub repository or a specific file within a repository, optionally at a specific revision, tag, or commit. A GitHub locator follows the form "github:USER/REPO(/path/to/file)(@VERSION)" where USER is the account owning the repository, REPO is the name of the repository, followed by a (optional) path to a specific file in the repository, and VERSION is an optional version (commit, tag, etc) amd defaults to "master" if not provided. If no path to a file is provided, the whole repository will be downloaded as a tarball, otherwise, the indicated file will be downloaded only. The following are valid GitHub locators:
 - "github:puppetlabs/puppetlabs-firewall@1.6.x"
 - "github:camptocamp/puppet-openssl"
 - "github:JungleCatSoftware/CloudConfigs/example/config"
 - "github:JungleCatSoftware/CloudBootstrap/README.md@0.0.1"
