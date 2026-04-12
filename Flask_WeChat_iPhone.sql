-- MySQL dump 10.13  Distrib 8.0.32, for Win64 (x86_64)
--
-- Host: localhost    Database: wechat_chat
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `friend_requests`
--

DROP TABLE IF EXISTS `friend_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`),
  CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_requests`
--

LOCK TABLES `friend_requests` WRITE;
/*!40000 ALTER TABLE `friend_requests` DISABLE KEYS */;
INSERT INTO `friend_requests` VALUES (1,2,3,'accepted',NULL);
/*!40000 ALTER TABLE `friend_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friends`
--

DROP TABLE IF EXISTS `friends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friends` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `friend_id` int NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `friend_id` (`friend_id`),
  CONSTRAINT `friends_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friends_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friends`
--

LOCK TABLES `friends` WRITE;
/*!40000 ALTER TABLE `friends` DISABLE KEYS */;
INSERT INTO `friends` VALUES (1,2,3,'2026-04-08 10:46:18'),(2,3,2,'2026-04-08 10:46:18');
/*!40000 ALTER TABLE `friends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci,
  `file_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (18,2,3,'你好，我喜欢你',NULL,NULL,'2026-04-08 15:52:21'),(19,2,3,'可以给我一个追你的机会嘛',NULL,NULL,'2026-04-08 15:52:21'),(20,2,3,'不行不行',NULL,NULL,'2026-04-08 15:52:21'),(21,2,3,'我不喜欢你',NULL,NULL,'2026-04-08 15:52:21'),(22,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(23,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(24,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(25,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(26,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(27,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(28,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(29,2,3,'1',NULL,NULL,'2026-04-08 16:36:16'),(30,2,3,'你好呀',NULL,NULL,'2026-04-08 17:01:35'),(31,2,3,'空间和空间',NULL,NULL,'2026-04-08 17:12:04'),(32,2,3,'将苦瓜hi金桂苑',NULL,NULL,'2026-04-08 17:12:04'),(33,2,3,'爱上发达的省份',NULL,NULL,'2026-04-08 17:16:10'),(34,2,3,'阿斯顿v阿斯旺',NULL,NULL,'2026-04-08 17:16:10');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activities` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` int NOT NULL COMMENT '关联的用户ID',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '访问者IP地址',
  `action_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型（如：login, upload, delete）',
  `action_detail` text COLLATE utf8mb4_unicode_ci COMMENT '详细描述或JSON数据',
  `created_at` datetime NOT NULL COMMENT '记录生成时间',
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '浏览器终端信息',
  `request_path` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '访问的URL路径',
  `method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '请求方式（GET, POST等）',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activities`
--

