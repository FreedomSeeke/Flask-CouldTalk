import os
import uuid
import random
import re  # 新增：引入正则表达式模块
import platform
from sqlalchemy.sql import func
from datetime import datetime, timedelta
from flask import Flask, render_template, request, redirect, url_for, jsonify, flash, send_from_directory, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user, \
    fresh_login_required
from flask_socketio import SocketIO, emit, join_room, leave_room
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import pymysql

# 初始化Flask应用
app = Flask(__name__)
app.config['SECRET_KEY'] = '30cd3ad5fa7e09f62affc67c14700d54d24f3fc3fceac272'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://flaskuser:v%2BeZU0%5EOS%3EO4mTZrZRj1@127.0.0.1:3306/wechat_chat?charset=utf8mb4'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_POOL_SIZE'] = 5
app.config['SQLALCHEMY_POOL_RECYCLE'] = 3600

# -------------- 关键配置：开启session支持（Flask默认开启，此处显式声明） --------------
app.config['SESSION_PERMANENT'] = False  # 会话随浏览器关闭失效
app.config['SESSION_TYPE'] = 'filesystem'  # 会话存储方式，也可使用redis等

# -------------- 文件上传配置 --------------
UPLOAD_FOLDER = os.path.join(app.root_path, 'static/uploads')
ALLOWED_IMAGE_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'}
ALLOWED_AUDIO_EXTENSIONS = {'mp3', 'wav', 'ogg', 'm4a', 'flac'}
MAX_IMAGE_SIZE = 20 * 1024 * 1024
MAX_AUDIO_SIZE = 100 * 1024 * 1024

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# 初始化数据库和SocketIO
db = SQLAlchemy(app)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='eventlet',
                    manage_session=False)  # 关闭SocketIO的session管理，避免冲突

# 初始化登录管理器
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# 安全密钥（用于创建初始管理员，可自行修改）
INIT_ADMIN_SECRET = '2381b3335f76ca56db8beaa127181ef37accbdb7223e559e46a47c58d549fe2d'  # 建议修改为自己的密钥

# -------------- 会话常量 --------------
SESSION_ID_KEY = 'user_session_id'  # session中存储会话ID的键名
SESSION_TIMEOUT = 3600  # 会话超时时间（秒），默认1小时

# -------------- 密码校验常量 --------------
PASSWORD_PATTERN = r'^(?=.*[a-zA-Z])(?=.*\d).{6,}$'  # 密码规则：至少6位，包含字母和数字
PASSWORD_ERROR_MSG = '密码必须是字母和数字的组合，且长度不少于6位'


# -------------- 数据库模型修改 --------------
class User(UserMixin, db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(500), nullable=False)
    online = db.Column(db.Boolean, default=False)
    # 登录验证相关字段
    login_attempts = db.Column(db.Integer, default=0)  # 登录失败次数
    lock_time = db.Column(db.DateTime, nullable=True)  # 账号锁定时间
    verify_code = db.Column(db.String(4), nullable=True)  # 验证码
    # 权限/状态字段
    role = db.Column(db.String(20), default='user')  # user:普通用户, admin:管理员
    is_banned = db.Column(db.Boolean, default=False)  # 是否封号
    is_muted = db.Column(db.Boolean, default=False)  # 是否禁言
    # 登录信息
    login_device = db.Column(db.String(100), nullable=True)  # 登录设备
    last_login_time = db.Column(db.DateTime, nullable=True)  # 最后登录时间
    session_created_at = db.Column(db.DateTime, nullable=True)  # 会话创建时间，用于会话超时
    # -------------- 新增字段：当前有效会话ID --------------
    current_session_id = db.Column(db.String(100), nullable=True)  # 存储当前唯一有效登录的会话ID
    # -------------- 新增字段：头像 --------------
    avatar = db.Column(db.String(255), nullable=True)  # 头像路径


class Message(db.Model):
    __tablename__ = 'messages'
    id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    receiver_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    content = db.Column(db.Text, nullable=True)
    file_type = db.Column(db.String(20), nullable=True)
    file_path = db.Column(db.String(255), nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.now())

    sender = db.relationship('User', foreign_keys=[sender_id], backref='sent_messages')
    receiver = db.relationship('User', foreign_keys=[receiver_id], backref='received_messages')


class FriendRequest(db.Model):
    __tablename__ = 'friend_requests'
    id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    receiver_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(20), default='pending')  # pending, accepted, rejected
    #created_at = db.Column(db.DateTime, default=datetime.now())
    created_at = db.Column(db.DateTime, server_default=func.now())

    # 关系定义
    sender = db.relationship('User', foreign_keys=[sender_id], backref='sent_requests')
    receiver = db.relationship('User', foreign_keys=[receiver_id], backref='received_requests')


class Friend(db.Model):
    __tablename__ = 'friends'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    friend_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now())

    # 关系定义
    user = db.relationship('User', foreign_keys=[user_id], backref='friendships')
    friend = db.relationship('User', foreign_keys=[friend_id], backref='friend_of')



class UserActivity(db.Model):
    __tablename__ = 'user_activities'

    id = db.Column(db.Integer, primary_key=True)

    user_id = db.Column(
        db.Integer,
        db.ForeignKey('users.id'),
        nullable=False
    )

    ip_address = db.Column(db.String(45), nullable=False)

    action_type = db.Column(db.String(50), nullable=False)
    action_detail = db.Column(db.Text, nullable=True)

    # ✅ 关键修复：传函数，不要调用
    created_at = db.Column(
        db.DateTime,
        default=datetime.now,
        nullable=False
    )

    # ✅ 强烈推荐的审计字段
    user_agent = db.Column(db.String(255))
    request_path = db.Column(db.String(100))
    method = db.Column(db.String(10))

    # 关系定义
    user = db.relationship('User', backref='activities')



# -------------- 工具函数 --------------
def allowed_file(filename, allowed_extensions):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extensions


# 生成4位数字验证码
def generate_verify_code():
    return str(random.randint(1000, 9999))


# 生成唯一的会话ID（使用UUID）
def generate_session_id():
    return str(uuid.uuid4())


# 检查账号是否锁定（临时锁定）
def is_user_locked(user):
    if not user.lock_time:
        return False
    if datetime.now() - user.lock_time < timedelta(minutes=1):
        return True
    # 超过锁定时间，重置状态
    user.lock_time = None
    user.login_attempts = 0
    db.session.commit()
    return False


