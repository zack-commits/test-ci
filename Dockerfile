# Use an official Python runtime as a parent image
FROM python:3.10.12

# Set the working directory in the container
WORKDIR /app/ComfyUI

# Copy the current directory contents into the container at /app
COPY ./ComfyUI /app/ComfyUI

# Install any needed packages specified in requirements.txt
RUN pip install --upgrade pip && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu && \
    pip install -r requirements.txt

# Make port 8188 available to the world outside this container
EXPOSE 8188

# 健康检查，使用 /system_stats 路由
HEALTHCHECK CMD curl -fs http://localhost:8188/system_stats || exit 1

# Define environment variable
ENV PYTHONUNBUFFERED=1

# Run main.py when the container launches
CMD ["python", "main.py", "--listen"]