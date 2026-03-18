
Before using k9s and kubevious you need to cat the pieces and chmod +x.
They were created with `split -d -a 1 -n 4 kubevious kubevious.` and `split -d -a 1 -n 4 k9s k9s.`

```
crictl - Container Runtime Interface control
Requires setting a runtime endpoint (e.g., unix:///var/run/containerd/containerd.sock) to connect to the runtime. 
sudo crictl ps: List running containers.
sudo crictl pods: List pods.
sudo crictl images: List container images.
sudo crictl inspect <ID>: Get detailed information about a container, image, or pod.
sudo crictl logs <ID>: Fetch container logs.
sudo crictl pull <IMAGE>: Pull an image. 

kubevious - sanity checks, has cli / portable / web UI versions

k9s - terminal UI for k8s

rakkess / rbac-tool / rbac-lookup - help with RBAC
```
