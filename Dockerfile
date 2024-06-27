# Sử dụng Nginx image chính thức từ Docker Hub
FROM nginx:alpine

# Copy nội dung từ thư mục hiện tại vào thư mục html của Nginx
COPY . /usr/share/nginx/html

# Expose cổng 80
EXPOSE 80
