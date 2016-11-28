


CREATE TABLE `MASH_param` (
       `MASH_param_id` smallint(5) NOT NULL AUTO_INCREMENT,
       `distance` decimal(10,10) NOT NULL,
       `pvalue` double unsigned DEFAULT NULL,
       `kmer_size` int(11) DEFAULT NULL,
       `sketch_size` int(11) DEFAULT NULL,
       PRIMARY KEY (`MASH_param_id`),
       UNIQUE KEY `distance` (`distance`,`pvalue`,`kmer_size`,`sketch_size`)
       ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;



CREATE TABLE `MASH_cluster` (
       `MASH_param_id` smallint(5) unsigned NOT NULL DEFAULT '0',
       `cluster_id` int(11) unsigned NOT NULL DEFAULT '0',
       `O_id` int(11) unsigned NOT NULL,
       PRIMARY KEY (`O_id`,`MASH_param_id`)
       ) ENGINE=MyISAM DEFAULT CHARSET=latin1;



