# Multi-Gateway Ignition Stack

This Docker Compose solution brings up three independent Ignition gateways (two Ignition and one Ignition Edge) in a Hub and Spoke configuration.  All gateways will be connected in the Gateway network automatically on first-launch.

## Quick Start

See the sections later in this guide for more details on these commands, but this should get you running quickly if you're impatient 😝:

```bash
$ git clone https://github.com/thirdgen88/ignition-examples.git ignition-examples
Cloning into 'ignition-examples'..
$ cd ignition-examples/ignition-gwnetwork         # Change to the Gateway Network Example Folder
$ docker-compose up -d && docker-compose logs -f  # Start the stack in detached mode and start to follow the logs (break with Ctrl-C)
...
```

## Container Customization

Take a look at the README's for the [kcollins/ignition](http://hub.docker.com/r/kcollins/ignition) Docker images for information on how to customize the containers' gateway network configurations (and more).

## Other

_Note_:  When using multiple gateways with this configuration is that your browser will only authenticate to one at a time.  At this time, a workaround for this is to use an alternate browser for interacting with the other gateway.  For example, use Chrome to connect to the `hub` gateway webpage, and use Firefox to connect to the `spokeX` gateways.  Alternatively, you can edit your systems `hosts` file to add aliases to `127.0.0.1` (localhost) for the names you want to use.  Then, using those names in your browser (still with the appropriate port), it will not prompt you for authentication when you switch between tabs of different containers.

Alternatively, you can use [Traefik](https://docs.traefik.io) as a reverse proxy.  Uncomment the `COMPOSE_FILES` and `COMPOSE_PATH_SEPARATOR` definitions in `.env` to enable.  From there, you can reach http://hub.localtest.me, http://spoke1.localtest.me, etc once you've brought up the stack.