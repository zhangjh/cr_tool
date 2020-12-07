/**
 * Author：zhangjihong
 * Desc：send mail written by node.js
 * Date：12/05 2020
*/
let nodemailer = require('nodemailer');
let mailConf = require('../conf/mail.conf');

function sendMail(to,content){
	let transport = nodemailer.createTransport("SMTP",{
		// 修改成合适的smtp邮件接入
		host: "smtp.exmail.qq.com",
		secureConnection: true,
		port: 465,
		auth: {
			user: mailConf.userName,
			pass: mailConf.userPass
		}
	});

	transport.sendMail({
		from: mailConf.userName,
		to: to,
		subject: "CR邮件提醒",
		text: content
	},function(err,info){
		if(err)console.error("error:",err);
		else console.log("res:",info.message);
		process.exit();
	});
}

const args = process.argv.splice(2);

const userName = mailConf.userName;
const userPass = mailConf.userPass;
const to = mailConf.reviewer;

if(!userName) {
	console.error("Error: mailConf userName is empty");
	return;
}
if(!userPass) {
	console.error("Error: mailConf userPass is empty");
	return;
}

const receiver = args[0] || to;
const content = args[1];
if(!receiver) {
	console.error("Error: receiver is empty");
	return;
}
if(!content) {
	console.error("Error: mail content is empty");
	return;
}
sendMail(args[0],args[1]);
