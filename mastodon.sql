-- MySQL dump 10.13  Distrib 5.5.44, for debian-linux-gnu (armv7l)
--
-- Host: localhost    Database: backupserver
-- ------------------------------------------------------
-- Server version	5.5.44-0+deb8u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `jobline` int(20) NOT NULL,
  `filepath` varchar(1024) NOT NULL,
  `filehash` varchar(100) NOT NULL,
  `runref` varchar(20) NOT NULL,
  `uploadid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  UNIQUE KEY `uploadid` (`uploadid`),
  KEY `jobline` (`jobline`),
  KEY `runref` (`runref`),
  KEY `filehash` (`filehash`)
) ENGINE=InnoDB AUTO_INCREMENT=16960 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `joblines`
--

DROP TABLE IF EXISTS `joblines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `joblines` (
  `job` bigint(20) NOT NULL,
  `tasktype` bigint(20) NOT NULL,
  `location` varchar(1024) NOT NULL,
  `lineid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  UNIQUE KEY `lineid` (`lineid`),
  KEY `job` (`job`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `user` bigint(20) NOT NULL,
  `jobname` varchar(100) NOT NULL,
  `sourceip` varchar(100) NOT NULL,
  `serverkey` varchar(100) NOT NULL,
  `jobid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  UNIQUE KEY `jobid` (`jobid`),
  KEY `user` (`user`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `runreferences`
--

DROP TABLE IF EXISTS `runreferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `runreferences` (
  `job` bigint(20) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `runid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `runref` varchar(20) NOT NULL,
  UNIQUE KEY `instance` (`runid`),
  KEY `job` (`job`),
  KEY `runref` (`runref`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tasktypes`
--

DROP TABLE IF EXISTS `tasktypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasktypes` (
  `taskref` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `taskname` varchar(100) NOT NULL,
  UNIQUE KEY `taskref` (`taskref`),
  KEY `taskref_2` (`taskref`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `useremail` varchar(250) NOT NULL,
  `userpass` varchar(250) NOT NULL,
  `userid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `status` int(11) NOT NULL,
  UNIQUE KEY `userid` (`userid`),
  KEY `userid_2` (`userid`),
  KEY `useremail` (`useremail`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-04-11 19:29:57
