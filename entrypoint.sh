#!/bin/bash
set -e
source /opt/ros/humble/setup.bash
if [ -f /workspace/ros2_ws/install/setup.bash ]; then
    source /workspace/ros2_ws/install/setup.bash
fi
export PYTHONPATH=/workspace:$PYTHONPATH
export DISPLAY=${DISPLAY:-:0}
exec "$@"
