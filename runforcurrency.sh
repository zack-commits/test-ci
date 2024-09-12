#!/bin/bash

# 路径前缀变量
BASE_PATH="/home/ec2-user"

# 创建文件夹结构
echo "Creating directory structure..."
mkdir -p $BASE_PATH/workspace/output
mkdir -p $BASE_PATH/workspace/models/{clip,unet,loras,vae}


# 在 workspace 下创建 nginx.conf
echo "Creating nginx.conf in workspace..."
cat <<EOL > $BASE_PATH/workspace/nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream backend_flux_txt2img {
        server 127.0.0.1:8188;
        server 127.0.0.1:8189;
    }

    upstream backend_flux_img2img {
        server 127.0.0.1:8188;
        server 127.0.0.1:8189;
    }

    server {
        listen 80;

        location /flux_txt2img {
            proxy_pass http://backend_flux_txt2img;
            proxy_connect_timeout 86400;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
        }

        location /flux_img2img {
            proxy_pass http://backend_flux_img2img;
            proxy_connect_timeout 86400;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
        }
    }
}
EOL

# 在 workspace 下创建 Dockerfile
echo "Creating Dockerfile in workspace..."
cat <<EOL > $BASE_PATH/workspace/Dockerfile
FROM python:3.12.5-bookworm

RUN pip install --no-cache-dir jinja2 numpy
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
#RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN apt update -y && apt install -y git cargo cmake g++ gcc python3-dev musl-dev make nasm
RUN git clone https://github.com/zack-commits/ComfyUI.git /ComfyUI
# 安装 ComfyUI 依赖
# RUN pip install --no-cache-dir -r /ComfyUI/requirements.txt && pip install --upgrade gguf
RUN pip install --no-cache-dir -r /ComfyUI/requirements.txt
# 安装 ComfyUI 插件
RUN git clone https://github.com/crystian/ComfyUI-Manager.git /ComfyUI/custom_nodes/ComfyUI-Manager && \
    git clone https://github.com/melMass/comfy_mtb.git /ComfyUI/custom_nodes/comfy_mtb && \
    git clone https://github.com/rgthree/rgthree-comfy.git /ComfyUI/custom_nodes/rgthree-comfy && \
    git clone https://github.com/AIGODLIKE/AIGODLIKE-COMFYUI-TRANSLATION.git /ComfyUI/custom_nodes/AIGODLIKE-COMFYUI-TRANSLATION && \
    git clone https://github.com/cubiq/ComfyUI_essentials.git /ComfyUI/custom_nodes/ComfyUI_essentials && \
    git clone https://github.com/city96/ComfyUI-GGUF.git /ComfyUI/custom_nodes/ComfyUI-GGUF && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /ComfyUI/custom_nodes/ComfyUI-Custom-Scripts 
# 清理系统不再需要的构建依赖  暂时保留git，因为后续需要更新代码
RUN apt remove -y git cargo cmake g++ gcc python3-dev musl-dev make nasm && apt autoremove -y && apt clean -y

RUN chmod +x /ComfyUI/main.py

ENTRYPOINT ["python", "/ComfyUI/main.py", "--listen"]
EOL


# 在 workspace 下创建 docker-compose.yaml
echo "Creating docker-compose.yaml in workspace..."
cat <<EOL > $BASE_PATH/workspace/docker-compose.yaml
services:
  comfy-ui:
    build:
      context: ./
      dockerfile: ./Dockerfile
    restart: unless-stopped
    volumes:
      - ./models/checkpoints:/ComfyUI/models/checkpoints
      - ./models/vae:/ComfyUI/models/vae
      - ./models/unet:/ComfyUI/models/unet
      - ./models/clip:/ComfyUI/models/clip
      - ./models/loras:/ComfyUI/models/loras
      - ./output:/ComfyUI/output
      - ./v2_FLUX_D_model_Q8_clip_Q8.json:/repository/v2_FLUX_D_model_Q8_clip_Q8.json
    ports:
      - 8188:8188
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: curl --fail http://localhost:8188/ || exit
      interval: 40s
      timeout: 30s
      retries: 3
      start_period: 60s
  comfy-ui2:
    build:
      context: ./
      dockerfile: ./2.Dockerfile
    restart: unless-stopped
    volumes:
      - ./models/checkpoints:/ComfyUI/models/checkpoints
      - ./models/vae:/ComfyUI/models/vae
      - ./models/unet:/ComfyUI/models/unet
      - ./models/clip:/ComfyUI/models/clip
      - ./models/loras:/ComfyUI/models/loras
      - ./output:/ComfyUI/output
      - ./v2_FLUX_D_model_Q8_clip_Q8.json:/repository/v2_FLUX_D_model_Q8_clip_Q8.json
    ports:
      - 8189:8188
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: curl --fail http://localhost:8189/ || exit
      interval: 40s
      timeout: 30s
      retries: 3
      start_period: 60s
  nginx:
    image: nginx:latest
    container_name: comfyui_load_balancer
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf  # 挂载本地的nginx.conf到容器中
    ports:
      - "80:80"  # 映射80端口到主机
    restart: always
EOL
# 下载文件
echo "Downloading files..."
curl -L -o $BASE_PATH/workspace/models/unet/flux1-dev-Q8_0.gguf "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q8_0.gguf?download=true"
curl -L -o $BASE_PATH/workspace/models/clip/clip_l.safetensors "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/clip/t5xxl_fp16.safetensors "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/clip/clip_l.t5xxl_fp8_e4m3fn.safetensors "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/loras/Hyper-FLUX.1-dev-8steps-lora_rank1.safetensors "https://huggingface.co/bdsqlsz/Hyper-Flux1-dev/resolve/main/Hyper-FLUX.1-dev-8steps-lora_rank1.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/loras/Hyper-FLUX.1-dev-8steps-lora.safetensors  "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-FLUX.1-dev-8steps-lora.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/loras/Hyper-FLUX.1-dev-16steps-lora.safetensors  "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-FLUX.1-dev-16steps-lora.safetensors?download=true"
curl -L -o $BASE_PATH/workspace/models/vae/ae.sft "https://liblibai-online.liblib.cloud/models/comfyui/afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38.sft?auth_key=1726022125-9b83542f2f6d488e91ba4067ff9e7bc8-0-6c637b8133219176d4472ba69de497c5&attname=F.1%20模型下载版-黑暗森林工作室_FLUX.1-vae.sft"

# 使用 docker-compose 构建和启动服务
echo "Building and starting Docker Compose services..."
docker-compose up -d -f $BASE_PATH/workspace/docker-compose.yaml

# 运行 ngrok 容器
echo "Starting ngrok container..."
docker run --net=host -itd -e NGROK_AUTHTOKEN=2lraehFb0cGX8ELOdDLtglwC3vr_2EHrQ3pgxD4cxZv6pxeU5 ngrok/ngrok:latest http 8188

echo "All done!"