# 获取登录设备信息
def get_login_device():
    """获取用户登录设备/系统信息"""
    user_agent = request.headers.get('User-Agent', '')
    system = platform.system()  # Windows/Linux/Mac
    device_info = f"{system} - {user_agent[:50]}..."  # 截取部分UA信息
    return device_info


# 获取用户IP地址
def get_user_ip():
    """获取访问者的真实IP地址"""
    # 尝试从各种可能的HTTP头中获取真实IP
    ip_headers = [
        'X-Real-IP',
        'X-Forwarded-For',
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_FORWARDED',
        'HTTP_X_CLUSTER_CLIENT_IP',
        'HTTP_CLIENT_IP'
    ]

    for header in ip_headers:
        ip = request.headers.get(header, '')
        if ip:
            # X-Forwarded-For格式: client, proxy1, proxy2
            if ',' in ip:
                # 分割并获取第一个IP地址（真实客户端IP）
                ips = ip.split(',')
                # 验证并返回第一个有效的IP地址
                for potential_ip in ips:
                    cleaned_ip = potential_ip.strip()
                    # 验证IP格式是否有效
                    import re
                    if re.match(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$', cleaned_ip):
                        # 排除常见的内网IP地址
                        private_ips = ['127.0.0.1', '10.', '172.16.', '192.168.']
                        is_private = False
                        for private_ip in private_ips:
                            if cleaned_ip.startswith(private_ip):
                                is_private = True
                                break
                        if not is_private:
                            return cleaned_ip
                # 如果没有找到有效的公网IP，返回第一个IP
                return ips[0].strip()
            else:
                # 验证IP格式是否有效
                import re
                if re.match(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$', ip):
                    # 排除常见的内网IP地址
                    private_ips = ['127.0.0.1', '10.', '172.16.', '192.168.']
                    is_private = False
                    for private_ip in private_ips:
                        if ip.startswith(private_ip):
                            is_private = True
                            break
                    if not is_private:
                        return ip

    # 直接从请求中获取IP
    ip = request.remote_addr
    return ip or 'unknown'


# 记录用户行为
def log_user_activity(user_id, action_type, action_detail=None):
    """
    记录用户行为到数据库
    :param user_id: 用户ID
    :param action_type: 行为类型
    :param action_detail: 行为详情
    """
    try:
        ip_address = get_user_ip()
        activity = UserActivity(
            user_id=user_id,
            ip_address=ip_address,
            action_type=action_type,
            action_detail=action_detail
        )
        db.session.add(activity)
        db.session.commit()
    except Exception as e:
        print(f"记录用户行为失败: {e}")
        db.session.rollback()


# 检查是否已有管理员账号
def has_admin_account():
    """检查数据库中是否已存在管理员账号"""
    return User.query.filter_by(role='admin').first() is not None


# -------------- 密码校验工具函数 --------------
def is_valid_password(password):
    """
    验证密码是否符合规则：字母+数字组合，长度至少6位
    :param password: 待校验的密码
    :return: True-有效，False-无效
    """
    if not password:
        return False
    # 使用正则表达式校验密码格式
    return re.match(PASSWORD_PATTERN, password) is not None


def are_friends(user1_id, user2_id):
    """
    检查两个用户是否是好友
    :param user1_id: 用户1的ID
    :param user2_id: 用户2的ID
    :return: True-是好友，False-不是好友
    """
    # 检查双向好友关系
    friend1 = Friend.query.filter_by(user_id=user1_id, friend_id=user2_id).first()
    friend2 = Friend.query.filter_by(user_id=user2_id, friend_id=user1_id).first()
    return friend1 is not None and friend2 is not None


def get_friends(user_id):
    """
    获取用户的好友列表
    :param user_id: 用户ID
    :return: 好友列表
    """
    friends = []
    # 查询用户作为发起方的好友关系
    friend_relationships = Friend.query.filter_by(user_id=user_id).all()
    for relationship in friend_relationships:
        friend = db.session.get(User, relationship.friend_id)
        if friend and not friend.is_banned:
            friends.append(friend)
    return friends


def has_pending_request(sender_id, receiver_id):
    """
    检查是否有未处理的好友请求
    :param sender_id: 发送者ID
    :param receiver_id: 接收者ID
    :return: True-有未处理请求，False-没有
    """
    return FriendRequest.query.filter_by(
        sender_id=sender_id,
        receiver_id=receiver_id,
        status='pending'
    ).first() is not None


def get_received_requests(user_id):
    """
    获取用户收到的好友请求
    :param user_id: 用户ID
    :return: 好友请求列表
    """
    return FriendRequest.query.filter_by(
        receiver_id=user_id,
        status='pending'
    ).all()


# -------------- 会话验证工具函数 --------------
def is_valid_session(user):
    """
    验证当前会话是否为用户的有效会话
    :param user: 当前登录的用户对象
    :return: True-有效，False-无效
    """
    if not user:
        return False
    # 获取当前session中的会话ID
    current_session_id = session.get(SESSION_ID_KEY)
    # 验证：用户的current_session_id存在，且与当前session中的会话ID一致
    if user.current_session_id is None or current_session_id != user.current_session_id:
        return False
    # 新增：检查会话是否超时
    if user.session_created_at:
        session_age = (datetime.now() - user.session_created_at).total_seconds()
        if session_age > SESSION_TIMEOUT:
            # 会话超时，自动失效
            invalidate_user_session(user)
            return False
    return True


def invalidate_user_session(user):
    """
    使用户的当前会话失效（清空current_session_id）
    :param user: 用户对象
    """
    if user:
        user.current_session_id = None
        user.online = False
        user.session_created_at = None
        db.session.commit()


# -------------- 登录管理器回调 --------------
@login_manager.user_loader
def load_user(user_id):
    user = db.session.get(User, int(user_id))
    # 封号用户无法加载
    if user and user.is_banned:
        return None
    return user


# -------------- 全局请求拦截器：验证会话有效性 --------------
@app.before_request
def before_request():
    """
    所有请求执行前的拦截器
    对已登录的用户，验证其会话是否有效；无效则强制登出
    """
    # 排除登录、注册、初始化管理员等不需要登录的路由
    exclude_routes = ['login', 'register', 'init_admin', 'static']
    if request.endpoint in exclude_routes:
        return

    # 仅对已登录的用户进行验证
    if current_user.is_authenticated:
        # 验证会话有效性
        if not is_valid_session(current_user):
            # 会话无效，强制登出
            logout_user()
            # 清除当前session中的会话ID
            session.pop(SESSION_ID_KEY, None)
            # 重定向到登录页，并提示
            flash('您的账号已在其他设备登录，您已被强制下线', 'warning')
            return redirect(url_for('login'))


# -------------- 权限装饰器 --------------
def admin_required(f):
    """管理员权限装饰器"""
    from functools import wraps
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated or current_user.role != 'admin':
            return redirect(url_for('index'))
        return f(*args, **kwargs)

    return decorated_function


# -------------- 新增：初始化管理员账号路由 --------------
@app.route('/init_admin', methods=['GET', 'POST'])
def init_admin():
    """
    初始化管理员账号的特殊入口
    只有在没有管理员账号时才能访问，且需要验证安全密钥
    """
    # 检查是否已有管理员账号
    if has_admin_account():
        return jsonify({'code': 0, 'msg': '管理员账号已存在，无法重复创建'})

    if request.method == 'POST':
        secret_key = request.form.get('secret_key', '')
        username = request.form.get('username', '')
        password = request.form.get('password', '')

        # 验证安全密钥
        if secret_key != INIT_ADMIN_SECRET:
            return jsonify({'code': 0, 'msg': '安全密钥错误，无法创建管理员'})

        # 验证用户名和密码
        if not username or not password:
            return jsonify({'code': 0, 'msg': '用户名和密码不能为空'})

        # 新增：管理员密码也需要符合字母+数字组合规则
        if not is_valid_password(password):
            return jsonify({'code': 0, 'msg': PASSWORD_ERROR_MSG})

        # 检查用户名是否已存在
        if User.query.filter_by(username=username).first():
            return jsonify({'code': 0, 'msg': '用户名已存在'})

        # 创建管理员账号
        hashed_pwd = generate_password_hash(password, method='pbkdf2:sha256')
        admin = User(
            username=username,
            password=hashed_pwd,
            role='admin',
            is_banned=False,
            is_muted=False,
            current_session_id=None  # 初始会话ID为空
        )
        db.session.add(admin)
        db.session.commit()

        return jsonify({'code': 1, 'msg': f'管理员账号 {username} 创建成功，请登录'})

    # GET请求返回创建表单
    return render_template('init_admin.html')


# -------------- 路由修改 --------------
@app.route('/')
@login_required
def index():
    # 如果没有管理员账号，提示先创建
    if not has_admin_account() and current_user.role == 'user':
        flash('系统尚未创建管理员账号，请联系系统管理员完成初始化', 'warning')

    # 管理员跳转到管理面板
    if current_user.role == 'admin':
        return redirect(url_for('admin_panel'))
    # 普通用户检查是否禁言/封号（封号已在load_user中拦截）
    # 只显示好友列表
    friends = get_friends(current_user.id)
    # 获取收到的好友请求
    friend_requests = get_received_requests(current_user.id)
    return render_template('index.html',
                           current_user=current_user,
                           friends=friends,
                           friend_requests=friend_requests,
                           is_muted=current_user.is_muted)


# 管理员面板
@app.route('/admin/panel')
@login_required
@admin_required
def admin_panel():
    """管理员面板：查看所有用户"""
    # 记录管理后台访问行为
    log_user_activity(current_user.id, 'admin_access', '访问管理员面板')

    users = User.query.all()
    return render_template('admin_panel.html',
                           current_user=current_user,
                           users=users)


# 管理员修改用户状态（禁言/封号）
@app.route('/admin/update_user/<int:user_id>', methods=['POST'])
@login_required
@admin_required
def update_user_status(user_id):
    user = User.query.get_or_404(user_id)
    # 禁止管理员修改自己的状态
    if user.id == current_user.id:
        return jsonify({'code': 0, 'msg': '无法修改自身状态'})

    action = request.form.get('action')
    if action == 'mute':
        user.is_muted = not user.is_muted
        msg = f"用户{user.username}已{'禁言' if user.is_muted else '解除禁言'}"
    elif action == 'ban':
        user.is_banned = not user.is_banned
        # 封号同时下线，并使会话失效
        if user.is_banned:
            user.online = False
            user.current_session_id = None  # 清空会话ID，强制下线
        msg = f"用户{user.username}已{'封号' if user.is_banned else '解封'}"
    else:
        return jsonify({'code': 0, 'msg': '无效操作'})

    db.session.commit()

    # 推送用户状态更新
    user_status = {
        'is_muted': user.is_muted,
        'is_banned': user.is_banned
    }
    socketio.emit('user_status', user_status, room=str(user.id))

    # 记录管理员操作行为
    log_user_activity(current_user.id, 'admin_action', msg)

    return jsonify({'code': 1, 'msg': msg})


# 管理员修改用户密码
@app.route('/admin/change_password/<int:user_id>', methods=['POST'])
@login_required
@admin_required
def change_user_password(user_id):
    """管理员修改用户密码"""
    user = User.query.get_or_404(user_id)

    new_password = request.form.get('new_password')
    if not new_password:
        return jsonify({'code': 0, 'msg': '新密码不能为空'})

    # 验证密码格式
    if not is_valid_password(new_password):
        return jsonify({'code': 0, 'msg': PASSWORD_ERROR_MSG})

    # 更新密码
    hashed_pwd = generate_password_hash(new_password, method='pbkdf2:sha256')
    user.password = hashed_pwd
    # 密码修改后，强制用户下线
    invalidate_user_session(user)
    db.session.commit()

    msg = f"用户{user.username}的密码已修改"
    # 记录管理员操作行为
    log_user_activity(current_user.id, 'admin_action', msg)

    return jsonify({'code': 1, 'msg': msg})


# 管理员注销用户账户
@app.route('/admin/logout_user/<int:user_id>', methods=['POST'])
@login_required
@admin_required
def logout_user_account(user_id):
    """管理员注销用户账户（从数据库中删除）"""
    user = User.query.get_or_404(user_id)
    # 禁止管理员注销自己的账户
    if user.id == current_user.id:
        return jsonify({'code': 0, 'msg': '无法注销自身账户'})

    # 从数据库中删除用户
    username = user.username
    # 先删除相关的消息、好友关系等数据
    # 删除用户发送的消息
    Message.query.filter_by(sender_id=user_id).delete()
    # 删除用户接收的消息
    Message.query.filter_by(receiver_id=user_id).delete()
    # 删除用户发送的好友请求
    FriendRequest.query.filter_by(sender_id=user_id).delete()
    # 删除用户接收的好友请求
    FriendRequest.query.filter_by(receiver_id=user_id).delete()
    # 删除用户的好友关系
    Friend.query.filter_by(user_id=user_id).delete()
    Friend.query.filter_by(friend_id=user_id).delete()
    # 删除用户的行为记录
    UserActivity.query.filter_by(user_id=user_id).delete()
    # 删除用户本身
    db.session.delete(user)
    db.session.commit()

    # 重新排序用户ID
    reorder_user_ids()

    msg = f"用户{username}的账户已被注销并从数据库中删除"
    # 记录管理员操作行为
    log_user_activity(current_user.id, 'admin_action', msg)

    return jsonify({'code': 1, 'msg': msg})


# 管理员查看所有聊天记录
@app.route('/admin/view_messages/<int:user_id>')
@login_required
@admin_required
def view_all_messages(user_id):
    """查看指定用户的所有聊天记录"""
    target_user = User.query.get_or_404(user_id)
    # 记录管理后台访问行为
    log_user_activity(current_user.id, 'admin_access', f'查看用户 {target_user.username} 的聊天记录')

    # 查询该用户发送/接收的所有消息
    messages = Message.query.filter(
        (Message.sender_id == user_id) | (Message.receiver_id == user_id)
    ).order_by(Message.timestamp.desc()).all()

    # 格式化消息数据
    message_list = []
    for msg in messages:
        sender = db.session.get(User, msg.sender_id)
        receiver = db.session.get(User, msg.receiver_id)
        message_list.append({
            'id': msg.id,
            'sender': sender.username,
            'receiver': receiver.username,
            'content': msg.content,
            'file_type': msg.file_type,
            'file_path': msg.file_path,
            'timestamp': msg.timestamp.strftime('%Y-%m-%d %H:%M:%S')
        })

    return render_template('admin_messages.html',
                           current_user=current_user,
                           target_user=target_user,
                           messages=message_list)


# 管理员查看用户行为日志
@app.route('/admin/view_activities')
@login_required
@admin_required
def view_activities():
    """查看用户行为日志"""

    # ===== 防抖：30 秒内不重复记录“查看用户行为日志” =====
    last = UserActivity.query.filter_by(
        user_id=current_user.id,
        action_type='admin_access',
        action_detail='查看用户行为日志'
    ).order_by(UserActivity.id.desc()).first()

    if not last or (datetime.now() - last.created_at).total_seconds() > 30:
        log_user_activity(
            current_user.id,
            'admin_access',
            '查看用户行为日志'
        )

    # ===== 查询日志 =====
    activities = (
        UserActivity.query
        .order_by(UserActivity.id.desc())
        .limit(100)
        .all()
    )

    # ===== 格式化日志数据 =====
    activity_list = []
    for activity in activities:
        user = db.session.get(User, activity.user_id)
        activity_list.append({
            'id': activity.id,
            'username': user.username if user else '未知用户',
            'ip_address': activity.ip_address,
            'action_type': activity.action_type,
            'action_detail': activity.action_detail,
            'created_at': activity.created_at.strftime('%Y-%m-%d %H:%M:%S')
        })

    return render_template(
        'admin_activities.html',
        current_user=current_user,
        activities=activity_list
    )


# 重新排序日志ID
#def view_activities():
# 记录管理后台访问行为
#log_user_activity(current_user.id, 'admin_access', '查看用户行为日志')

# 查询所有用户行为日志，按时间倒序排列
#    activities = UserActivity.query \
#    .order_by(UserActivity.id.desc()) \
#    .limit(100) \
#    .all()

    # 格式化日志数据
#    activity_list = []
#    for activity in activities:
#        user = User.query.get(activity.user_id)
#        activity_list.append({
#            'id': activity.id,
#            'username': user.username if user else '未知用户',
#            'ip_address': activity.ip_address,
#            'action_type': activity.action_type,
#            'action_detail': activity.action_detail,
#            'created_at': activity.created_at.strftime('%Y-%m-%d %H:%M:%S')
#        })

#    return render_template('admin_activities.html',
#                           current_user=current_user,
#                           activities=activity_list)


def reorder_activity_ids():
    """
    重新排序日志ID，从1开始连续编号
    """
    try:
        # 获取所有日志，按ID升序排列
        activities = UserActivity.query.order_by(UserActivity.id).all()

        # 重新分配ID
        for i, activity in enumerate(activities, 1):
            activity.id = i

        # 提交更改
        db.session.commit()

        # 重置自增计数器
        # 使用原生SQL重置自增计数器
        from sqlalchemy import text
        db.session.execute(text("ALTER TABLE user_activities AUTO_INCREMENT = " + str(len(activities) + 1)))
        db.session.commit()

        return True
    except Exception as e:
        print(f"重新排序日志ID失败: {e}")
        db.session.rollback()
        return False


def reorder_user_ids():
    """
    重新排序用户ID，从1开始连续编号
    """
    try:
        # 获取所有用户，按ID升序排列
        users = User.query.order_by(User.id).all()

        # 重新分配ID
        for i, user in enumerate(users, 1):
            user.id = i

        # 提交更改
        db.session.commit()

        # 重置自增计数器
        # 使用原生SQL重置自增计数器
        from sqlalchemy import text
        db.session.execute(text("ALTER TABLE users AUTO_INCREMENT = " + str(len(users) + 1)))
        db.session.commit()

        return True
    except Exception as e:
        print(f"重新排序用户ID失败: {e}")
        db.session.rollback()
        return False


# 单个删除日志
@app.route('/admin/delete_activity/<int:activity_id>', methods=['POST'])
@login_required
@admin_required
def delete_activity(activity_id):
    """
    删除单个日志
    """
    try:
        # 查找并删除日志
        activity = UserActivity.query.get_or_404(activity_id)
        db.session.delete(activity)
        db.session.commit()

        # 重新排序ID
        reorder_activity_ids()

        # 记录管理员操作
        log_user_activity(current_user.id, 'admin_action', f'删除单条日志（ID: {activity_id}）')

        return jsonify({'code': 1, 'msg': '删除成功'})
    except Exception as e:
        print(f"删除日志失败: {e}")
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '删除失败'})


