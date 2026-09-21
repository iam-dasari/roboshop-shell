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
Next I have deployed the project using Shell Script and found below advantages:

### Advantages of Shell Script

| Advantage of Shell Script | What You Learn / Gain |
|---|---|
| **Automation** | Automates repetitive deployment commands instead of executing them manually |
| **Time Saving** | Deploys applications much faster than logging into each server and running commands one by one |
| **Consistency** | Executes the same steps and configuration every time |
| **Reduced Human Errors** | Minimizes mistakes such as typos, missing commands, or incorrect configuration |
| **Repeatability** | The same deployment can be executed repeatedly whenever required |
| **Standardized Deployment** | Creates a standard deployment procedure that every engineer can follow |
| **Easy to Maintain** | Deployment steps are stored in a script instead of depending on personal knowledge |
| **Parameterization** | Variables can be used for environments, versions, IPs, ports, artifact URLs, etc. |
| **Error Handling** | Can stop deployment when a command fails and perform validation checks |
| **Health Checks** | Can automatically verify whether the application and its dependencies are running |
| **Service Management** | Can automate `systemctl start`, `stop`, `restart`, `enable`, and `status` operations |
| **Dependency Handling** | Can install required packages and configure application dependencies automatically |
| **Configuration Management** | Can create users, directories, configuration files, permissions, and environment variables |
| **Multi-Server Deployment** | Can execute deployment steps across multiple servers |
| **Easy Integration with CI/CD** | Shell scripts can be executed from Jenkins, GitHub Actions, GitLab CI, etc. |
| **Version Control** | Scripts can be stored in Git, allowing change tracking, review, and history |
| **Documentation** | The script itself documents the deployment procedure |
| **Faster Recovery** | Deployment or recovery steps can be executed quickly using the same script |
| **Reduced Dependency on Engineers** | Deployment does not depend on someone remembering every manual command |
| **Foundation for Advanced Automation** | Provides a foundation for moving later to Ansible, Docker, Kubernetes, and GitOps |

### Comparison of Manual Vs Shell Script
| Manual Deployment | Shell Script |
|---|---|
| SSH into server | Script can automate execution |
| Run commands one by one | Commands execute automatically |
| Time-consuming | Faster |
| High chance of human error | Fewer manual errors |
| Difficult to repeat | Easily repeatable |
| Different engineers may follow different steps | Standardized process |
| Difficult to execute on many servers | Can automate multiple servers |
| No built-in documentation | Script documents the process |
| Hard to integrate with CI/CD | Easy to integrate with CI/CD |
| Difficult to track changes | Store scripts in Git |