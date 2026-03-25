-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: wechat_chat
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.22.04.1

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_requests`
--

LOCK TABLES `friend_requests` WRITE;
/*!40000 ALTER TABLE `friend_requests` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friends`
--

LOCK TABLES `friends` WRITE;
/*!40000 ALTER TABLE `friends` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_detail` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_path` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activities`
--

LOCK TABLES `user_activities` WRITE;
/*!40000 ALTER TABLE `user_activities` DISABLE KEYS */;
INSERT INTO `user_activities` VALUES (1,1,'183.228.54.26','admin_action','清空所有日志','2026-03-18 12:08:34',NULL,NULL,NULL),(2,1,'183.228.54.26','admin_access','查看用户行为日志','2026-03-18 12:08:35',NULL,NULL,NULL),(3,1,'183.228.54.26','admin_action','用户3的账户已被注销并从数据库中删除','2026-03-18 12:09:08',NULL,NULL,NULL),(4,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:09',NULL,NULL,NULL),(5,1,'183.228.54.26','admin_action','用户4的账户已被注销并从数据库中删除','2026-03-18 12:09:17',NULL,NULL,NULL),(6,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:18',NULL,NULL,NULL),(7,1,'183.228.54.26','admin_action','用户15的账户已被注销并从数据库中删除','2026-03-18 12:09:25',NULL,NULL,NULL),(8,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:26',NULL,NULL,NULL),(9,1,'183.228.54.26','admin_action','用户11的账户已被注销并从数据库中删除','2026-03-18 12:09:29',NULL,NULL,NULL),(10,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:30',NULL,NULL,NULL),(11,1,'183.228.54.26','admin_action','用户12的账户已被注销并从数据库中删除','2026-03-18 12:09:33',NULL,NULL,NULL),(12,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:34',NULL,NULL,NULL),(13,1,'183.228.54.26','admin_action','用户10已封号','2026-03-18 12:09:37',NULL,NULL,NULL),(14,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:38',NULL,NULL,NULL),(15,1,'183.228.54.26','admin_action','用户10的账户已被注销并从数据库中删除','2026-03-18 12:09:41',NULL,NULL,NULL),(16,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:41',NULL,NULL,NULL),(17,1,'183.228.54.26','admin_action','用户13的账户已被注销并从数据库中删除','2026-03-18 12:09:44',NULL,NULL,NULL),(18,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:45',NULL,NULL,NULL),(19,1,'183.228.54.26','admin_action','用户9的账户已被注销并从数据库中删除','2026-03-18 12:09:48',NULL,NULL,NULL),(20,1,'183.228.54.26','admin_access','访问管理员面板','2026-03-18 12:09:49',NULL,NULL,NULL),(21,1,'183.228.54.26','admin_access','查看用户 admin 的聊天记录','2026-03-18 12:09:56',NULL,NULL,NULL),(22,1,'183.228.54.190','login','登录成功，设备: Linux - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-25 15:16:52',NULL,NULL,NULL),(23,1,'183.228.54.190','admin_access','访问管理员面板','2026-03-25 15:16:52',NULL,NULL,NULL);
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
  `login_device` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_time` datetime DEFAULT NULL,
  `session_created_at` datetime DEFAULT NULL,
  `current_session_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','pbkdf2:sha256:600000$zxxoWctkz3fYk6f4$69feb2ed3a4d69af3a37a8921d695f939f1dc188e3561b26226b2e67adc968a4',1,0,NULL,NULL,'admin',0,0,'Linux - Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...','2026-03-25 15:16:52','2026-03-25 15:16:52','cbb39163-5669-45a6-9700-4c54c75d70e8'),(2,'5','pbkdf2:sha256:600000$c6hAIDOEKKmtqxzG$7779b65cd0368f47acb33ab54d0cb6ec1c3a81ea3c8387ed27730aaaf3d6376f',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(3,'6','pbkdf2:sha256:600000$ffznVpuVLsMgMCRg$3ba2b8d8c3f389e94f38035e3b5ddcde1de848aafc514153558399b0f44fc669',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(4,'7','pbkdf2:sha256:600000$gtDKMqblBwRepY2c$74335ac721fe079bb62016e6abfec3e0863f89cbe10cf666dc4c1588658de98a',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(5,'8','pbkdf2:sha256:600000$J9R7pyGj0m9Q3vMN$e3fa16c6caaf9c6038d4fbac42fee67b935bcef060a0b100f05364e3dc908f8e',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(6,'16','pbkdf2:sha256:600000$L1HtYge4eP18tArc$da6056722ced8c9af13d86765bc2f696ef1067850f5d11deb26f504e6f25c7d1',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(7,'17','pbkdf2:sha256:600000$a4BNqaFldwyxYh62$3ad158e7a4823108d233f38fbea331305762e592fcd444ec95abdd299bf7d229',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(8,'18','pbkdf2:sha256:600000$TEFIt3GSPZOURsS9$b299f8f4392d63f66f404f80d806602ea8e35847d9a558b1705c224e41cc76b3',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(9,'19','pbkdf2:sha256:600000$NffClapnBrCJJViY$b754e4be102d6977a6fc4593a9c69d0d9c0ab8381962d7504b549bff5bd4bcb6',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL),(10,'20','pbkdf2:sha256:600000$uHgOUC3xa7mqGVey$fb2f50673198052072b9227542198fd724da73e771809cfece4283289220ec36',0,0,NULL,NULL,'user',0,0,NULL,NULL,NULL,NULL);
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

-- Dump completed on 2026-03-25 15:35:21