# 批量删除日志
@app.route('/admin/delete_activities', methods=['POST'])
@login_required
@admin_required
def delete_activities():
    """
    批量删除日志
    """
    try:
        # 获取要删除的ID列表
        # 尝试从form获取
        activity_ids = request.form.get('ids')
        if not activity_ids:
            # 尝试从json获取
            import json
            data = request.get_json()
            if data and 'ids' in data:
                activity_ids = data['ids']
            else:
                return jsonify({'code': 0, 'msg': '请选择要删除的日志'})
        else:
            # 如果是字符串形式的数组，解析它
            import json
            try:
                activity_ids = json.loads(activity_ids)
            except:
                # 尝试按逗号分割
                activity_ids = activity_ids.split(',')

        # 确保是列表
        if not isinstance(activity_ids, list):
            activity_ids = [activity_ids]

        # 转换为整数
        activity_ids = [int(id) for id in activity_ids]

        # 删除日志
        UserActivity.query.filter(UserActivity.id.in_(activity_ids)).delete(synchronize_session=False)
        db.session.commit()

        # 重新排序ID
        reorder_activity_ids()

        # 记录管理员操作
        log_user_activity(current_user.id, 'admin_action', f'批量删除日志（数量: {len(activity_ids)}）')

        return jsonify({'code': 1, 'msg': f'成功删除 {len(activity_ids)} 条日志'})
    except Exception as e:
        print(f"批量删除日志失败: {e}")
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '删除失败'})


