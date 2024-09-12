package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"math/rand"
)

type Payload struct {
	WorkflowName string `json:"workflow_name"`
	Prompt       string `json:"prompt"`
	BatchSize    int    `json:"batch_size"`
	Width        int    `json:"width"`
	Height       int    `json:"height"`
}

type ResponseItem struct {
	ImageBase64 string `json:"image_base64"`
	Index       int    `json:"index"`
}

var wg sync.WaitGroup

const SYNCNUM = 1

func generateImage(prompt string) {
	defer wg.Done()
	// 自定义API的请求地址和Token
	// serverAddress := "https://ra9egd0raba5e1ee.us-east-1.aws.endpoints.huggingface.cloud"
	// serverAddress := "http://127.0.0.1:8189"
	serverAddress := "https://56f9-13-48-53-51.ngrok-free.app"
	endpoint := fmt.Sprintf("%s/flux_txt2img", serverAddress)
	// accessToken := "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"

	// 准备JSON请求体
	payload := Payload{
		WorkflowName: "v2_FLUX_D_model_Q8_clip_Q8.json",
		Prompt:       prompt,
		BatchSize:    1,
		Width:        1024,
		Height:       1024,
	}

	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		fmt.Println("JSON 序列化错误:", err)
		return
	}

	req, err := http.NewRequest("POST", endpoint, bytes.NewBuffer(payloadBytes))
	if err != nil {
		fmt.Println("请求创建错误:", err)
		return
	}

	req.Header.Set("Content-Type", "application/json")
	// req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", accessToken))

	// 记录开始时间
	startTime := time.Now()

	// 发送请求并获取响应
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("请求失败:", err)
		return
	}
	defer resp.Body.Close()

	// 记录结束时间并计算响应时间
	endTime := time.Now()
	responseTime := endTime.Sub(startTime)
	fmt.Printf("API 响应时间: %.2f 秒\n", responseTime.Seconds())

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("读取响应错误:", err)
		return
	}

	// fmt.Println("API 响应状态码:", resp.StatusCode)
	// fmt.Println("API 响应内容:", string(body))

	// 将响应内容写入 api.json 文件
	// err = os.WriteFile("api.json", body, 0644) // 0644 是文件的权限，表示可读写但非执行
	// if err != nil {
	// 	fmt.Println("保存文件错误:", err)
	// 	return
	// }

	// fmt.Println("响应内容已成功保存到 api.json")

	if resp.StatusCode != http.StatusOK {
		fmt.Println("API 请求失败，状态码:", resp.StatusCode)
		fmt.Println("响应内容:", string(body))
		return
	}

	err = os.WriteFile("api.json", body, 0644)
	if err != nil {
		fmt.Println("保存json错误:", err)
		return
	}

	// 解析JSON响应
	var responseItems []ResponseItem
	err = json.Unmarshal(body, &responseItems)
	if err != nil {
		fmt.Println("解析响应JSON错误:", err)
		return
	}

	if len(responseItems) == 0 {
		fmt.Println("没有找到图片数据")
		return
	}

	// 提取Base64编码的图片数据
	imageData := responseItems[0].ImageBase64
	imageBytes, err := base64.StdEncoding.DecodeString(imageData)
	if err != nil {
		fmt.Println("Base64 解码错误:", err)
		return
	}

	//文件名字为当前时间加随机字符串
	fileName := "./img/" + time.Now().Format("20060102150405") + generateRandomString(3) + ".png"

	// 将图片保存为PNG文件
	err = ioutil.WriteFile(fileName, imageBytes, 0644)
	if err != nil {
		fmt.Println("保存图片错误:", err)
		return
	}

	fmt.Println("图片已成功保存为png")
}

// 生成三个随机字母
func generateRandomString(n int) string {
	const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	rand.Seed(time.Now().UnixNano())
	var sb strings.Builder
	for i := 0; i < n; i++ {
		sb.WriteByte(letters[rand.Intn(len(letters))])
	}
	return sb.String()
}

func main() {
	// 记录开始时间
	startTime := time.Now()
	prompt := "In a forest, the sun is shining brightly, and the air is filled with the fragrance of flowers and the chirping of birds. Two little girls are holding hands, smiling at the camera in a front-facing shot. A wise old grandpa Tree is smiling and looking at them. One of the girls is wearing a pale yellow dress with lace edges, glasses, and has a black ponytail, while the other is wearing blue jeans and a pink shirt with long golden hair. There is also a wooden sign stuck in the ground beside them, which reads ‘Happy Childhood.’ Contemporary fashion photo shoot, masterpiece, realism, 4k, high quality, high focus, superior quality, sharp and clear."
	wg = sync.WaitGroup{}
	wg.Add(SYNCNUM)
	for range SYNCNUM {
		go generateImage(prompt)
	}
	wg.Wait()
	// 记录结束时间并计算响应时间
	endTime := time.Now()
	responseTime := endTime.Sub(startTime)
	fmt.Printf("总时间: %.2f 秒\n", responseTime.Seconds())
}