LOCK TABLES `user_activities` WRITE;
/*!40000 ALTER TABLE `user_activities` DISABLE KEYS */;
INSERT INTO `user_activities` VALUES (1,1,'127.0.0.1','admin_action','清空所有日志','2026-02-21 18:55:25',NULL,NULL,NULL),(2,1,'127.0.0.1','admin_access','查看用户行为日志','2026-02-21 18:55:26',NULL,NULL,NULL),(3,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-02-21 19:06:22',NULL,NULL,NULL),(4,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:06:22',NULL,NULL,NULL),(5,1,'127.0.0.1','admin_access','查看用户行为日志','2026-02-21 19:06:24',NULL,NULL,NULL),(6,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:07:05',NULL,NULL,NULL),(7,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:07:21',NULL,NULL,NULL),(8,1,'127.0.0.1','admin_action','用户刘浪辉的密码已修改','2026-02-21 19:07:28',NULL,NULL,NULL),(9,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:07:29',NULL,NULL,NULL),(11,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:07:41',NULL,NULL,NULL),(12,1,'127.0.0.1','admin_access','查看用户行为日志','2026-02-21 19:07:43',NULL,NULL,NULL),(13,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-02-21 19:32:01',NULL,NULL,NULL),(14,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:32:01',NULL,NULL,NULL),(15,1,'127.0.0.1','admin_access','查看用户行为日志','2026-02-21 19:32:07',NULL,NULL,NULL),(16,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:43:20',NULL,NULL,NULL),(17,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:43:41',NULL,NULL,NULL),(18,1,'127.0.0.1','admin_access','访问管理员面板','2026-02-21 19:46:02',NULL,NULL,NULL),(19,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 19:48:27',NULL,NULL,NULL),(20,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:48:27',NULL,NULL,NULL),(21,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 19:55:27',NULL,NULL,NULL),(22,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:55:27',NULL,NULL,NULL),(23,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:55:44',NULL,NULL,NULL),(24,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:55:55',NULL,NULL,NULL),(25,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:56:03',NULL,NULL,NULL),(26,1,'127.0.0.1','admin_action','用户刘浪辉的账户已被注销并从数据库中删除','2026-03-10 19:56:16',NULL,NULL,NULL),(27,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:56:18',NULL,NULL,NULL),(28,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 19:59:21',NULL,NULL,NULL),(29,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:59:21',NULL,NULL,NULL),(30,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 19:59:55',NULL,NULL,NULL),(31,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 19:59:55',NULL,NULL,NULL),(32,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 20:01:58',NULL,NULL,NULL),(33,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:01:58',NULL,NULL,NULL),(34,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 20:04:45',NULL,NULL,NULL),(35,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:04:45',NULL,NULL,NULL),(36,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:04:48',NULL,NULL,NULL),(37,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:04:54',NULL,NULL,NULL),(38,1,'127.0.0.1','logout','用户主动登出','2026-03-10 20:04:56',NULL,NULL,NULL),(39,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 20:05:38',NULL,NULL,NULL),(40,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:05:38',NULL,NULL,NULL),(41,1,'127.0.0.1','admin_action','用户LLL的账户已被注销并从数据库中删除','2026-03-10 20:05:43',NULL,NULL,NULL),(42,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:05:44',NULL,NULL,NULL),(43,1,'127.0.0.1','admin_action','用户1已封号','2026-03-10 20:05:51',NULL,NULL,NULL),(44,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:05:52',NULL,NULL,NULL),(45,1,'127.0.0.1','admin_action','用户1已解封','2026-03-10 20:05:53',NULL,NULL,NULL),(46,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:05:54',NULL,NULL,NULL),(47,1,'127.0.0.1','admin_action','用户1的账户已被注销并从数据库中删除','2026-03-10 20:05:57',NULL,NULL,NULL),(48,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:05:58',NULL,NULL,NULL),(49,1,'127.0.0.1','admin_action','用户2的账户已被注销并从数据库中删除','2026-03-10 20:06:00',NULL,NULL,NULL),(50,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:06:01',NULL,NULL,NULL),(51,1,'127.0.0.1','admin_action','用户qwert12345的账户已被注销并从数据库中删除','2026-03-10 20:06:03',NULL,NULL,NULL),(52,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:06:04',NULL,NULL,NULL),(53,1,'127.0.0.1','logout','用户主动登出','2026-03-10 20:06:10',NULL,NULL,NULL),(54,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 20:10:06',NULL,NULL,NULL),(55,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:10:06',NULL,NULL,NULL),(56,1,'127.0.0.1','logout','用户主动登出','2026-03-10 20:10:08',NULL,NULL,NULL),(57,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-10 20:11:03',NULL,NULL,NULL),(58,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:11:03',NULL,NULL,NULL),(59,1,'127.0.0.1','admin_action','用户3qwe的账户已被注销并从数据库中删除','2026-03-10 20:11:10',NULL,NULL,NULL),(60,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:11:12',NULL,NULL,NULL),(61,1,'127.0.0.1','admin_action','用户3的账户已被注销并从数据库中删除','2026-03-10 20:11:22',NULL,NULL,NULL),(62,1,'127.0.0.1','admin_access','访问管理员面板','2026-03-10 20:11:23',NULL,NULL,NULL),(63,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 10:43:19',NULL,NULL,NULL),(64,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 10:43:19',NULL,NULL,NULL),(65,1,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 10:44:07',NULL,NULL,NULL),(66,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 10:44:07',NULL,NULL,NULL),(67,1,'192.168.1.9','admin_access','查看用户行为日志','2026-04-08 10:44:10',NULL,NULL,NULL),(68,1,'192.168.1.9','logout','用户主动登出','2026-04-08 10:44:17',NULL,NULL,NULL),(69,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 10:44:38',NULL,NULL,NULL),(70,3,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 10:46:53',NULL,NULL,NULL),(71,3,'127.0.0.1','logout','用户主动登出','2026-04-08 11:04:16',NULL,NULL,NULL),(72,3,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:04:55',NULL,NULL,NULL),(73,2,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 11:19:23',NULL,NULL,NULL),(74,3,'192.168.1.9','logout','用户主动登出','2026-04-08 11:24:57',NULL,NULL,NULL),(75,1,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:25:09',NULL,NULL,NULL),(76,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 11:25:10',NULL,NULL,NULL),(77,1,'192.168.1.9','admin_access','查看用户行为日志','2026-04-08 11:25:11',NULL,NULL,NULL),(78,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 11:25:12',NULL,NULL,NULL),(79,1,'192.168.1.9','logout','用户主动登出','2026-04-08 11:25:13',NULL,NULL,NULL),(80,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:25:19',NULL,NULL,NULL),(81,2,'192.168.1.9','logout','用户主动登出','2026-04-08 11:25:22',NULL,NULL,NULL),(82,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:28:09',NULL,NULL,NULL),(83,2,'192.168.1.9','logout','用户主动登出','2026-04-08 11:28:12',NULL,NULL,NULL),(84,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:31:22',NULL,NULL,NULL),(85,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:46:32',NULL,NULL,NULL),(86,2,'192.168.1.9','update_avatar','更新头像: 8a766661-8929-432d-9f0e-111bfaa9040c.png','2026-04-08 11:46:43',NULL,NULL,NULL),(87,2,'192.168.1.9','update_username','修改用户名为 测试一','2026-04-08 11:46:55',NULL,NULL,NULL),(88,2,'192.168.1.9','logout','用户主动登出','2026-04-08 11:47:04',NULL,NULL,NULL),(89,3,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:47:24',NULL,NULL,NULL),(90,3,'192.168.1.9','logout','用户主动登出','2026-04-08 11:53:25',NULL,NULL,NULL),(91,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 11:53:33',NULL,NULL,NULL),(92,2,'192.168.1.9','update_avatar','更新头像: e3b8d8c7-96fa-403a-a97b-f88264663052.png','2026-04-08 11:58:24',NULL,NULL,NULL),(93,2,'192.168.1.9','update_username','修改用户名为 测试一','2026-04-08 12:04:09',NULL,NULL,NULL),(94,3,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 12:08:21',NULL,NULL,NULL),(95,2,'192.168.1.9','upload_file','上传image文件: 80cdd1be-27ff-4383-a925-1ad1d91e907f.png','2026-04-08 12:18:25',NULL,NULL,NULL),(96,2,'192.168.1.9','send_file','发送image文件给 2','2026-04-08 12:18:26',NULL,NULL,NULL),(97,2,'192.168.1.9','logout','用户主动登出','2026-04-08 12:18:50',NULL,NULL,NULL),(98,3,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 12:18:57',NULL,NULL,NULL),(99,3,'192.168.1.9','logout','用户主动登出','2026-04-08 12:19:05',NULL,NULL,NULL),(100,1,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 12:19:13',NULL,NULL,NULL),(101,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 12:19:13',NULL,NULL,NULL),(102,1,'192.168.1.9','admin_access','查看用户 测试一 的聊天记录','2026-04-08 12:19:21',NULL,NULL,NULL),(103,1,'192.168.1.9','admin_access','查看用户 2 的聊天记录','2026-04-08 12:19:26',NULL,NULL,NULL),(104,3,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 12:43:15',NULL,NULL,NULL),(105,3,'192.168.1.9','send_message','发送文本消息给 测试一','2026-04-08 12:48:42',NULL,NULL,NULL),(106,3,'192.168.1.9','send_message','发送文本消息给 测试一','2026-04-08 12:49:00',NULL,NULL,NULL),(107,3,'192.168.1.9','update_avatar','更新头像: 74b25607-a67a-49ee-a779-1c25841e5bee.png','2026-04-08 12:57:55',NULL,NULL,NULL),(108,3,'192.168.1.9','logout','用户主动登出','2026-04-08 13:06:04',NULL,NULL,NULL),(109,1,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 13:06:23',NULL,NULL,NULL),(110,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 13:06:23',NULL,NULL,NULL),(111,1,'192.168.1.9','admin_access','查看用户行为日志','2026-04-08 13:06:26',NULL,NULL,NULL),(112,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 13:06:35',NULL,NULL,NULL),(113,1,'192.168.1.9','admin_access','查看用户 测试一 的聊天记录','2026-04-08 13:06:38',NULL,NULL,NULL),(114,1,'192.168.1.9','admin_access','访问管理员面板','2026-04-08 13:06:40',NULL,NULL,NULL),(115,1,'192.168.1.9','admin_access','查看用户 2 的聊天记录','2026-04-08 13:06:43',NULL,NULL,NULL),(116,1,'192.168.1.9','logout','用户主动登出','2026-04-08 13:06:55',NULL,NULL,NULL),(117,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 13:07:12',NULL,NULL,NULL),(118,2,'192.168.1.9','change_password','修改密码','2026-04-08 13:12:32',NULL,NULL,NULL),(119,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 13:21:04',NULL,NULL,NULL),(120,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:21:04',NULL,NULL,NULL),(121,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:29:46',NULL,NULL,NULL),(122,1,'127.0.0.1','admin_action','查看用户测试一的密码','2026-04-08 13:29:50',NULL,NULL,NULL),(123,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:30:14',NULL,NULL,NULL),(124,1,'127.0.0.1','admin_action','查看用户测试一的密码','2026-04-08 13:30:17',NULL,NULL,NULL),(125,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:30:29',NULL,NULL,NULL),(126,1,'127.0.0.1','logout','用户主动登出','2026-04-08 13:30:31',NULL,NULL,NULL),(127,1,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 13:30:46',NULL,NULL,NULL),(128,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:30:46',NULL,NULL,NULL),(129,1,'127.0.0.1','admin_action','查看用户测试一的密码','2026-04-08 13:30:48',NULL,NULL,NULL),(130,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:31:37',NULL,NULL,NULL),(131,1,'127.0.0.1','admin_access','访问管理员面板','2026-04-08 13:39:42',NULL,NULL,NULL),(132,1,'127.0.0.1','logout','用户主动登出','2026-04-08 14:05:48',NULL,NULL,NULL),(133,3,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 14:05:53',NULL,NULL,NULL),(134,3,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 14:10:07',NULL,NULL,NULL),(135,3,'192.168.1.9','send_message','发送文本消息给 测试一','2026-04-08 14:10:24',NULL,NULL,NULL),(136,3,'192.168.1.9','logout','用户主动登出','2026-04-08 14:10:34',NULL,NULL,NULL),(137,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 14:10:41',NULL,NULL,NULL),(138,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:10:52',NULL,NULL,NULL),(139,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:11:11',NULL,NULL,NULL),(140,2,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 14:42:48',NULL,NULL,NULL),(141,2,'127.0.0.1','update_username','修改用户名为 1','2026-04-08 14:43:09',NULL,NULL,NULL),(142,2,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 14:51:33',NULL,NULL,NULL),(143,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:51:39',NULL,NULL,NULL),(144,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:51:43',NULL,NULL,NULL),(145,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:51:47',NULL,NULL,NULL),(146,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:51:50',NULL,NULL,NULL),(147,2,'192.168.1.9','send_message','发送文本消息给 2','2026-04-08 14:51:54',NULL,NULL,NULL),(148,3,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 15:07:54',NULL,NULL,NULL),(149,3,'127.0.0.1','send_message','发送文本消息给 1','2026-04-08 15:26:20',NULL,NULL,NULL),(150,3,'127.0.0.1','send_message','发送文本消息给 1','2026-04-08 15:26:20',NULL,NULL,NULL),(151,3,'127.0.0.1','send_message','发送文本消息给 1','2026-04-08 15:26:20',NULL,NULL,NULL),(152,3,'127.0.0.1','send_message','发送文本消息给 1','2026-04-08 15:26:21',NULL,NULL,NULL),(153,3,'127.0.0.1','send_message','发送文本消息给 1','2026-04-08 15:43:33',NULL,NULL,NULL),(154,3,'127.0.0.1','upload_file','上传audio文件: 5c323526-8ad7-494a-b46d-f841b1d8124e.flac','2026-04-08 15:43:52',NULL,NULL,NULL),(155,3,'127.0.0.1','send_file','发送audio文件给 1','2026-04-08 15:43:52',NULL,NULL,NULL),(156,2,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 15:52:35',NULL,NULL,NULL),(157,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 15:52:47',NULL,NULL,NULL),(158,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 15:52:56',NULL,NULL,NULL),(159,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 15:53:00',NULL,NULL,NULL),(160,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 15:53:05',NULL,NULL,NULL),(161,2,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 16:37:10',NULL,NULL,NULL),(162,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:17',NULL,NULL,NULL),(163,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:17',NULL,NULL,NULL),(164,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:18',NULL,NULL,NULL),(165,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:18',NULL,NULL,NULL),(166,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:18',NULL,NULL,NULL),(167,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:19',NULL,NULL,NULL),(168,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:19',NULL,NULL,NULL),(169,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 16:37:19',NULL,NULL,NULL),(170,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 17:01:54',NULL,NULL,NULL),(171,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 17:13:00',NULL,NULL,NULL),(172,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 17:13:01',NULL,NULL,NULL),(173,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 17:16:16',NULL,NULL,NULL),(174,2,'127.0.0.1','send_message','发送文本消息给 2','2026-04-08 17:16:20',NULL,NULL,NULL),(175,6,'127.0.0.1','login','登录成功，设备: Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 18:14:30',NULL,NULL,NULL),(176,6,'192.168.1.9','login','登录成功，设备: Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 18:17:07',NULL,NULL,NULL);
/*!40000 ALTER TABLE `user_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `online` tinyint(1) DEFAULT NULL,
  `login_attempts` int DEFAULT NULL,
  `lock_time` datetime DEFAULT NULL,
  `verify_code` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_banned` tinyint(1) DEFAULT NULL,
  `is_muted` tinyint(1) DEFAULT NULL,
  `login_device` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_time` datetime DEFAULT NULL,
  `session_created_at` datetime DEFAULT NULL,
  `current_session_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','pbkdf2:sha256:1000000$OnJooPTrQBUgvDzc$ca3ffd6a029d43f315a66fdb57815e0bebbdcde0d6391094291246fae6c8f33a',0,1,NULL,NULL,'admin',0,0,'Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 13:30:46',NULL,NULL,NULL),(2,'1','pbkdf2:sha256:1000000$SXJnUvOh1sUCmN7X$2e31e28622cbf1cc74e770f242e087c367a634e01d8bc0a240a23c003261165b',1,0,NULL,NULL,'user',0,0,'Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 16:37:10','2026-04-08 16:37:10','5e324547-bd01-44d1-bf13-c9c772707129','/static/uploads/e3b8d8c7-96fa-403a-a97b-f88264663052.png'),(3,'2','pbkdf2:sha256:1000000$g51B7v5fFIJT2Yoh$307945b23affc3b94d1b16fe0c2c3303a52562888c79a0e5f4d76df0b722f66e',0,0,NULL,NULL,'user',0,0,'Windows - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-04-08 15:07:54','2026-04-08 15:07:54','1da81e6c-0479-4acf-9262-bf2c25182027','/static/uploads/74b25607-a67a-49ee-a779-1c25841e5bee.png'),(4,'4','pbkdf2:sha256:1000000$5mcWi4hbJLlD0wgp$aa284d3983de8e0dfcf9f20e4bea3d72de50456cb35ebf12cc8f01f6b722513b',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL,NULL),(5,'5','pbkdf2:sha256:1000000$cCHMjU8iN9n023we$23532aaeda42ade013308096c816ed6b716d3e910961fb1f0842ef297096c1b1',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL,NULL),(6,'7','pbkdf2:sha256:1000000$7M9PQg5RWqNzgPOk$0153fcda0c2ab998a8177ed474bc41375b04b9cef6913da1c676976c81e329f1',0,0,NULL,NULL,'user',0,0,'Windows - Mozilla/5.0 (Linux; Android 16; V2301A) AppleWebKi...','2026-04-08 18:17:07','2026-04-08 18:17:07','0058de7c-2eba-4deb-851e-021fd1ca77b3',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-12 15:54:08
