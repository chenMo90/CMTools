# CMTools

[![CI Status](https://img.shields.io/travis/904165900@qq.com/CMTools.svg?style=flat)](https://travis-ci.org/904165900@qq.com/CMTools)
[![Version](https://img.shields.io/cocoapods/v/CMTools.svg?style=flat)](https://cocoapods.org/pods/CMTools)
[![License](https://img.shields.io/cocoapods/l/CMTools.svg?style=flat)](https://cocoapods.org/pods/CMTools)
[![Platform](https://img.shields.io/cocoapods/p/CMTools.svg?style=flat)](https://cocoapods.org/pods/CMTools)

## Develop

修改工程后，执行`pod lib lint`检测是否有错误

	pod lib lint

将本地文件上传到远程仓库

	git remote add origin https://github.com/chenMo90/CMTools.git

	git add .

	git commit -m "Initial commit"

	git push -u origin master 

当执行推送远端失败时，先执行以下操作

	git pull origin master

如果出现下面所示错误，需添加--allow-unrelated-histories即可

	#From https://github.com/chenMo90/CMTools.git
	# * branch            master     -> FETCH_HEAD
	#fatal: refusing to merge unrelated histories

执行下面语句

	git pull origin master --allow-unrelated-histories

修改版本号

	git tag 0.1.0

	git push --tags

### 校验Spec

执行`pod spec lint`

	pod spec lint

没有报错便是成功了







## Requirements

## Installation

1.提交 podspec 到本地,向仓库中添加组件，可以在 `~/.cocoapods/repos/` 下查看 

	pod repo add CMTools https://github.com/chenMo90/CMTools.git

2.添加CMTools

```ruby
pod 'CMTools' , :git => 'https://github.com/chenMo90/CMTools.git'
```

## Author

Jim

## License

CMTools is available under the MIT license. See the LICENSE file for more info.