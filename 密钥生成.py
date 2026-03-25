import os
# 生成24字节（192位）的随机字节，再转为十六进制字符串（更易读）
print(os.urandom(24).hex())
# 生成32字节的密钥（更安全）
print(os.urandom(32).hex())