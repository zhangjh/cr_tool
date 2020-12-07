### 该工具用来自动生成MR请求供CR辅助使用

#### 使用方式如下：
```
Usage: run.sh
	[-g 'git路径前缀，不填默认读配置，正常都不用填，该参数和-n参数共同组成git clone的仓库地址']
	-n 'git应用名'
	-b '开发分支名'
	[-t] '目标分支名,不传时自动生成'
	[-msg] '合并备注消息，不填以默认信息填充'

	[-m '审阅者邮件，不填默认读配置']
	[-s '环境已经妥当，跳过环境检查环节，默认跳过，首次运行请指定该参数']
```
正常情况下，只需传递-n和-b参数，指定git应用名和开发分支名，首次运行时需要随意指定-s参数初始化依赖环境。

例如：
```
// bin目录下执行
sh run.sh -n document -b dev_test -s ''
```

#### 一些配置
在conf目录下，有两个配置文件：config和mail.conf
config包括GITLAB_URL和GITLAB_TOKEN参数，URL不用修改，TOKEN需要配置自己的gitlab access token。生成方式如下：
![](https://cdn.nlark.com/yuque/0/2020/png/106920/1607181064503-689720af-4de7-46ca-9bb2-f59d80eb89bd.png)

mail.conf中包含：userName,userPass和reviewer，前两项为自己的邮箱账号和密码，reviewer为cr提交给的人员邮箱。如果不填同时脚本执行时也没有传递-m参数，
那么将不会发送cr请求创建的邮件通知。工具执行后会生成MR链接，可以将链接手动发给reviewer。


#### 其他
bin目录下还包含clean.sh脚本，该脚本可以批量自动清除因为创建CR请求生成的临时CR分支。定期清理保持分支干净。
