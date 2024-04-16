## Override helm chart default values


### Add dih helm repo
```helm repo add <repo-name> <repo-url>```

Example:

```helm repo add dih https://resources.gigaspaces.com/helm-charts-dih```

Validate by:
``` helm repo list```


### Display helm installations

```helm list -n <namespace>```

To get list of all namespace:

```helm list -Aa```

### Default dih installation 

```helm instal <name> <repo-name>/<chart> --version <version> -n <namespace>```

Exmaple:

```helm install dih dih/dih --version 16.4.2 -n dih```


### Override helm chart via cli

We will override only the changes.

For example, to override the disable global security (enabled by default):

```helm install dih dih/dih --version 16.4.2 --set=global.security.enabled=false```

### Override helm chart via yaml file

```helm install dih dih/dih --version 16.4.2 -f /path/to/values.yaml```

while values.yaml contains:

```
global:
  security:
    enabled: false
```


### To override repo URLs and to disable unused components

Please review the attached file:

```override_repo.yaml```