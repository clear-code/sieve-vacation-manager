# users-cookbook

Create users for virtual mail account.

## Supported Platforms

CentOS 6.5, CentOS 7.0, Debian

## Attributes

None

## Usage

### users::default

Include `users` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[users::default]"
  ]
}
```

## License and Authors

Author:: Kenji Okimoto <okimoto@clear-code.com>
