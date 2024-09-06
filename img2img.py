# img2img
# 在ComfyUI 中内包一个API, 内调已有的图片生成API并返回图片
# 请求地址
import json
import urllib
import base64
import io
from PIL import Image
import os

def image_to_base64(image):
    # convert Pillow image type to base64
    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='PNG')
    img_byte_arr = img_byte_arr.getvalue()
    return base64.b64encode(img_byte_arr).decode('utf-8')

# 自定义API
server_address = "https://ra9egd0raba5e1ee.us-east-1.aws.endpoints.huggingface.cloud"
# server_address = "http://127.0.0.1:8188"
endpoint = f"{server_address}/flux_img2img"

img_pth = "./test.png"
img_name = os.path.basename(img_pth)
img_base64 = image_to_base64(Image.open(img_pth))

payload = {
    "workflow_name": "v2_FLUX_D_model_Q8_clip_Q8_IMG_TO_MG.json", 
    "prompt": "A circular flower bed surrounded by stone bricks, a large tree, low shrubs, natural lighting, in a style reminiscent of Makoto Shinkai.png",
    "img_name": img_name,
    "img_base64": img_base64, 
    "denoise": 0.9
}
json_data = json.dumps(payload).encode('utf-8')
# 创建请求对象
req = urllib.request.Request(endpoint, data=json_data, headers={'Content-Type': 'application/json'}, method='POST')

# 发送请求并获取响应
try:
    with urllib.request.urlopen(req) as response:
        # 读取并解析响应
        result = response.read().decode('utf-8')
        result = json.loads(result)
except urllib.error.HTTPError as e:
    # 处理HTTP错误
    print(f"HTTP error: {e.code} - {e.reason}")
    result = None
except urllib.error.URLError as e:
    # 处理URL错误
    print(f"URL error: {e.reason}")
    result = None