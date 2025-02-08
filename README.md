# 密码生成器 (Password Generator)

一个使用 Flutter Web 开发的在线密码生成器，支持多种自定义选项，可生成安全、可靠的密码。

## 功能特点

- 🔐 自定义密码长度（4-32字符）
- 🔢 支持数字、大小写字母、特殊字符
- ⚙️ 灵活的密码规则配置
- 📱 响应式设计，支持移动端和桌面端
- 🎨 现代化的 Material Design 3 界面
- 📊 密码强度实时评估
- 💡 智能密码建议
- 📋 一键复制功能

## 在线体验

访问 [在线密码生成器](#) 立即使用

## 本地开发

### 环境要求

- Flutter SDK (3.6.0 或更高)
- Dart SDK (3.6.0 或更高)
- 支持 Web 的浏览器

### 安装步骤

1. 克隆项目

```bash
git clone https://github.com/yourusername/password_generator.git
cd password_generator
```

2. 安装依赖

```bash
flutter pub get
```

3. 运行项目

```bash
# 开发模式
flutter run -d chrome

# 或构建发布版本
flutter build web --release
```

### 项目结构

```
lib/
├── main.dart              # 应用入口
├── screens/               # 界面
│   └── password_generator_screen.dart
├── services/             # 服务
│   └── password_generator.dart
└── utils/               # 工具类
    └── responsive_utils.dart
```

## 部署说明

1. 构建 Web 版本

```bash
flutter build web --release
```

2. 部署到服务器

- 将 `build/web` 目录下的文件复制到您的 Web 服务器
- 确保正确配置服务器以支持 Flutter Web 应用

### Apache 配置示例

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</IfModule>
```

### Nginx 配置示例

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## 技术栈

- Flutter Web
- Material Design 3
- Responsive Builder
- Flutter Web Optimizer

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

作者 - [@yourusername](https://github.com/yourusername)

项目链接: [https://github.com/yourusername/password_generator](https://github.com/yourusername/password_generator)

## 致谢

- [Flutter](https://flutter.dev)
- [Material Design](https://material.io)
- [所有贡献者](https://github.com/yourusername/password_generator/contributors)

