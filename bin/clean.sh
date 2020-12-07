#!/bin/bash
### 清理临时cr分支
## 清理本地分支
git branch| grep code | xargs git branch -D
## 清理远程分支`
git branch -r | grep code | sed 's/origin\///g' | xargs -I {} git push origin :{}

