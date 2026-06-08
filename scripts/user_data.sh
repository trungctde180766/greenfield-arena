#!/bin/bash
set -e

# Redirect all output to log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update and install dependencies
apt-get update -y
apt-get install -y docker.io curl git

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Create kind cluster configuration with port mapping
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
EOF

# Create cluster
kind create cluster --config kind-config.yaml

# Create web app HTML
mkdir -p /root/webapp
cat <<'EOF' > /root/webapp/index.html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GreenField - Đặt sân thể thao</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #134e5e, #71b280);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            color: #fff;
            overflow: hidden;
        }
        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .glass-container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 24px;
            padding: 3rem 4rem;
            text-align: center;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            max-width: 600px;
            width: 90%;
            transform: translateY(30px);
            opacity: 0;
            animation: slideUp 1s ease-out forwards;
        }
        @keyframes slideUp {
            to { transform: translateY(0); opacity: 1; }
        }
        .icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-20px); }
            60% { transform: translateY(-10px); }
        }
        h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(to right, #a8ff78, #78ffd6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        p.subtitle {
            font-size: 1.25rem;
            font-weight: 300;
            margin-bottom: 2rem;
            line-height: 1.6;
            color: #e0e0e0;
        }
        .version-badge {
            display: inline-block;
            background: rgba(0, 0, 0, 0.3);
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.875rem;
            font-weight: 500;
            letter-spacing: 1px;
            text-transform: uppercase;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }
        .version-badge:hover {
            background: rgba(0, 0, 0, 0.5);
            transform: scale(1.05);
        }
        .circles {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: -1;
        }
        .circles li {
            position: absolute;
            display: block;
            list-style: none;
            width: 20px;
            height: 20px;
            background: rgba(255, 255, 255, 0.2);
            animation: float 25s linear infinite;
            bottom: -150px;
            border-radius: 50%;
        }
        .circles li:nth-child(1) { left: 25%; width: 80px; height: 80px; animation-delay: 0s; }
        .circles li:nth-child(2) { left: 10%; width: 20px; height: 20px; animation-delay: 2s; animation-duration: 12s; }
        .circles li:nth-child(3) { left: 70%; width: 20px; height: 20px; animation-delay: 4s; }
        .circles li:nth-child(4) { left: 40%; width: 60px; height: 60px; animation-delay: 0s; animation-duration: 18s; }
        .circles li:nth-child(5) { left: 65%; width: 20px; height: 20px; animation-delay: 0s; }
        .circles li:nth-child(6) { left: 75%; width: 110px; height: 110px; animation-delay: 3s; }
        .circles li:nth-child(7) { left: 35%; width: 150px; height: 150px; animation-delay: 7s; }
        .circles li:nth-child(8) { left: 50%; width: 25px; height: 25px; animation-delay: 15s; animation-duration: 45s; }
        .circles li:nth-child(9) { left: 20%; width: 15px; height: 15px; animation-delay: 2s; animation-duration: 35s; }
        .circles li:nth-child(10) { left: 85%; width: 150px; height: 150px; animation-delay: 0s; animation-duration: 11s; }
        @keyframes float {
            0% { transform: translateY(0) rotate(0deg); opacity: 1; border-radius: 0; }
            100% { transform: translateY(-1000px) rotate(720deg); opacity: 0; border-radius: 50%; }
        }
    </style>
</head>
<body>
    <ul class="circles">
        <li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li><li></li>
    </ul>
    <div class="glass-container">
        <div class="icon">⚽</div>
        <h1>GreenField</h1>
        <p class="subtitle">Hệ thống đặt sân thể thao hiện đại, nhanh chóng và tiện lợi số 1 dành cho bạn.</p>
        <div class="version-badge">
            🚀 Phiên bản 1.0.0 | K8s & Terraform
        </div>
    </div>
</body>
</html>
EOF

# Create Dockerfile
cat <<'EOF' > /root/webapp/Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EOF

# Build Docker image
cd /root/webapp
docker build -t greenfield-app:1.0 .

# Load image into kind cluster
kind load docker-image greenfield-app:1.0

# Create K8s deployment and service
cat <<EOF > /root/webapp/k8s-manifest.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: greenfield-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: greenfield
  template:
    metadata:
      labels:
        app: greenfield
    spec:
      containers:
      - name: greenfield
        image: greenfield-app:1.0
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: greenfield-service
spec:
  type: NodePort
  selector:
    app: greenfield
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30000
EOF

kind get kubeconfig > /root/kubeconfig
export KUBECONFIG=/root/kubeconfig
kubectl apply -f /root/webapp/k8s-manifest.yaml

echo "Setup complete!"