# 清空所有日志
@app.route('/admin/clear_activities', methods=['POST'])
@login_required
@admin_required
def clear_activities():
    """
    清空所有日志
    """
    try:
        # 删除所有日志
        UserActivity.query.delete()
        db.session.commit()

        # 重置自增计数器
        from sqlalchemy import text
        db.session.execute(text("ALTER TABLE user_activities AUTO_INCREMENT = 1"))
        db.session.commit()

        # 记录管理员操作
        log_user_activity(current_user.id, 'admin_action', '清空所有日志')

        return jsonify({'code': 1, 'msg': '已清空所有日志'})
    except Exception as e:
        print(f"清空日志失败: {e}")
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '清空失败'})

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        # 如果已有用户登录，直接跳转到首页
        return redirect(url_for('index'))

    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        verify_code_input = request.form.get('verify_code', '')

        # 查询用户
        user = User.query.filter_by(username=username).first()
        if not user:
            return render_template('login.html', error='用户名不存在', show_verify=False)

        # 检查是否封号
        if user.is_banned:
            return render_template('login.html', error='该账号已被封号，无法登录', show_verify=False)

        # 检查临时锁定
        if is_user_locked(user):
            remain_time = (user.lock_time + timedelta(minutes=1) - datetime.now()).seconds
            return render_template('login.html', error=f'账号已锁定，请{remain_time}秒后重试', show_verify=False)

        # 验证码验证逻辑
        if user.login_attempts >= 3:
            if not verify_code_input or verify_code_input != user.verify_code:
                user.login_attempts += 1
                if user.login_attempts >= 5:
                    user.lock_time = datetime.now()
                    db.session.commit()
                    return render_template('login.html', error='验证码错误，账号已锁定1分钟', show_verify=False)
                user.verify_code = generate_verify_code()
                db.session.commit()
                return render_template('login.html', error='验证码错误，请重新输入', verify_code=user.verify_code,
                                       show_verify=True)

            # 验证码正确，验证密码
            if check_password_hash(user.password, password):
                # -------------- 关键修改：登录成功，生成新的会话ID，更新用户的current_session_id --------------
                new_session_id = generate_session_id()
                # 更新用户记录：新的会话ID、在线状态、登录设备、最后登录时间、会话创建时间
                user.login_attempts = 0
                user.verify_code = None
                user.online = True
                user.login_device = get_login_device()
                user.last_login_time = datetime.now()
                user.session_created_at = datetime.now()  # 设置会话创建时间
                user.current_session_id = new_session_id  # 覆盖旧的会话ID，使旧会话失效
                db.session.commit()

                # 记录登录成功行为
                log_user_activity(user.id, 'login', f'登录成功，设备: {user.login_device}')

                # 登录用户，并设置session持久化
                login_user(user, remember=False)  # 关闭remember，确保会话随浏览器关闭失效
                # 将新的会话ID存入当前session
                session[SESSION_ID_KEY] = new_session_id

                flash(f'登录成功！您的账号当前仅允许此设备登录', 'success')
                return redirect(url_for('index'))
            else:
                user.login_attempts += 1
                if user.login_attempts >= 5:
                    user.lock_time = datetime.now()
                    db.session.commit()
                    return render_template('login.html', error='密码错误，账号已锁定1分钟', show_verify=False)
                user.verify_code = generate_verify_code()
                db.session.commit()
                return render_template('login.html', error='密码错误，请重新输入', verify_code=user.verify_code,
                                       show_verify=True)
        else:
            # 无验证码，直接验证密码
            if check_password_hash(user.password, password):
                # -------------- 关键修改：登录成功，生成新的会话ID，更新用户的current_session_id --------------
                new_session_id = generate_session_id()
                # 更新用户记录：新的会话ID、在线状态、登录设备、最后登录时间、会话创建时间
                user.login_attempts = 0
                user.verify_code = None
                user.online = True
                user.login_device = get_login_device()
                user.last_login_time = datetime.now()
                user.session_created_at = datetime.now()  # 设置会话创建时间
                user.current_session_id = new_session_id  # 覆盖旧的会话ID，使旧会话失效
                db.session.commit()

                # 记录登录成功行为
                log_user_activity(user.id, 'login', f'登录成功，设备: {user.login_device}')

                # 登录用户，并设置session持久化
                login_user(user, remember=False)  # 关闭remember，确保会话随浏览器关闭失效
                # 将新的会话ID存入当前session
                session[SESSION_ID_KEY] = new_session_id

                flash(f'登录成功！您的账号当前仅允许此设备登录', 'success')
                return redirect(url_for('index'))
            else:
                user.login_attempts += 1
                db.session.commit()
                if user.login_attempts >= 3:
                    user.verify_code = generate_verify_code()
                    db.session.commit()
                    return render_template('login.html', error=f'密码错误（{user.login_attempts}/5），请输入验证码',
                                           verify_code=user.verify_code, show_verify=True)
                return render_template('login.html', error=f'密码错误（{user.login_attempts}/5）', show_verify=False)

    return render_template('login.html', error='', show_verify=False)


