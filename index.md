### 接下来可能要接触的项目
1. cicd 相关的项目
2. infra相关的项目
3. gpu的项目
4. 翻译相关的项目  主要是kafka队列堵塞的问题（一个游戏一个队列）
5. ebpf的项目

### 常用网址
https://a.g123.jp/general/tasks/my-tasks/inprogress
https://mail.google.com/mail/u/0/#inbox

#### aws
https://ctw-inc.awsapps.com/start/#/?tab=accounts
#### AWS配置速查
https://instances.vantage.sh/aws/ec2/g5.xlarge

### 项目相关
#### g123-jp  Repository Overview
https://github.com/G123-jp?q=&type=all&language=go&sort=

### 服务器相关
#### 镜像地址
https://argo.g123.io/applications?showFavorites=false&proj=&sync=&autoSync=&health=&namespace=&cluster=&labels=&search=gateway

### 文件相关
#### team overview
https://docs.google.com/document/d/1m8lg6vbeKaX2TbS7eP1VPqL14uu_lbX9k-07e3HmPhc/edit?pli=1#heading=h.h5vv5wycndd1
#### sprint
https://docs.google.com/document/d/1QvbtVJOSTK1cxGwwgccnn_tiQ36wFo62YFEF4G0qf7o/edit#heading=h.vab3er26gven
#### openvpn
https://docs.google.com/document/d/15pQ1COMdknzgPrFZyeT1P7x-aMnRSqrHMASrTwKSrBo/edit#heading=h.r9mknnaaiqfj
#### google drive
https://drive.google.com/drive/folders/1O-XnPMvcWg7EPLyx9bRZ9A3UdiXCk6CI




### 账号相关 
#### wifi
CTW SH
Bac0nYasa1

#### gmail
zhang.j1@ctw.inc
密码
cedkuh-vipru8-deSsik
#### github 二重认证恢复密钥
db832-45f64
33023-b9db8
cd2c8-56b1e
2c405-45983
6c27e-2f251
16181-fc9d4
af45b-1a84a
c906f-804af
22c38-274d0
95d47-73d0f
9e5e1-dc767
97295-ce694
ccb2c-d8a00
0671b-d9049
e3af3-104e5
cc552-081aa






### 测试comfyui相关

#### --fast参数测试
第一次3.89s/it   k采样 38.95  总用时  44.72
第二次3.94s/it   k采样 39.42  总用时  45.14
第二次3.94s/it   k采样 39.40  总用时  45.06

#### 不加--fast参数测试
第一次4.01s/it   k采样 40.18  总用时  46.74
第二次3.93s/it   k采样 39.30  总用时  44.98
第二次3.89s/it   k采样 38.88  总用时  44.62



### Comfyui相关
#### 代码地址
https://github.com/ComfyUI/ComfyUI
#### 插件
dev-utils
https://github.com/crystian/ComfyUI-Manager.git
https://github.com/crystian/ComfyUI-Crystools.git
#### gguf node插件
https://github.com/city96/ComfyUI-GGUF
#### gguf模型
curl -L -o ./models/unset/flux1-dev-Q8_0.gguf https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q8_0.gguf?download=true
#### clip
curl -L -o clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
curl -L -o t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true
curl -L -o clip_l.t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true
#### 加速lora
curl -L -o ./models/clip/Hyper-FLUX.1-dev-8steps-lora.safetensors  https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-FLUX.1-dev-8steps-lora.safetensors?download=true
curl -L -o ./models/clip/Hyper-FLUX.1-dev-16steps-lora.safetensors  https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-FLUX.1-dev-16steps-lora.safetensors?download=true
curl -L -o ./models/clip/Hyper-FLUX.1-dev-8steps-lora_rank1.safetensors https://huggingface.co/bdsqlsz/Hyper-Flux1-dev/resolve/main/Hyper-FLUX.1-dev-8steps-lora_rank1.safetensors?download=true

#### vae
https://liblibai-online.liblib.cloud/models/comfyui/afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38.sft?auth_key=1726022125-9b83542f2f6d488e91ba4067ff9e7bc8-0-6c637b8133219176d4472ba69de497c5&attname=F.1%20模型下载版-黑暗森林工作室_FLUX.1-vae.sft



FLUX原模+VAE：https://www.liblib.art/modelinfo/8dfd5ff599b7461f9924606eddfdb96a?from=search 
FLUX FP8模型：https://www.liblib.art/modelinfo/de40ff893256477bbb1bb54e3d8d9df6?from=search 
FLUX NF4模型：https://www.liblib.art/modelinfo/0175a2f9826d4c3a9335380940f87f58?from=search 
FLUX GGUF模型：https://huggingface.co/city96/FLUX.1-dev-gguf/tree/main 
FLUX CLIP模型：https://huggingface.co/comfyanonymous/flux_text_encoders/tree/main 
FLUX Lora模型：https://huggingface.co/XLabs-AI/flux-lora-collection/tree/main  

FLUX Controlnet模型： 
Hed：https://huggingface.co/XLabs-AI/flux-controlnet-hed-v3/tree/main  
Depth：https://huggingface.co/XLabs-AI/flux-controlnet-depth-v3/tree/main  
Canny：https://huggingface.co/XLabs-AI/flux-controlnet-canny-v3/tree/main 

GGUF节点包：https://github.com/city96/ComfyUI-GGUF 
NF4节点包：https://github.com/comfyanonymous/ComfyUI_bitsandbytes_NF4 
Xlabs节点包：https://github.com/XLabs-AI/x-flux-comfyui  

【以上所有模型整合+教学工作流+FLUX关键词】：https://pan.quark.cn/s/577933c072ee

### ngrok
docker run --net=host -it -e NGROK_AUTHTOKEN=2lraehFb0cGX8ELOdDLtglwC3vr_2EHrQ3pgxD4cxZv6pxeU5 ngrok/ngrok:latest http 8188


curl -X POST http://127.0.0.1:8188/flux_txt2img -H "Content-Type: application/json" -d '{"workflow_name": "workflow.json","prompt": "a cute cat","batch_size": 1,"width": 1024,"height": 1024}'


```
This is a woman, about 25 years old, looking at the audience with eyes that seem to have penetrated time. She is wearing a black windbreaker, shoulder-length black hair, straight bangs, and a white shirt exposed at the collar. The expression on her face seems to give humanity away. You can see through it. Also, this is a film photo, so it needs to have film grain.
```


flow-grafana-agent   generic
gc3a-embedding-deployment generic
adnext-ui-deployment generic
nginx generic

datadog-agent  go
node-local-dns  go
doraemon-metaknow-deployment go
g123-uts-deployment go
gc3a-gateway-deployment go
cs-mgr-go-api-deployment go
artifex-ui-deployment go
pilot-discovery go
istiod go
server go
agent go
api go
app go


g123-data-fireman-server-server java
g123-auxin-admin-server-deployment java
g123-data-audience-server-server java
g123-auxin-deployment java
artifex-deployment java
adnext-deployment java
adnext-infoservice-deployment java
java java


doraemon-data-api-deployment python
cs-mgr-ui-deployment python
g123-data-ads-manager python
g123-bot-py-deployment python
g123-data-gamefactory-deployment python
g123-ip-supervision-ui-deployment python
g123-data-gamefactory-creativelab-deployment python
doraemon-external-bot-deployment python
doraemon-bot-deployment python
gc3a-segment-anything-deployment python
gc3a-label-anything-deployment python
doraemon-metaknow-ui-deployment python
ads-scheduler-beater-deployment python
python3.10 python
python3.9 python