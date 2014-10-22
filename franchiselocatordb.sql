--
-- Table structure for table `FranchiseLocator`
--

CREATE TABLE FranchiseLocator (
  Number int(10) NOT NULL auto_increment,
  Company int(3) default NULL,
  Name varchar(50) default NULL,
  Store varchar(15) default NULL,
  Address varchar(50) default NULL,
  DID bigint(10) default NULL,
  ZipCode int(5) default NULL,
  Latitude varchar(10) default NULL,
  Longitude varchar(10) default NULL,
  AddInfo varchar(150) default NULL,
  PRIMARY KEY  (Number)
) TYPE=InnoDB;