# -------------- 核心修改：注册路由添加密码格式校验 --------------
@app.route('/register', methods=['GET', 'POST'])
def register():
    # 禁止注册管理员账号
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        confirm_password = request.form['confirm_password']

        # 1. 检查用户名是否为管理员预留名
        if username == 'Administrator':
            return render_template('register.html', error='禁止注册该用户名')

        # 2. 检查用户名是否已存在
        if User.query.filter_by(username=username).first():
            return render_template('register.html', error='用户名已存在')

        # 3. 检查两次密码是否一致
        if password != confirm_password:
            return render_template('register.html', error='两次输入的密码不一致')

        # 4. 新增：密码格式校验
        if not is_valid_password(password):
            return render_template('register.html', error=PASSWORD_ERROR_MSG)

        # 4. 密码符合规则，创建用户
        hashed_pwd = generate_password_hash(password, method='pbkdf2:sha256')
        new_user = User(
            username=username,
            password=hashed_pwd,
            current_session_id=None  # 初始会话ID为空
        )
        db.session.add(new_user)
        db.session.commit()

        flash('注册成功，请登录', 'success')
        return redirect(url_for('login'))

    return render_template('register.html', error='')


@app.route('/logout')
@login_required
def logout():
    # 记录登出行为
    log_user_activity(current_user.id, 'logout', '用户主动登出')

    # -------------- 关键修改：登出时，清空用户的current_session_id，使所有会话失效 --------------
    invalidate_user_session(current_user)
    # 清除当前session中的会话ID
    session.pop(SESSION_ID_KEY, None)
    # 登出用户
    logout_user()
    flash('您已成功登出', 'info')
    return redirect(url_for('login'))


