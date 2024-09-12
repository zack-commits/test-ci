FROM python:3.12.5-bookworm

RUN pip install --no-cache-dir jinja2 numpy
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
#RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN apt update -y && apt install -y git cargo cmake g++ gcc python3-dev musl-dev make nasm
RUN git clone https://github.com/zack-commits/ComfyUI.git ComfyUI

# 安装 ComfyUI 依赖
# RUN pip install --no-cache-dir -r /ComfyUI/requirements.txt && pip install --upgrade gguf
RUN pip install --no-cache-dir -r /ComfyUI/requirements.txt
# 安装 ComfyUI 插件
RUN git clone https://github.com/crystian/ComfyUI-Manager.git /ComfyUI/custom_nodes/ComfyUI-Manager && \
    git clone https://github.com/melMass/comfy_mtb.git /ComfyUI/custom_nodes/comfy_mtb && \
    git clone https://github.com/rgthree/rgthree-comfy.git /ComfyUI/custom_nodes/rgthree-comfy && \
    git clone https://github.com/AIGODLIKE/AIGODLIKE-COMFYUI-TRANSLATION.git /ComfyUI/custom_nodes/AIGODLIKE-COMFYUI-TRANSLATION && \
    git clone https://github.com/cubiq/ComfyUI_essentials.git /ComfyUI/custom_nodes/ComfyUI_essentials && \
    git clone https://github.com/crystian/ComfyUI-Crystools.git /ComfyUI/custom_nodes/ComfyUI-Crystools && \
    git clone https://github.com/ty0x2333/ComfyUI-Dev-Utils.git /ComfyUI/custom_nodes/ComfyUI-Dev-Utils && \
    git clone https://github.com/city96/ComfyUI-GGUF.git /ComfyUI/custom_nodes/ComfyUI-GGUF && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /ComfyUI/custom_nodes/ComfyUI-Custom-Scripts 
# 清理系统不再需要的构建依赖  暂时保留git，因为后续需要更新代码
RUN apt remove -y cargo cmake g++ gcc python3-dev musl-dev make nasm && apt autoremove -y && apt clean -y

RUN chmod +x /ComfyUI/main.py

ENTRYPOINT ["python", "/ComfyUI/main.py", "--listen"]