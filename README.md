# CouldTalk 聊天网站技术文档

## 📌 项目概述
本项目是一个基于 **Flask** 和 **WebSocket (SocketIO)** 构建的即时通讯系统。系统支持多端登录限制、好友管理、即时聊天（文本/文件）、以及完善的管理员审计与后台管理功能。

---

## 🛠 技术栈
* **后端框架**: Flask 3.x
* **数据库 ORM**: SQLAlchemy (MySQL)
* **实时通信**: Flask-SocketIO (Eventlet 异步模式)
* **身份验证**: Flask-Login
* **前端引擎**: Jinja2 模板
* **环境依赖**: PyMySQL, Werkzeug (安全校验)

---

## 🗄 数据库模型设计

### 1. 用户表 (`users`)
存储用户核心信息、登录状态及权限控制字段。
* `id`: 唯一标识 (自增)
* `username`: 用户名 (唯一)
* `role`: 角色 (`admin` / `user`)
* `current_session_id`: **关键字段**，存储当前有效 UUID，用于实现单设备登录踢出逻辑。
* `login_attempts / lock_time`: 用于暴力破解防御的计数器和锁定时间。
* `is_banned / is_muted`: 封号与禁言状态位。

### 2. 消息表 (`messages`)
* 存储发送者、接收者、内容及文件路径（图片/音频）。

### 3. 好友关系 (`friends`) & 请求表 (`friend_requests`)
* 支持双向好友验证机制（`pending`, `accepted`, `rejected`）。

### 4. 审计日志表 (`user_activities`)
* 记录 IP 地址、操作类型（登录、改密、管理行为）、User-Agent 及请求路径。

---

## 🔐 核心安全机制

### 1. 单设备登录限制 (Session Validation)
系统通过 `app.before_request` 全局拦截器实现：
1.  登录成功后，服务器生成一个随机的 `UUID` 存入数据库 `current_session_id` 和用户 Session。
2.  每次请求时校验两者是否一致。
3.  **效果**：若账号在 B 设备登录，A 设备的 `session_id` 将失效，用户被强制登出并提示“已在其他设备登录”。

### 2. 暴力破解防御
* **失败计数**：连续失败 3 次后强制开启 **4位数字验证码** 校验。
* **临时锁定**：连续失败 5 次后，账号自动锁定 **60 秒**，期间无法尝试登录。

### 3. 管理员初始化保护
* 系统通过 `/init_admin` 入口进行首次部署。
* 设置了 `INIT_ADMIN_SECRET` 安全密钥校验，且一旦数据库存在管理员账号，该入口自动关闭。

### 4. 数据安全
* **密码加密**：采用 `pbkdf2:sha256` 算法进行 Hash 存储。
* **权限装饰器**：使用 `@admin_required` 自定义装饰器保护管理接口。

---

## 🚀 核心功能接口

### 用户功能
* **注册/登录**：包含设备信息采集和验证码逻辑。
* **即时通讯**：基于 SocketIO 实现，支持 `eventlet` 并发。
* **文件上传**：限制图片最大 **20MB**，音频最大 **100MB**。

### 管理员后台
| 路径 | 功能说明 |
| :--- | :--- |
| `/admin/panel` | 用户概览，控制禁言、封号、修改用户密码。 |
| `/admin/logout_user/<id>` | **物理删除**用户及其关联的所有聊天、好友、日志数据。 |
| `/admin/view_activities` | 审计日志查看，支持**防抖记录**（30秒内不重复记录相同查看行为）。 |
| `/admin/clear_activities` | 一键清空审计日志并**重置自增 ID**。 |

---

## 🔧 系统配置常量
* `SESSION_TIMEOUT`: 默认 **3600秒** (1小时) 自动超时。
* `PASSWORD_PATTERN`: 必须包含字母和数字，长度 $\ge 6$ 位。
* `UPLOAD_FOLDER`: `static/uploads`。

---

## ⚠️ 开发者提醒
1.  **数据库重排**：系统内置了 `reorder_user_ids` 和 `reorder_activity_ids` 函数，在删除数据后会通过原生 SQL `ALTER TABLE ... AUTO_INCREMENT = N` 保持 ID 的连续性。
2.  **异步模式**：SocketIO 使用了 `manage_session=False`，以防止与 Flask 原生 Session 产生竞争冲突。
	

欢迎大家进行二次开发

<img src="https://github.com/user-attachments/assets/0a2c6783-7ccf-4091-a57a-099ed1c215ac" width="300" height="300" />

```text
CouldTalk License (Non-Commercial)

版权所有 (c) 2026 LLH

许可条款：
1. 本项目允许任何个人或组织在非商业用途下使用、复制、修改和分发。
2. **禁止任何形式的商业销售**，包括但不限于：
   - 直接出售源代码
   - 打包后出售
   - 提供基于本项目的收费服务
3. 使用本项目即表示接受以上条款。
4. 如违反上述条款，作者保留追究法律责任的权利。