@app.route('/friend/request/<int:receiver_id>', methods=['POST'])
@login_required
def send_friend_request(receiver_id):
    """
    发送好友请求
    :param receiver_id: 接收者的用户ID
    :return: JSON响应
    """
    # 不能向自己发送请求
    if receiver_id == current_user.id:
        return jsonify({'code': 0, 'msg': '不能向自己发送好友请求'})

    # 检查用户是否存在
    receiver = db.session.get(User, receiver_id)
    if not receiver or receiver.is_banned:
        return jsonify({'code': 0, 'msg': '用户不存在或已被封号'})

    # 检查是否已经是好友
    if are_friends(current_user.id, receiver_id):
        return jsonify({'code': 0, 'msg': '已经是好友'})

    # 检查是否有未处理的请求
    if has_pending_request(current_user.id, receiver_id):
        return jsonify({'code': 0, 'msg': '好友请求已发送，请等待对方响应'})

    # 发送好友请求
    try:
        request = FriendRequest(
            sender_id=current_user.id,
            receiver_id=receiver_id,
            status='pending'
        )
        db.session.add(request)
        db.session.commit()
        return jsonify({'code': 1, 'msg': '好友请求已发送，请等待对方响应'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '发送好友请求失败'})


@app.route('/friend/request/<int:request_id>/<action>', methods=['POST'])
@login_required
def handle_friend_request(request_id, action):
    """
    处理好友请求
    :param request_id: 请求ID
    :param action: 操作类型（accept, reject）
    :return: JSON响应
    """
    # 验证操作类型
    if action not in ['accept', 'reject']:
        return jsonify({'code': 0, 'msg': '无效的操作类型'})

    # 查找请求
    request = db.session.get(FriendRequest, request_id)
    if not request:
        return jsonify({'code': 0, 'msg': '好友请求不存在'})

    # 验证请求接收者
    if request.receiver_id != current_user.id:
        return jsonify({'code': 0, 'msg': '无权处理此好友请求'})

    # 验证请求状态
    if request.status != 'pending':
        return jsonify({'code': 0, 'msg': '好友请求已处理'})

    try:
        if action == 'accept':
            # 接受请求，创建好友关系
            request.status = 'accepted'
            # 创建双向好友关系
            friendship1 = Friend(user_id=request.sender_id, friend_id=request.receiver_id)
            friendship2 = Friend(user_id=request.receiver_id, friend_id=request.sender_id)
            db.session.add(friendship1)
            db.session.add(friendship2)
            db.session.commit()
            return jsonify({'code': 1, 'msg': '已接受好友请求'})
        else:
            # 拒绝请求
            request.status = 'rejected'
            db.session.commit()
            return jsonify({'code': 1, 'msg': '已拒绝好友请求'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '处理好友请求失败'})


@app.route('/friend/remove/<int:friend_id>', methods=['POST'])
@login_required
def remove_friend(friend_id):
    """
    删除好友
    :param friend_id: 好友的用户ID
    :return: JSON响应
    """
    # 检查是否是好友
    if not are_friends(current_user.id, friend_id):
        return jsonify({'code': 0, 'msg': '不是好友关系'})

    # 删除好友关系（双向）
    try:
        # 删除用户对对方的好友关系
        Friend.query.filter_by(user_id=current_user.id, friend_id=friend_id).delete()
        # 删除对方对用户的好友关系
        Friend.query.filter_by(user_id=friend_id, friend_id=current_user.id).delete()
        db.session.commit()
        return jsonify({'code': 1, 'msg': '删除好友成功'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'code': 0, 'msg': '删除好友失败'})


@app.route('/session/heartbeat')
@login_required
def session_heartbeat():
    """
    会话心跳检测，保持会话活跃状态
    前端定期调用此接口，更新会话创建时间
    """
    if is_valid_session(current_user):
        # 更新会话创建时间，重置超时计时器
        current_user.session_created_at = datetime.now()
        db.session.commit()
        return jsonify({'code': 1, 'msg': '会话保持活跃'})
    else:
        return jsonify({'code': 0, 'msg': '会话已失效'})





@app.route('/search_user')
@login_required
def search_user():
    """
    搜索用户
    :return: JSON响应，包含匹配的非好友用户列表
    """
    keyword = request.args.get('keyword', '').strip()
    if not keyword:
        return jsonify({'code': 0, 'msg': '请输入搜索关键词'})

    # 搜索用户名包含关键词的用户
    matched_users = User.query.filter(
        User.username.like(f'%{keyword}%'),
        User.id != current_user.id,
        User.is_banned == False
    ).all()

    # 只显示非好友用户
    non_friends = []

    for user in matched_users:
        if not are_friends(current_user.id, user.id):
            # 检查是否有未处理的好友请求
            has_pending = has_pending_request(current_user.id, user.id)
            non_friends.append({
                'id': user.id,
                'username': user.username,
                'online': user.online,
                'has_pending_request': has_pending
            })

    return jsonify({
        'code': 1,
        'msg': f'找到{len(non_friends)}个用户',
        'data': {
            'non_friends': non_friends
        }
    })


