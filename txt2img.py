# txt2img
# 在ComfyUI 中内包一个API, 内调已有的图片生成API并返回图片
# 请求地址
import json
import urllib.request
import base64
import time

# 自定义API
server_address = "https://ra9egd0raba5e1ee.us-east-1.aws.endpoints.huggingface.cloud"
server_address = "https://3457-13-48-53-51.ngrok-free.app"
# server_address = "http://127.0.0.1:8188"
endpoint = f"{server_address}/flux_txt2img"
access_token = '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'

payload = {
    "workflow_name": "workflow.json",
    "prompt": "In a forest, the sun is shining brightly, and the air is filled with the fragrance of flowers and the chirping of birds. Two little girls are holding hands, smiling at the camera in a front-facing shot. A wise old grandpa Tree is smiling and looking at them. One of the girls is wearing a pale yellow dress with lace edges, glasses, and has a black ponytail, while the other is wearing blue jeans and a pink shirt with long golden hair. There is also a wooden sign stuck in the ground beside them, which reads ‘Happy Childhood.’ Contemporary fashion photo shoot, masterpiece, realism, 4k, high quality, high focus, superior quality, sharp and clear.",
    "batch_size": 1,
    "width": 1024,
    "height": 768
}
json_data = json.dumps(payload).encode('utf-8')
# 创建请求对象
req = urllib.request.Request(endpoint, data=json_data, headers={'Content-Type': 'application/json',"Authorization": f"Bearer {access_token}"}, method='POST')

# 发送请求并获取响应
try:
    start_time = time.time()  # 记录开始时间

    with urllib.request.urlopen(req) as response:
        end_time = time.time()  # 记录结束时间
        response_time = end_time - start_time  # 计算响应时间
        
        print(f"API 响应时间: {response_time:.2f} 秒")


        # 读取并解析响应
        result = response.read().decode('utf-8')
        result_json = json.loads(result)

        # 打印完整的响应内容
        # print("API 响应内容:", json.dumps(result_json, indent=1, ensure_ascii=False))

        #将响应内容保存到文件中
        with open('api_response.json', 'w', encoding='utf-8') as f:
            json.dump(result_json, f, ensure_ascii=False, indent=2)
        
        print("API 响应已保存到文件 'api_response.json'")
        
       # 检查响应中是否包含图片数据
        image_data = result_json[0]['image_base64']
        image_bytes = base64.b64decode(image_data)
        
        # 将图片保存为文件
        with open('generated_image.png', 'wb') as img_file:
            img_file.write(image_bytes)
            
        print("图片已成功保存为 generated_image.png")
except urllib.error.HTTPError as e:
    # 处理HTTP错误
    print(f"HTTP error: {e.code} - {e.reason}")
    result = None
except urllib.error.URLError as e:
    # 处理URL错误
    print(f"URL error: {e.reason}")
    result = None
