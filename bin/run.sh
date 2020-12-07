######################################
### Author: zhangjihong            ###
### Desc: 自动创建git MR工具       ###
### Date：12/05 2020               ###
######################################

#!/bin/bash

help() {
	echo "Usage: `basename $0` 
	[-g 'git路径前缀，不填默认读配置，正常都不用填，该参数和-n参数共同组成git clone的仓库地址']
	-n 'git应用名'
	-b '开发分支名'
	[-t] '目标分支名,不传时自动生成'
	[-msg] '合并备注消息，不填以默认信息填充'\n
	[-m '审阅者邮件，不填默认读配置']
	[-s '环境已经妥当，跳过环境检查环节，默认跳过，首次运行请指定该参数']"
}

# 环境检查，需要安装git
check() {
	ret=`which git`
	if [ $? -ne 0 ];then
		echo "git not exist, installing git first, waiting..."
		brew install git 
	fi

	ret=`which node`
	if [ $? -ne 0 ];then
		echo "need node to send mail, installing node first, waiting..."
		brew install node 
	fi
}

## 安装nodemailer依赖
install() {
	cd ${lib_dir}
	npm i 
}

# git创建分支
create_br() {
	cd ${bin_dir}
	if [ ! -e repo ];then
		mkdir repo
	fi
	cd repo
	name=`echo ${git_repo} | awk -F/ '{print $2}' | awk -F. '{print $1}'`
	if [ -e ${name} ];then 
		cd ${name}
	else
		git clone ${git_repo} && cd ${name}
	fi
	git checkout master && git pull
	git checkout -b ${target_branch}	
	git push --set-upstream origin ${target_branch}
	git pull
}

## 创建mr提交使用的配置
function create_config() {
	token=`cat ${conf_dir}/config | grep TOKEN | awk -F= '{print $2}'`
	git config --add gitlab.url "http://git2.superboss.cc"
	git config --add gitlab.token "${token}"
}

## 创建mr
function create_mr() {
	echo `pwd`
	ret=`which lab`
	if [ $? -ne 0 ];then
		echo "install git-lab-cli, waiting..."
		npm i git-lab-cli -g 
	fi
	create_config

	git checkout ${dev_branch}
	mr_address=`lab mr -a ${reviewer_mail} -m "${msg}" -b "${dev_branch}" -t "${target_branch}"`
	if [ $? -ne 0 ];then
		echo "mr create failed"
		exit 1
	fi
	print_red "mr请求地址: ${mr_address}，临时cr分支：${target_branch}，cr未完成时该mr地址可持续使用，无需重复生成mr请求."
	send_mail ${reviewer_mail} ${mr_address}
}

print_red() {
	echo "\033[31m" $1 "\033[0m" 
}

send_mail() {
	cd ${lib_dir}
	mail_content="您有一个分支CodeReview待处理，请查看${2}"
	if [ "${reviewer_mail}" != "" ];then
		node mail.js ${reviewer_mail} "${mail_content}"
	fi
}

main() {
	echo "skip: ${skip_env_check}"
	if [ "${skip_env_check}" != "true" ];then
		check
		install
	fi
	create_br 
	if [ $? -ne 0 ];then
		echo "create_br failed"
		exit 1
	fi
	echo "target_branch: ${target_branch}"
	create_mr 
}

skip_env_check="true"
while getopts 'g:n:b:t:m:s:h' OPT; do
	case $OPT in
		g)
			git_base="$OPTARG";;
		n)
			git_name="$OPTARG";;
		b)
			dev_branch="$OPTARG";;
		t)
			target_branch="$OPTARG";;
		msg)
			msg="$OPTARG";;
		m)
			reviewer_mail="$OPTARG";;
		s)
			skip_env_check="$OPTARG";;
		h)
			help
			exit 0;;
		?)
			echo "invalid param"
			help
			exit 1;;
	esac
done

if [ "${git_base}" == "" ];then
	git_base=`cat ../conf/config | grep GITLAB_BASE | awk -F= '{print $2}'`
	if [ "${git_base}" == "" ];then
		echo "默认仓库地址前缀未配置，且未通过参数指定"
		exit 0
	fi
fi
if [ "${git_name}" == "" ];then
	echo "git名称未填"
	exit 1
fi
git_repo="${git_base}${git_name}.git"

if [ "${dev_branch}" == "" ];then
	echo "开发分支未填"
	exit 2
fi
if [ "${target_branch}" == "" ];then
	## 创建临时分支
	target_branch="code_review_`date +%m%d%H%M%S%y`"
fi
if [ "${msg}" == "" ];then
	msg="开发代码合并，默认MR消息-`date +%m%d%H%M%S%y`"
fi
if [ "${reviewer_mail}" == "" ];then
	reviewer_mail=`cat ../conf/mail.conf| awk -F'module.exports.reviewer = ' '{print $2}' | awk -F'"' '{print $2}' | grep -v '^$'`
	if [ "${reviewer_mail}" == "" ];then
		echo "review人员邮箱未配置，不发送邮件"
	fi
fi

echo "git_repo: ${git_repo}" 
echo "dev_branch: ${dev_branch}"
echo "target_branch: ${target_branch}"
echo "msg: ${msg}"
echo "reviewer_mail: ${reviewer_mail}"

bin_dir=`pwd`
conf_dir=`cd ${bin_dir}/../conf/ && pwd`
lib_dir=`cd ${bin_dir}/../lib/ && pwd`

main 

