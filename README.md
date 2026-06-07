# 🚀 Đồ Án: Tự động hoá Triển khai K8s và Ứng dụng Web bằng Terraform

Dự án này sử dụng Terraform để thực hiện **1-Click Automation** việc xây dựng toàn bộ hạ tầng mạng trên AWS (VPC, Subnets, ALB, EC2), tự động cài đặt cụm Kubernetes (Kind) và triển khai một ứng dụng web Đặt sân thể thao (GreenField Arena) hoàn toàn tự động.

## 🛠 Lệnh chạy (Hướng dẫn triển khai)

**Yêu cầu hệ thống:**
- Cài đặt [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
- Cấu hình AWS Credentials (chạy lệnh `aws configure` với quyền Admin)

**Các bước chạy:**

1. **Khởi tạo Terraform:**
   ```bash
   terraform init
   ```

2. **Kiểm tra kế hoạch triển khai (tuỳ chọn):**
   ```bash
   terraform plan
   ```

3. **Áp dụng triển khai (1-Click):**
   ```bash
   terraform apply -auto-approve
   ```

4. **Kiểm tra kết quả:**
   - Sau khi lệnh apply hoàn tất, lấy URL của Load Balancer tại output `alb_url`.
   - **Lưu ý:** Đợi khoảng **3-5 phút** để EC2 cài đặt xong Kubernetes và Web App ở background. Trong thời gian này, truy cập URL sẽ báo lỗi `503 Service Temporarily Unavailable` (đây là cơ chế Health Check bình thường của ALB).
   - Khi App sẵn sàng, load lại URL để thấy giao diện Web Đặt Sân Thể Thao.

5. **Dọn dẹp hệ thống (Không dùng nữa):**
   ```bash
   terraform destroy -auto-approve
   ```

## 🏗 Sơ đồ Kiến trúc (Architecture Diagram)

```mermaid
graph TD
    User([Người dùng]) -->|HTTP Port 80| ALB(AWS Application Load Balancer)
    
    subgraph AWS VPC
        ALB -->|Forward Port 30000| EC2_SG[Security Group]
        
        subgraph EC2 Instance [Máy chủ EC2 - t3.small]
            EC2_SG --> HostPort(Máy chủ Vật lý - Port 30000)
            HostPort -->|Docker Port Mapping| DockerContainer[Docker Container: Kind Control Plane]
            
            subgraph K8s Cluster [Cụm Kubernetes - Kind]
                DockerContainer --> NodePort(K8s NodePort Service - Port 30000)
                NodePort -->|Load Balance| Pod(App Pod: Nginx Web Server - Port 80)
            end
        end
    end
    
    subgraph Cơ sở hạ tầng tự động (Terraform Providers)
        TF[Terraform] -->|AWS Provider| AWS_VPC
        TF -->|HTTP Provider| AutoIP(Lấy IP Public của Dev)
        AutoIP -.->|Whitelist SSH| EC2_SG
        TF -->|TLS Provider| SSH_Key(Tạo Cặp khoá RSA)
        SSH_Key -.->|Local Provider| File(Lưu k8s-1click-key.pem)
    end
```

## 🔌 Giải thích cách Wire Provider (Sự liên kết giữa các Providers)

Đồ án sử dụng **4 Providers** và "wire" (liên kết) chúng với nhau một cách chặt chẽ để tăng tính tự động và bảo mật:

1. **Provider `aws` (Chính):** Tạo toàn bộ hạ tầng (VPC, ALB, EC2, Security Groups).
2. **Provider `tls` & `aws` & `local` (Wire 1 - Cấp phát SSH Key tự động):**
   - Terraform dùng `tls_private_key` để sinh ra một cặp khoá RSA mã hoá.
   - Lấy **Public Key** đẩy lên AWS thông qua tài nguyên `aws_key_pair` để gắn vào máy ảo EC2.
   - Dùng provider `local` (cụ thể là `local_sensitive_file`) lấy **Private Key** lưu thẳng xuống máy tính dưới dạng file `k8s-1click-key.pem`. 
   - *Kết quả:* Không cần tạo key thủ công trên AWS Console, file `.pem` có sẵn trên máy tính để dev có thể SSH vào EC2 lập tức.
3. **Provider `http` & `aws` (Wire 2 - Bảo mật Security Group động):**
   - Dùng provider `http` (cụ thể là `data.http.myip`) gọi API `ipv4.icanhazip.com` để tự động dò ra địa chỉ IP Public của mạng wifi mà người đang chạy Terraform sử dụng.
   - Cài cắm chính IP này vào rule Ingress cho Port 22 của Security Group trên AWS.
   - *Kết quả:* EC2 được bảo mật tuyệt đối, ngăn chặn mọi nỗ lực scan dò quét port SSH, vì chỉ có đúng địa chỉ IP của bạn mới được quyền truy cập.

## 📸 Bằng chứng (Proof of Execution)

Dưới đây là bằng chứng Load Balancer đang hoạt động bình thường, định tuyến thành công vào K8s và mở được giao diện Web Đặt Sân Thể Thao trên Browser:

> **Ghi chú nộp bài:** Cần chụp màn hình trình duyệt lúc App đang mở (nhớ hiển thị rõ URL của AWS ALB trên thanh địa chỉ), lưu file thành `proof.png` vào cùng thư mục này để hình ảnh hiển thị ở dưới.

![App Demo ALB URL](./proof.png)
