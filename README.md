# QuestDB AMI Build Specification

This repository contains scripts and resources that can be used to build your
own AMI with QuestDB. The AMI is based on
[Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/) and generated using
[Packer](https://packer.io) from [HashiCorp](https://hashicorp.com).

## Prerequisites

In order to use this template, you will need:

- [Packer](https://www.packer.io/docs/install/index.html)
- AWS credentials

## Repository structure

```bash
└── src
    ├── assets
    │   ├── bashrc          # Used to set 'JAVA_HOME'
    │   ├── cloudwatch.json # Configuration which enables logs forwarding to AWS CloudWatch
    │   ├── logrotate.conf  # Configuration file for logrotate
    │   ├── rsyslog.conf    # Configuration file for rsyslog
    │   └── systemd.service # Service file to run QuestDB via systemd
    ├── config
    │   └── server.conf     # Configuration file for QuestDB
    ├── scripts
    │   └── per-boot.sh     # Script that runs every time the instance is started (CloudWatch)
    ├── build.bash          # Script that automates the installation of all the components on the AMI
    └── template.json       # Template file for Packer
```

## Build the AMI

1. Clone this repository:

```bash
git clone https://github.com/questdb/questdb-packer-ami.git
```

2. Navigate to `src` and run `packer`:

```bash
cd questdb-packer-ami/src
packer build template.json
```

That's it, you can now create a new EC2 instance using the AMI you just built.

## Usage

### Configuration

The AMI built using this template is very generic. You might want to change the
database configuration file:

```
src/config/server.conf
```

For all the properties and values that you can set, please check our
[documentation](https://questdb.io/docs/reference/configuration).

### Logs and AWS CloudWatch

This AMI uses [logrotate](https://linux.die.net/man/8/logrotate) to
automatically trim and archive logs generated by QuestDB. The AWS CloudWatch
[agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
is also preinstalled and already configured. If you want the logs to be
available on your CloudWatch dashboard, you need to:

1. Make sure you run your EC2 with an instance profile that has the
   `CloudWatchAgentServerPolicy`
   [IAM policy](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html)
2. Create the necessary CloudWatch resources: `/questdb-<instance-id>` (with
   leading slash) log group and `questdb-systemd-service.log` log stream
   (example of instance id: `i-0c1386329d00506a2`)

## Resources

Complete references are available in the
[Documentation](https://questdb.io/docs/introduction/).

Get started:

- [Docker](https://questdb.io/docs/get-started/docker/)
- [Binaries](https://questdb.io/docs/get-started/binaries/)
- [Homebrew](https://questdb.io/docs/get-started/homebrew/)

Develop:

- [Connect](https://questdb.io/docs/develop/connect/)
- [Insert data](https://questdb.io/docs/develop/insert-data/)
- [Query data](https://questdb.io/docs/develop/query-data/)
- [Authenticate](https://questdb.io/docs/develop/authenticate/)

Concepts:

- [SQL extensions](https://questdb.io/docs/concept/sql-extensions/)
- [Storage model](https://questdb.io/docs/concept/storage-model/)
- [Partitions](https://questdb.io/docs/concept/partitions/)
- [Designated timestamp](https://questdb.io/docs/concept/designated-timestamp/)

## Support / Contact

[Slack channel](https://slack.questdb.io)

## Roadmap

[Our roadmap is here](https://github.com/questdb/questdb/projects/3)

## Contribution

Feel free to contribute to the project by forking the repository and submitting
pull requests. Please make sure you have read our
[contributing guide](https://github.com/questdb/questdb-packer-ami/blob/master/CONTRIBUTING.md).
