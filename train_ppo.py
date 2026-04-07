"""
Quick-start PPO training script — swap env_id for your Isaac Sim env.
Run: python3 train_ppo.py
"""
import gymnasium as gym
from stable_baselines3 import PPO, SAC
from stable_baselines3.common.callbacks import EvalCallback, CheckpointCallback
from stable_baselines3.common.monitor import Monitor
import torch, os

ENV_ID   = "Pendulum-v1"   # ← replace with your Isaac Sim / ROS2 gym env
ALGO     = "PPO"            # "PPO" or "SAC"
LOG_DIR  = "/workspace/logs"
SAVE_DIR = "/workspace/rl_training/checkpoints"
os.makedirs(LOG_DIR, exist_ok=True)
os.makedirs(SAVE_DIR, exist_ok=True)

env = Monitor(gym.make(ENV_ID))

callbacks = [
    EvalCallback(env, best_model_save_path=SAVE_DIR,
                 log_path=LOG_DIR, eval_freq=5000, deterministic=True),
    CheckpointCallback(save_freq=10000, save_path=SAVE_DIR, name_prefix=ALGO.lower()),
]

if ALGO == "PPO":
    model = PPO("MlpPolicy", env, verbose=1, tensorboard_log=LOG_DIR,
                device="cuda" if torch.cuda.is_available() else "cpu",
                n_steps=2048, batch_size=64, n_epochs=10,
                learning_rate=3e-4, gamma=0.99, gae_lambda=0.95,
                clip_range=0.2, ent_coef=0.01)
else:  # SAC
    model = SAC("MlpPolicy", env, verbose=1, tensorboard_log=LOG_DIR,
                device="cuda" if torch.cuda.is_available() else "cpu",
                learning_rate=3e-4, buffer_size=1_000_000,
                learning_starts=1000, batch_size=256, tau=0.005,
                gamma=0.99, train_freq=1, gradient_steps=1)

print(f"Training {ALGO} on {ENV_ID} | GPU: {torch.cuda.is_available()}")
model.learn(total_timesteps=500_000, callback=callbacks,
            tb_log_name=f"{ALGO}_{ENV_ID}")
model.save(f"{SAVE_DIR}/{ALGO}_final")
print("Done. Run: tensorboard --logdir /workspace/logs")
