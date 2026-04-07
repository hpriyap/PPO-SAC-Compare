# Base: CUDA 11.8 + Ubuntu 22.04 (Isaac Sim compatible)
FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# ── System deps ──────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    software-properties-common curl wget git vim \
    python3-pip python3-dev build-essential \
    libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ── ROS2 Humble ──────────────────────────────────────────────────────────────
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu jammy main" \
    > /etc/apt/sources.list.d/ros2.list && \
    apt-get update && apt-get install -y \
    ros-humble-ros-base \
    ros-humble-ament-cmake \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# ── Python RL stack ──────────────────────────────────────────────────────────
RUN pip3 install --no-cache-dir \
    torch==2.0.1+cu118 torchvision==0.15.2+cu118 \
    --extra-index-url https://download.pytorch.org/whl/cu118

RUN pip3 install --no-cache-dir \
    stable-baselines3==2.2.1 \
    gymnasium==0.29.1 \
    tensorboard==2.14.0 \
    numpy==1.24.4 \
    matplotlib \
    pandas \
    wandb \
    imageio \
    opencv-python-headless \
    rclpy

# ── Isaac Sim Python bindings (pip install, no full Omniverse needed) ─────────
RUN pip3 install --no-cache-dir \
    isaacsim-rl \
    omni-isaac-gym-envs 2>/dev/null || echo "Install via Omniverse Launcher separately if needed"

# ── rosdep init ──────────────────────────────────────────────────────────────
RUN rosdep init 2>/dev/null || true && rosdep update

# ── Workspace ────────────────────────────────────────────────────────────────
WORKDIR /workspace
RUN mkdir -p /workspace/ros2_ws/src /workspace/rl_training /workspace/logs

# ── Entrypoint ───────────────────────────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
