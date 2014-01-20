-- Set your database name here
CREATE DATABASE `monitor` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `monitor`;

CREATE TABLE IF NOT EXISTS `cpudata` (
  `idCpu` tinyint(3) unsigned NOT NULL,
  `idData` int(10) unsigned NOT NULL,
  `usage` float unsigned NOT NULL,
  PRIMARY KEY (`idCpu`,`idData`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `clock` int(11) NOT NULL,
  `loadAvgOne` float unsigned NOT NULL,
  `loadAvgFive` float unsigned NOT NULL,
  `loadAvgFifteen` float unsigned NOT NULL,
  `overallCpuUsage` float unsigned NOT NULL,
  `processes` tinyint(3) unsigned NOT NULL,
  `connections` int(10) unsigned NOT NULL,
  `hosts` int(10) unsigned NOT NULL,
  `users` tinyint(3) unsigned NOT NULL,
  `memTotalUsed` int(10) unsigned NOT NULL,
  `memTotalUsage` float unsigned NOT NULL,
  `memBuffersUsed` int(10) unsigned NOT NULL,
  `memBuffersUsage` float unsigned NOT NULL,
  `memCachedUsed` int(10) unsigned NOT NULL,
  `memCachedUsage` float unsigned NOT NULL,
  `memSystemUsed` int(10) unsigned NOT NULL,
  `memSystemUsage` float unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `filesystem` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mountpath` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `fsdata` (
  `idFs` int(10) unsigned NOT NULL,
  `idData` int(10) unsigned NOT NULL,
  `used` int(10) unsigned NOT NULL,
  `usage` float unsigned NOT NULL,
  PRIMARY KEY (`idFs`,`idData`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `pingdata` (
  `idHost` int(10) unsigned NOT NULL,
  `idData` int(10) unsigned NOT NULL,
  `time` float unsigned NOT NULL,
  PRIMARY KEY (`idHost`,`idData`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `pinghost` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `target` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