@app.route('/search_all_messages')
@login_required
def search_all_messages():
    """
    搜索所有聊天记录
    :return: JSON响应，包含匹配的聊天记录
    """
    keyword = request.args.get('keyword', '').strip()
    if not keyword:
        return jsonify({'code': 0, 'msg': '请输入搜索关键词', 'data': []})

    # 搜索所有好友的聊天记录
    friends = get_friends(current_user.id)
    friend_ids = [friend.id for friend in friends]

    # 搜索与好友的聊天记录
    messages = Message.query.filter(
        ((Message.sender_id == current_user.id) & (Message.receiver_id.in_(friend_ids))) |
        ((Message.sender_id.in_(friend_ids)) & (Message.receiver_id == current_user.id)),
        Message.content.like(f'%{keyword}%')
    ).order_by(Message.timestamp.desc()).all()

    # 格式化消息数据
    message_list = []
    for msg in messages:
        sender = db.session.get(User, msg.sender_id)
        receiver = db.session.get(User, msg.receiver_id)
        message_list.append({
            'id': msg.id,
            'sender_id': msg.sender_id,
            'receiver_id': msg.receiver_id,
            'sender_name': sender.username,
            'receiver_name': receiver.username,
            'content': msg.content,
            'file_type': msg.file_type,
            'file_path': msg.file_path,
            'timestamp': msg.timestamp.strftime('%Y-%m-%d %H:%M:%S')
        })

    return jsonify({
        'code': 1,
        'msg': f'找到{len(message_list)}条聊天记录',
        'data': message_list
    })


# -------------- 文件上传接口 --------------
@app.route('/upload_file', methods=['POST'])
@login_required
def upload_file():
    # 禁言/封号用户禁止上传文件
    if current_user.is_muted or current_user.is_banned:
        return jsonify({'code': 0, 'msg': '您无权限上传文件'})

    if 'file' not in request.files:
        return jsonify({'code': 0, 'msg': '未选择文件'})

    file = request.files['file']
    if file.filename == '':
        return jsonify({'code': 0, 'msg': '文件名为空'})

    file_ext = file.filename.rsplit('.', 1)[1].lower()
    file_size = len(file.read())
    file.seek(0)

    file_type = None
    max_size = 0
    if allowed_file(file.filename, ALLOWED_IMAGE_EXTENSIONS):
        file_type = 'image'
        max_size = MAX_IMAGE_SIZE
    elif allowed_file(file.filename, ALLOWED_AUDIO_EXTENSIONS):
        file_type = 'audio'
        max_size = MAX_AUDIO_SIZE
    else:
        return jsonify({'code': 0,
                        'msg': f'不支持的文件格式，仅支持图片({",".join(ALLOWED_IMAGE_EXTENSIONS)})和音频({",".join(ALLOWED_AUDIO_EXTENSIONS)})'})

    if file_size > max_size:
        return jsonify({'code': 0, 'msg': f'文件过大，{file_type}最大支持{max_size // 1024 // 1024}MB'})

    unique_filename = str(uuid.uuid4()) + '.' + file_ext
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
    file.save(file_path)

    # 记录文件上传行为
    log_user_activity(current_user.id, 'upload_file', f'上传{file_type}文件: {unique_filename}')

    relative_path = f'/static/uploads/{unique_filename}'
    return jsonify({'code': 1, 'msg': '文件上传成功', 'data': {'file_type': file_type, 'file_path': relative_path}})


# -------------- 消息接口 --------------
@app.route('/get_messages/<int:receiver_id>')
@login_required
def get_messages(receiver_id):
    # 检查是否是好友
    if not are_friends(current_user.id, receiver_id):
        return jsonify([])

    # 禁言用户仅能查看消息，无法发送
    messages = Message.query.filter(
        ((Message.sender_id == current_user.id) & (Message.receiver_id == receiver_id)) |
        ((Message.sender_id == receiver_id) & (Message.receiver_id == current_user.id))
    ).order_by(Message.timestamp).all()

    message_list = []
    for msg in messages:
        message_list.append({
            'sender': msg.sender.username,
            'sender_id': msg.sender_id,
            'content': msg.content,
            'file_type': msg.file_type,
            'file_path': msg.file_path,
            'timestamp': msg.timestamp.strftime('%Y-%m-%d %H:%M')
        })
    return jsonify(message_list)


@app.route('/search_messages/<int:receiver_id>', methods=['GET'])
@login_required
def search_messages(receiver_id):
    # 检查是否是好友
    if not are_friends(current_user.id, receiver_id):
        return jsonify({'code': 0, 'msg': '只有好友之间才能搜索消息', 'data': []})

    keyword = request.args.get('keyword', '').strip()
    if not keyword:
        return jsonify({'code': 0, 'msg': '请输入搜索关键词', 'data': []})

    messages = Message.query.filter(
        ((Message.sender_id == current_user.id) & (Message.receiver_id == receiver_id)) |
        ((Message.sender_id == receiver_id) & (Message.receiver_id == current_user.id)),
        Message.content.like(f'%{keyword}%')
    ).order_by(Message.timestamp).all()

    message_list = []
    for msg in messages:
        message_list.append({
            'sender': msg.sender.username,
            'sender_id': msg.sender_id,
            'content': msg.content,
            'file_type': msg.file_type,
            'file_path': msg.file_path,
            'timestamp': msg.timestamp.strftime('%Y-%m-%d %H:%M')
        })
    return jsonify({'code': 1, 'msg': f'找到{len(message_list)}条结果', 'data': message_list})


@app.route('/clear_messages/<int:receiver_id>', methods=['POST'])
@login_required
def clear_messages(receiver_id):
    # 检查是否是好友
    if not are_friends(current_user.id, receiver_id):
        return jsonify({'code': 0, 'msg': '只有好友之间才能清空消息'})

    Message.query.filter(
        ((Message.sender_id == current_user.id) & (Message.receiver_id == receiver_id)) |
        ((Message.sender_id == receiver_id) & (Message.receiver_id == current_user.id))
    ).delete()
    db.session.commit()
    return jsonify({'code': 1, 'msg': '聊天记录已清空'})





# -------------- SocketIO --------------
@socketio.on('connect')
@login_required
def handle_connect():
    # -------------- 关键修改：验证SocketIO连接的会话有效性 --------------
    if not is_valid_session(current_user):
        emit('connect_error', {'msg': '您的账号已在其他设备登录，无法建立连接'})
        return

    # 禁言/封号用户禁止连接
    if current_user.is_muted or current_user.is_banned:
        emit('connect_error', {'msg': '您无权限连接聊天'})
        return
    print(f'用户 {current_user.username} 已连接')
    join_room(str(current_user.id))
    # 推送用户状态
    user_status = {
        'is_muted': current_user.is_muted,
        'is_banned': current_user.is_banned
    }
    emit('user_status', user_status, room=str(current_user.id))


