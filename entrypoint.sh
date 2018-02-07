#!/bin/bash


VARNISH_CUSTOMIZED_VCL="/etc/varnish/conf.d/default.vcl"
: ${STORAGE_TYPE:=${VARNISH_STORAGE_TYPE:='malloc'}}
if [[ $STORAGE_TYPE == 'malloc' ]]; then
	: ${STORAGE_SIZE:=${VARNISH_STORAGE_SIZE:='256m'}}
	VARNISH_STORAGE_OPTION="$STORAGE_TYPE,$STORAGE_SIZE"
elif [[ $STORAGE_TYPE == 'file' ]]; then
	: ${STORAGE_SIZE:=${VARNISH_STORAGE_SIZE:='1g'}}
	VARNISH_STORAGE_OPTION="$STORAGE_TYPE,/var/lib/varnish/varnish_storage.bin,$STORAGE_SIZE"
fi 


if [[ $1 == "varnish" ]]; then
	if [[ ! -f ${VARNISH_CUSTOMIZED_VCL} ]]; then
		VARNISH_CUSTOMIZED_VCL="/etc/varnish/default.vcl"
		sed "s/127.0.0.1/${VARNISH_BACKEND_SERVICE}/g" -i ${VARNISH_CUSTOMIZED_VCL}
		sed "s/8080/${VARNISH_BACKEND_PORT}/g" -i ${VARNISH_CUSTOMIZED_VCL}
	fi 

	chown -R varnish:varnish /var/lib/varnish/
	varnishd  \
		-S /etc/varnish/secret \
		-f ${VARNISH_CUSTOMIZED_VCL} \
		-a :80 \
		-s ${VARNISH_STORAGE_OPTION} \
		-P /var/lib/varnish/varnish.pid
	varnishlog 
fi 
