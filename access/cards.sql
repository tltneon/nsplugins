CREATE TABLE IF NOT EXISTS `cards` (
  `uid` int(10) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `owner` varchar(64) NOT NULL,
  `access` varchar(32) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `description` varchar(128) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;