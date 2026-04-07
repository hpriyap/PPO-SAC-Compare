# Docker 1 — PPO/SAC + ROS2 + Isaac Sim

## Quick start

### 1. Build
```bash
docker compose build
```

### 2. Run (interactive)
```bash
docker compose up -d
docker exec -it ppo_sac_trainer bash
```

### 3. Train PPO or SAC
```bash
# inside container
python3 /workspace/rl_training/train_ppo.py
```

### 4. Watch reward curve
```bash
tensorboard --logdir /workspace/logs --host 0.0.0.0
# open http://localhost:6006
```

## On AWS EC2 (g4dn.xlarge / g5.xlarge)

```bash
# Install NVIDIA container toolkit
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list \
  | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Then build and run as above
```

## Swap ENV_ID for your Isaac Sim environment
Edit `train_ppo.py` → `ENV_ID = "YourIsaacSimEnv-v0"`