@socketio.on('send_text_message')
@login_required
def handle_send_text_message(data):
    # -------------- 关键修改：验证会话有效性 --------------
    if not is_valid_session(current_user):
        emit('message_error', {'msg': '您的账号已在其他设备登录，无法发送消息'})
        return

    # 禁言/封号用户禁止发送消息
    if current_user.is_muted or current_user.is_banned:
        emit('message_error', {'msg': '您已被禁言/封号，无法发送消息'})
        return

    receiver_id = data['receiver_id']
    # 检查是否是好友
    if not are_friends(current_user.id, receiver_id):
        emit('message_error', {'msg': '只有好友之间才能发送消息'})
        return

    content = data['content'].strip()
    if not content:
        return

    # 再次检查用户状态，确保在发送过程中没有被禁言或封号
    user = db.session.get(User, current_user.id)
    if user.is_muted or user.is_banned:
        emit('message_error', {'msg': '您已被禁言/封号，无法发送消息'})
        return

    new_message = Message(
        sender_id=current_user.id,
        receiver_id=receiver_id,
        content=content,
        file_type=None,
        file_path=None
    )
    db.session.add(new_message)
    db.session.commit()

    # 记录发送消息行为
    receiver = db.session.get(User, receiver_id)
    log_user_activity(current_user.id, 'send_message', f'发送文本消息给 {receiver.username}')

    message_data = {
        'sender': current_user.username,
        'sender_id': current_user.id,
        'content': content,
        'file_type': None,
        'file_path': None,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M')
    }
    emit('receive_message', message_data, room=str(receiver_id))
    emit('receive_message', message_data, room=str(current_user.id))


@socketio.on('send_file_message')
@login_required
def handle_send_file_message(data):
    # -------------- 关键修改：验证会话有效性 --------------
    if not is_valid_session(current_user):
        emit('message_error', {'msg': '您的账号已在其他设备登录，无法发送文件'})
        return

    # 禁言/封号用户禁止发送文件
    if current_user.is_muted or current_user.is_banned:
        emit('message_error', {'msg': '您已被禁言/封号，无法发送文件'})
        return

    receiver_id = data['receiver_id']
    # 检查是否是好友
    if not are_friends(current_user.id, receiver_id):
        emit('message_error', {'msg': '只有好友之间才能发送文件'})
        return

    file_type = data['file_type']
    file_path = data['file_path']

    # 再次检查用户状态，确保在发送过程中没有被禁言或封号
    user = db.session.get(User, current_user.id)
    if user.is_muted or user.is_banned:
        emit('message_error', {'msg': '您已被禁言/封号，无法发送文件'})
        return

    new_message = Message(
        sender_id=current_user.id,
        receiver_id=receiver_id,
        content=None,
        file_type=file_type,
        file_path=file_path
    )
    db.session.add(new_message)
    db.session.commit()

    # 记录发送文件消息行为
    receiver = db.session.get(User, receiver_id)
    log_user_activity(current_user.id, 'send_file', f'发送{file_type}文件给 {receiver.username}')

    message_data = {
        'sender': current_user.username,
        'sender_id': current_user.id,
        'content': None,
        'file_type': file_type,
        'file_path': file_path,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M')
    }
    emit('receive_message', message_data, room=str(receiver_id))
    emit('receive_message', message_data, room=str(current_user.id))


@socketio.on('disconnect')
@login_required
def handle_disconnect():
    print(f'用户 {current_user.username} 已断开连接')
    # 标记在线状态为False
    current_user.online = False
    db.session.commit()
    leave_room(str(current_user.id))


# -------------- 初始化数据库 --------------
with app.app_context():
    # 先删除现有表，再重新创建（解决字段缺失问题）
    db.create_all()
    # 移除自动创建管理员账号的逻辑
    print("MySQL数据库表初始化完成！")

# -------------- 修改用户信息接口 --------------
@app.route('/update_username', methods=['POST'])
@login_required
def update_username():
    """
    修改用户名
    :return: JSON响应
    """
    new_username = request.form.get('username', '').strip()
    if not new_username:
        return jsonify({'code': 0, 'msg': '请输入新用户名'})

    # 检查用户名是否已存在
    existing_user = User.query.filter_by(username=new_username).first()
    if existing_user and existing_user.id != current_user.id:
        return jsonify({'code': 0, 'msg': '用户名已存在'})

    # 更新用户名
    current_user.username = new_username
    db.session.commit()

    # 记录操作
    log_user_activity(current_user.id, 'update_username', f'修改用户名为 {new_username}')

    return jsonify({'code': 1, 'msg': '用户名修改成功'})

@app.route('/update_avatar', methods=['POST'])
@login_required
def update_avatar():
    """
    修改头像
    :return: JSON响应
    """
    if 'avatar' not in request.files:
        return jsonify({'code': 0, 'msg': '未选择文件'})

    file = request.files['avatar']
    if file.filename == '':
        return jsonify({'code': 0, 'msg': '文件名为空'})

    # 检查文件类型
    if not allowed_file(file.filename, ALLOWED_IMAGE_EXTENSIONS):
        return jsonify({'code': 0, 'msg': f'不支持的文件格式，仅支持图片({",".join(ALLOWED_IMAGE_EXTENSIONS)})'})

    # 检查文件大小
    file_size = len(file.read())
    file.seek(0)
    if file_size > MAX_IMAGE_SIZE:
        return jsonify({'code': 0, 'msg': f'文件过大，最大支持{MAX_IMAGE_SIZE // 1024 // 1024}MB'})

    # 保存文件
    unique_filename = str(uuid.uuid4()) + '.' + file.filename.rsplit('.', 1)[1].lower()
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
    file.save(file_path)

    # 更新用户头像路径
    current_user.avatar = f'/static/uploads/{unique_filename}'
    db.session.commit()

    # 记录操作
    log_user_activity(current_user.id, 'update_avatar', f'更新头像: {unique_filename}')

    return jsonify({'code': 1, 'msg': '头像更新成功'})


# -------------- 运行应用 --------------
if __name__ == '__main__':
    socketio.run(app, debug=True, host='0.0.0.0', port=8000)
