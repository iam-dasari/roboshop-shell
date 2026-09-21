I have deployed the application manually and found below advantages:

### Advantages of Manual Deployment

| Advantage | What you learn |
|---|---|
| Understand every component | What each microservice actually needs |
| Understand dependencies | Catalogue → MongoDB, Cart → Redis, Payment → RabbitMQ/MySQL, etc. |
| Linux administration | Packages, users, permissions, systemd, logs |
| Networking | DNS, ports, Security Groups, private IPs, connectivity |
| Troubleshooting | What happens when a dependency is unavailable |
| Configuration understanding | Where application configuration lives |
| Service management | `systemctl`, restart, enable, status |
| Database understanding | Initialization, schemas, users, connectivity |
| DNS understanding | Route 53 records and name resolution |
| Security understanding | Which ports should be open between tiers |
| Architecture understanding | How the complete application actually works |

### Manual deployment is particularly good for troubleshooting
With manual deployment you can investigate layer by layer:
```
                CART FAILURE
                     |
        +------------+------------+
        |            |            |
      Linux        Network      App
        |            |            |
    systemd       DNS/SG       NodeJS
        |            |            |
      logs          Redis      config
```
For example:
```
- systemctl status cart
- journalctl -u cart -n 100
- nslookup redis.dasaridevops.online
- nc -vz redis.dasaridevops.online 6379
- curl localhost:8080
``` 
### Manual deployment also teaches networking
This is extremely useful for your current AWS learning.
```
DNS?
 ↓
Private/Public IP?
 ↓
Route?
 ↓
Security Group?
 ↓
Redis bind address?
 ↓
Redis running?
 ↓
Port 6379?
```
### Manual deployment also exposes configuration problems
For example, suppose Cart contains: REDIS_HOST=redis.dasaridevops.online
and DNS doesn't resolve. You immediately understand:
```
Application configuration
        ↓
DNS
        ↓
Route 53
        ↓
VPC DNS
```
