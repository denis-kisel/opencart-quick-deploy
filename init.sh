#!/bin/bash
source conf.sh

DIR_ROOT=$(pwd)

create_db=yes
create_files=yes
oc_vs=(2000 2010 2011 2020 2031 2101 2102 2200 2300 2301 2302 3000 3011 3012 3020)

args=$@
for arg in ${args[*]}
do
	if [[ $arg = odb ]]; then
		create_files=no
	fi

	if [[ $arg = of ]]; then
		create_db=no
	fi

	if [[ $arg = v:* ]]; then
		oc_vs_str=${arg//v:/}
		IFS=',' read -r -a oc_vs <<< $oc_vs_str
	fi
done

for oc_v in ${oc_vs[*]}
do
	echo $create_files
	if [[ $create_files = yes ]]; then
		echo Create/update files for opencart $oc_v
		rm -fR $oc_v
		mkdir $oc_v
		cp -r resources/$oc_v/* $oc_v

		echo set configs
		cp templates/catalog_config.txt $oc_v/config.php
		cp templates/admin_config.txt $oc_v/admin/config.php
		cp templates/htaccess.txt $oc_v/.htaccess
		
		# Catalog
		sed -i "s/{oc_v}/$oc_v/g" $oc_v/config.php
		sed -i "s/{domain}/${DOMAIN//\//\\/}/g" $oc_v/config.php
		sed -i "s/{dir_route}/${DIR_ROOT//\//\\/}/g" $oc_v/config.php

		sed -i "s/{db_driver}/$DB_DRIVER/g" $oc_v/config.php
		sed -i "s/{db_host}/$DB_HOSTNAME/g" $oc_v/config.php
		sed -i "s/{db_user}/$DB_USER/g" $oc_v/config.php
		sed -i "s/{db_pass}/$DB_PASS/g" $oc_v/config.php
		sed -i "s/{db_db}/opencart_$oc_v/g" $oc_v/config.php
		sed -i "s/{db_port}/$DB_PORT/g" $oc_v/config.php

		# Admin
		sed -i "s/{oc_v}/$oc_v/g" $oc_v/admin/config.php
		sed -i "s/{domain}/${DOMAIN//\//\\/}/g" $oc_v/admin/config.php
		sed -i "s/{dir_route}/${DIR_ROOT//\//\\/}/g" $oc_v/admin/config.php

		sed -i "s/{db_driver}/$DB_DRIVER/g" $oc_v/admin/config.php
		sed -i "s/{db_host}/$DB_HOSTNAME/g" $oc_v/admin/config.php
		sed -i "s/{db_user}/$DB_USER/g" $oc_v/admin/config.php
		sed -i "s/{db_pass}/$DB_PASS/g" $oc_v/admin/config.php
		sed -i "s/{db_db}/opencart_$oc_v/g" $oc_v/admin/config.php
		sed -i "s/{db_port}/$DB_PORT/g" $oc_v/admin/config.php
		
		# Htaccess
		sed -i "s/{rewrite_base}/${REWRITE_BASE//\//\\/}$oc_v\//g" $oc_v/.htaccess
		
		# Fix sql bugs
		sed -i "s/----/-- --/" resources/$oc_v/install/opencart.sql
	fi
	
	if [[ $create_db = yes ]]; then
		echo Create/update DB
		mysql -u $DB_USER -p$DB_PASS <<CREATE_DB
		DROP DATABASE IF EXISTS opencart_$oc_v;
		CREATE DATABASE opencart_$oc_v;
		USE opencart_$oc_v
		source resources/$oc_v/install/opencart.sql
		
		INSERT INTO oc_user (user_id, user_group_id, username, password, salt, firstname, lastname, email, image, code, ip, status, date_added) VALUES (1, 1, 'admin', '21232f297a57a5a743894a0e4a801fc3', '', '', '', '', '', '', '', 1, '2018-06-05 09:32:05');
CREATE_DB
	fi
done
