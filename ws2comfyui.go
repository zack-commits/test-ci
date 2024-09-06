package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"image/png"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// 定义请求数据结构
type RequestPayload struct {
	WorkflowName string `json:"workflow_name"`
	Prompt       string `json:"prompt"`
	BatchSize    int    `json:"batch_size"`
	Width        int    `json:"width"`
	Height       int    `json:"height"`
}

// 定义响应结构
type QueueInfo struct {
	PromptID string `json:"prompt_id"`
}

func fluxTxt2ImgHandler(w http.ResponseWriter, r *http.Request) {
	// 解析请求体
	var data RequestPayload
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	// 处理工作流文件路径
	workflowName := data.WorkflowName
	workflowPath := fmt.Sprintf("/repository/%s", workflowName)

	if _, err := os.Stat(workflowPath); os.IsNotExist(err) {
		http.Error(w, "Workflow file not found", http.StatusNotFound)
		return
	}

	// 打开工作流文件
	file, err := os.Open(workflowPath)
	if err != nil {
		http.Error(w, "Failed to open workflow file", http.StatusInternalServerError)
		return
	}
	defer file.Close()

	// 加载工作流 JSON
	var prompt map[string]interface{}
	if err := json.NewDecoder(file).Decode(&prompt); err != nil {
		http.Error(w, "Failed to parse workflow file", http.StatusInternalServerError)
		return
	}

	// 修改工作流中的 prompt, batch_size, width, height 等参数
	prompt["11"].(map[string]interface{})["inputs"].(map[string]interface{})["text"] = data.Prompt
	prompt["12"].(map[string]interface{})["inputs"].(map[string]interface{})["batch_size"] = data.BatchSize
	prompt["12"].(map[string]interface{})["inputs"].(map[string]interface{})["width"] = data.Width
	prompt["12"].(map[string]interface{})["inputs"].(map[string]interface{})["height"] = data.Height
	prompt["13"].(map[string]interface{})["inputs"].(map[string]interface{})["noise_seed"] = time.Now().UnixNano() % 10000000

	// 数据传递到 API
	serverAddress := "http://127.0.0.1:8188"
	clientID := uuid.New().String()
	p := map[string]interface{}{
		"prompt":    prompt,
		"client_id": clientID,
	}

	// 发送 POST 请求
	resp, err := sendPostRequest(fmt.Sprintf("%s/prompt", serverAddress), p)
	if err != nil {
		http.Error(w, "Failed to send POST request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// 解析队列信息
	var queueInfo QueueInfo
	if err := json.NewDecoder(resp.Body).Decode(&queueInfo); err != nil {
		http.Error(w, "Failed to parse queue info", http.StatusInternalServerError)
		return
	}

	// 建立 WebSocket 连接
	websocketURL := fmt.Sprintf("ws://%s/ws?clientId=%s", serverAddress, clientID)
	conn, _, err := websocket.DefaultDialer.Dial(websocketURL, nil)
	if err != nil {
		http.Error(w, "Failed to connect to WebSocket", http.StatusInternalServerError)
		return
	}
	defer conn.Close()

	// 监听 WebSocket 消息
	outputImages := make(map[string][][]byte)
	currentNode := ""
	saveWebsocketNodeID := "20"

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			break // WebSocket 连接关闭或出错
		}

		// 解析 JSON 消息
		var msg map[string]interface{}
		if err := json.Unmarshal(message, &msg); err != nil {
			continue
		}

		if msg["type"] == "executing" {
			data := msg["data"].(map[string]interface{})
			if data["prompt_id"] == queueInfo.PromptID {
				if data["node"] == nil {
					break // 执行结束
				} else {
					currentNode = data["node"].(string)
				}
			}
		} else if currentNode == saveWebsocketNodeID {
			// 处理图片二进制数据
			imageData := message[8:] // 假设图片数据从第8字节开始
			outputImages[currentNode] = append(outputImages[currentNode], imageData)
		}
	}

	// 将图片保存并返回 Base64 编码
	var result []map[string]string
	for nodeID, images := range outputImages {
		for idx, imageData := range images {
			imgReader := bytes.NewReader(imageData)
			img, err := png.Decode(imgReader)
			if err != nil {
				continue
			}

			// 保存图片为文件
			fileName := fmt.Sprintf("generated_image_%s_%d.png", nodeID, idx)
			imgFile, err := os.Create(fileName)
			if err != nil {
				continue
			}
			png.Encode(imgFile, img)
			imgFile.Close()

			// 将图片转换为 Base64
			buffer := new(bytes.Buffer)
			png.Encode(buffer, img)
			imgBase64 := base64.StdEncoding.EncodeToString(buffer.Bytes())

			// 将结果存入响应
			result = append(result, map[string]string{
				"image_base64": imgBase64,
				"index":        fmt.Sprintf("%d", idx),
			})
		}
	}

	// 返回结果
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func sendPostRequest(url string, data interface{}) (*http.Response, error) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	return client.Do(req)
}

func main() {
	http.HandleFunc("/flux_txt2img", fluxTxt2ImgHandler)
	fmt.Println("Server started at :8080")
	http.ListenAndServe(":8080", nil)
}
