"use strict";

$(document).ready(function () {
	var lei3Po8h = ["support", ["tuna", "tsinghua", "edu", "cn"].join(".")].join("@");
	$('a#eib1gieB').text(lei3Po8h).attr('href', atob('bWFpbHRvOgo=') + lei3Po8h);

	$('.selectpicker').selectpicker();

	var mir_tmpl = $("#template").text(),
	    label_map = {
		'unknown': 'label-default',
		'syncing': 'label-info',
		'success': 'label-success',
		'fail': 'label-warning',
		'failed': 'label-warning',
		'paused': 'label-warning'
	},
	    help_url = {
		"gentoo-portage-prefix": "/help/gentoo-prefix-portage/", "gentoo-portage": "/help/gentoo-portage/", "openthos-src": "/help/openthos-src/", "CTAN": "/help/CTAN/", "grafana": "/help/grafana/", "llvm": "/help/llvm/", "CRAN": "/help/CRAN/", "bioconductor": "/help/bioconductor/", "rubygems": "/help/rubygems/", "repoforge": "/help/repoforge/", "virtualbox": "/help/virtualbox/", "ubuntu": "/help/ubuntu/", "termux": "/help/termux/", "tensorflow": "/help/tensorflow/", "stackage": "/help/stackage/", "rpmfusion": "/help/rpmfusion/", "repo-ck": "/help/repo-ck/", "raspbian": "/help/raspbian/", "pypi": "/help/pypi/", "pybombs": "/help/pybombs/", "nodesource": "/help/nodesource/", "nodejs-release": "/help/nodejs-release/", "msys2": "/help/msys2/", "mongodb": "/help/mongodb/", "lxc-images": "/help/lxc-images/", "linux.git": "/help/linux.git/", "linux-stable.git": "/help/linux-stable.git/", "lineageOS": "/help/lineageOS/", "lineage-rom": "/help/lineage-rom/", "homebrew": "/help/homebrew/", "homebrew-bottles": "/help/homebrew-bottles/", "hackage": "/help/hackage/", "gitlab-runner": "/help/gitlab-runner/", "gitlab-ci-multi-runner": "/help/gitlab-ci-multi-runner/", "gitlab-ce": "/help/gitlab-ce/", "git-repo": "/help/git-repo/", "fedora": "/help/fedora/", "epel": "/help/epel/", "elpa": "/help/elpa/", "docker-ce": "/help/docker-ce/", "debian": "/help/debian/", "cygwin": "/help/cygwin/", "chromiumos": "/help/chromiumos/", "centos": "/help/centos/", "bananian": "/help/bananian/", "archlinuxcn": "/help/archlinuxcn/", "archlinux": "/help/archlinux/", "AOSP": "/help/AOSP/", "anaconda": "/help/anaconda/", "CocoaPods": "/help/CocoaPods/", "AUR": "/help/AUR/"
	},
	    new_mirrors = {
		"fzug": true, "chakra-releases": true, "fedora-altarch": true, "gentoo-portage-prefix": true, "gitlab-runner": true, "pkgsrc": true, "eclipse": true, "nodejs-release": true
	},
	/**
	{
		'status': 'success',
		'last_update': '-',
		'name': "AUR",
		'url': 'https://aur.tuna.tsinghua.edu.cn/',
		'upstream': 'https://aur.archlinux.org/'
	}
	**/
	    unlisted = [],
	    options = {
		'AOSP': {
			'url': "/help/AOSP/"
		},
		'lineageOS': {
			'url': "/help/lineageOS/"
		},
		'homebrew': {
			'url': "/help/homebrew/"
		},
		'linux.git': {
			'url': "/help/linux.git/"
		},
		'linux-stable.git': {
			'url': "/help/linux-stable.git/"
		},
		'git-repo': {
			'url': "/help/git-repo/"
		},
		'chromiumos': {
			'url': "/help/chromiumos/"
		},
		'weave': {
			'url': "/help/weave/"
		},
		'CocoaPods': {
			'url': "/help/CocoaPods/"
		},
		'llvm': {
			'url': "/help/llvm/"
		},
		'openthos-src': {
			'url': "/help/openthos-src/"
		}
	},
	    descriptions = {
		'AOSP': 'Android 操作系统源代码', 'AUR': 'Arch Linux 用户软件库', 'Bananian': '为 Banana Pi 制作的，基于官方 Debian 仓库的发行版镜像和软件包仓库', 'CRAN': 'R 语言的可执行文件、源代码和说明文件，也收录了各种用户撰写的软件包', 'CTAN': 'TeX 的各种发行版、软件包和文档', 'CocoaPods': 'Objective-C 和 Swift 的依赖管理器', 'ELK': '现已更名为 Elastic Stack，仅保留用作向后兼容', 'HHVM': 'Facebook 开发的高性能 PHP 语言虚拟机', 'Homebrew': 'Homebrew 的 formula 索引的镜像，二进制预编译包的镜像请见 homebrew-bottles', 'NetBSD': 'NetBSD 的安装镜像和部分系统源码', 'OpenBSD': 'OpenBSD 的安装镜像和官方软件包仓库', 'adobe-fonts': 'Adobe 公司的开源字体', 'alpine': 'Alpine Linux 的安装镜像和官方软件包仓库', 'anaconda': '用于科学计算的 Python 发行版', 'antergos': '基于 Arch Linux 的使用 GNOME 3 的发行版，曾用名 Cinnarch', 'anthon': 'Anthon Linux (安同 Linux)的安装镜像和官方软件包仓库', 'aosp-monthly': 'AOSP 镜像每月打包', 'apache': 'Apache 基金会赞助的各个项目', 'arch4edu': '用于 Arch Linux 的一系列科研、教学所需工具', 'archlinux': 'Arch Linux 的安装镜像和官方软件包仓库', 'archlinuxarm': '用于 arm 平台的 Arch Linux 镜像和软件包仓库', 'archlinuxcn': '由 Arch Linux 中文社区驱动的非官方用户仓库,包含中文用户常用软件、工具、字体/美化包等', 'bananian': '用于 Banana Pi 的 Debian 操作系统', 'bioconductor': '开源的基因数据分析处理工具', 'bjlx': '北京龙芯 & Debian 俱乐部 的公开软件源', 'blackarch': '用于安全评估的基于 Arch Linux 的轻量级发行版', 'centos': 'CentOS 的安装镜像和官方软件包仓库', 'centos-altarch': 'CentOS 额外平台的安装镜像和官方软件包仓库', 'ceph': '高性能对象存储和文件系统', 'chakra': '专注于 Qt 与 KDE 软件的 Linux 发行版', 'chakra-releases': 'Chakra 发行版的安装镜像', 'chromiumos': 'Google Chrome OS的开放源代码开发版本', 'clojars': 'Clojure 语言的第三方软件包仓库', 'ctex': '旧版 CTEX 安装镜像存档', 'cygwin': 'Cygwin 官方软件包仓库', 'debian': 'Debian Linux 的官方软件包仓库', 'debian-cd': 'Debian Linux 的安装镜像', 'debian-multimedia': 'Debian Linux 第三方多媒体软件源', 'debian-nonfree': 'Debian Linux 的非自由软件包仓库', 'debian-security': 'Debian Linux 的安全更新', 'deepin': 'Deepin Linux 的官方软件包仓库', 'deepin-cd': 'Deepin Linux 的安装镜像', 'dell': 'Dell 服务器管理工具', 'docker-ce': 'Docker Community Edition 的安装包', 'dotdeb': '用于 Debian 服务器的额外镜像源', 'eclipse': '著名的IDE Eclipse', 'elasticstack': 'ELK 系列数据分析工具，5.x 之后改名为 Elastic Stack', 'elpa': 'Emacs 内建包管理器 package.el 的软件源', 'elrepo': 'RHEL 及其变体的 RPM 软件包仓库', 'elvish': 'TUNA 前会长 xiaq 开发的革命性 Shell', 'epel': '企业版 Linux 附加软件包', 'erlang-solutions': '', 'fedora': 'Fedora Linux 的安装镜像和官方软件包仓库', 'fedora-altarch': 'Fedora Linux 额外平台的安装镜像和官方软件包仓库', 'flightgear': '多平台的飞行模拟器', 'fzug': 'Fedora 中文用户组的软件包仓库', 'gentoo': 'Gentoo Linux 的 Stage 3 镜像', 'gentoo-portage': 'Gentoo Linux 的 Portage 包管理器镜像源', 'gentoo-portage-prefix': 'Gentoo/Prefix 的 Portage 包管理器镜像源', 'git-repo': 'Google 开发的项目依赖下载工具 repo 的镜像', 'gitlab-ce': 'Gitlab 社区版', 'gitlab-ci-multi-runner': 'GitLab 持续集成框架', 'gitlab-ee': 'Gitlab 企业版', 'gitlab-runner': 'GitLab 持续集成框架版本 10 及以上', 'gnu': 'GNU项目的软件包（源代码、文档和部分平台的二进制文件）', 'grafana': '开源的数据可视化工具', 'hackage': 'Haskell 社区的中心软件包仓库', 'homebrew': 'Homebrew 的软件包描述文件', 'homebrew-bottles': '预编译的 Homebrew 软件包', 'iina': 'macOS 上的现代化开源视频播放器', 'infinality-bundle': 'Arch Linux 的字体渲染软件包', 'influxdata': '时间序列数据平台', 'ius': '为企业版 Linux 提供最新软件包的镜像源', 'jenkins': '用 Java 编写的持续集成框架', 'kali': 'Kali Linux 的官方软件包仓库', 'kali-images': 'Kali Linux 的安装镜像', 'kali-security': 'Kali Linux 的安全更新', 'kernel': '各个版本的Linux 内核源代码', 'kodi': '开源的多媒体播放器，原名 XBMC', 'lede': 'OpenWRT 与 LEDE 再次合并后的源码仓库', 'lineage-rom': '最大的社区Android发行版之一Lineage的ROM', 'lineageOS': '最大的社区Android发行版之一Lineage的源代码', 'linux-next.git': 'Linux 内核源代码的 Git 仓库，开发分支（包含为下一个 merge windows 开发的 patch）', 'linux-stable.git': 'Linux 内核源代码的 Git 仓库, 稳定版分支', 'linux.git': 'Linux 内核源代码的 Git 仓库', 'linuxmint': 'Linux Mint 的官方软件源', 'linuxmint-cd': 'Linux Mint 的安装镜像', 'llvm': 'LLVM 编译器套件的多个 git repo 的镜像', 'loongson': '用于龙芯电脑的软件包', 'lxc-images': 'Linux 容器的镜像', 'macports': 'macOS 的一个开源软件包管理系统', 'mageia': 'Mageia Linux （衍生于Mandriva Linux）的安装镜像和官方软件包仓库', 'manjaro': 'Manjaro Linux 的官方软件源', 'manjaro-cd': 'Manjanro Linux 的安装镜像', 'mariadb': '衍生于 MySQL 的开源关系数据库', 'mongodb': '开源的跨平台 NoSQL 文档型数据库', 'msys2': '用于编译原生 Windows 程序的类 Linux 开发环境', 'mysql': 'MySQL 安装包及各种工具下载', 'neurodebian': '用于神经科学研究的 Debian 软件包源', 'nodejs-release': '预编译的 nodejs 二进制程序', 'nodesource': '为 Debian, Ubuntu, Fedora, RHEL 等发行版提供预编译的 nodejs 和 npm 等软件包', 'openresty': '基于 Nginx 与 Lua 的高性能 Web 平台', 'opensuse': 'openSUSE 的安装镜像和官方软件包仓库', 'openthos': 'OpenTHOS 的二进制发行包', 'openthos-src': 'OpenTHOS 源代码仓库', 'openwrt': 'OpenWrt 软件包镜像源（仅包含Chaos Calmer版本，请前往 lede 目录获取最新源码）', 'osmc': '免费、开源的媒体中心解决方案', 'packman': '为 Debian、Fedora、openSUSE、Ubuntu 提供额外和过期软件包的仓库', 'parrot': 'Parrot Linux（专注于安全审计的 Linux 发行版）的安装映像和官方软件源', 'percona': '开源的数据库解决方案，详见 http://www.percona.com', 'pkgsrc': 'NetBSD 的第三方软件源', 'postgresql': '著名的开源关系型数据库 PostgreSQL 的镜像', 'puppy': '为家用电脑设计的轻量级 Linux 发行版', 'pybombs': '为 GNU Radio 设计的编译管理系统', 'pypi': 'Python 软件包索引源', 'qt': '跨平台软件开发库 Qt 的源码、开发工具、文档等', 'raspberrypi': '', 'raspbian': '为 Raspberry Pi 编译的 Debian', 'redhat': 'Red Hat Enterprise Linux 官方软件源', 'remi': '包含最新版本 PHP 和 MySQL 的第三方 yum 源', 'repo-ck': 'repo-ck 是 Arch 的非官方仓库，内有包含 ck 补丁、BFS 调度器等', 'repoforge': 'Repoforge 是 RHEL 系统下的软件仓库，拥有 10000 多个软件包，被认为是最安全、最稳定的一个软件仓库', 'ros': 'ROS (Robot Operating System) 提供一系列程序库和工具以帮助软件开发者创建机器人应用软件', 'rpmfusion': 'RPM Fusion 提供了一些 Fedora Project 和 Red Hat 不包含的软件', 'rubygems': 'Ruby 的一个包管理器', 'sagemath': '构建在 NumPy, SciPy 等工具之上的开源数学软件系统', 'saltstack': '基于 python 的配置管理与运维自动化工具', 'slackware': 'Linux 发行版 Slackware 的源代码和官方软件包仓库', 'slackwarearm': '用于 ARM 设备的 Slackware 发行版源代码和官方软件包仓库', 'solus': 'SolusOS 的软件仓库，致力于制作对新手友好的发行版', 'stackage': 'Haskell 项目管理器 stack 所需的元数据与 ghc 安装包的镜像', 'steamos': 'Valve 开发的基于 Debian 的操作系统，包含安装镜像和官方软件包仓库', 'tensorflow': '采用数据流图、用于数值计算的开源深度学习框架 TensorFlow', 'termux': ' 运行在 Android 上的终端模拟器 Termux 的官方软件包仓库', 'tinycorelinux': '为嵌入式开发的微型 Linux 发行版', 'ubuntu': '流行的 Linux 发行版 Ubuntu 的安装镜像和官方软件包仓库', 'ubuntu-cdimage': 'Ubuntu 及 Ubuntu 衍生版各版本安装镜像', 'ubuntu-cloud-images': '适用于公有云的 Ubuntu 安装镜像', 'ubuntu-ports': 'armhf, arm64 以及 powerpc 等平台的 Ubuntu 软件仓库', 'ubuntu-releases': '包含近几年发行的 Ubuntu 的镜像', 'videolan-ftp': '简称VLC，是一款自由、开源的跨平台多媒体播放器及框架，可播放大多数多媒体文件', 'virtualbox': 'Oracle 的开源的 x86 架构虚拟机', 'weave': 'Google 开发的物联网（IoT）设备通信平台', 'winehq': 'Wine （允许类 Unix 操作系统运行 Windows 程序）', 'zabbix': '著名的网络监视、管理系统'
	};

	var vmMirList = new Vue({
		el: "#mirror-list",
		data: {
			test: "hello",
			mirrorList: []
		},
		created: function created() {
			this.refreshMirrorList();
		},
		updated: function updated() {
			$('.mirror-item-label').popover();
		},
		computed: {
			nowBrowsingMirror: function nowBrowsingMirror() {
				var mirrorName = location.pathname.split('/')[1];
				if (!mirrorName) {
					return false;
				}
				mirrorName = mirrorName.toLowerCase();
				var result = this.mirrorList.filter(function (m) {
					return m.name.toLowerCase() === mirrorName;
				})[0];
				if (!result) {
					return false;
				}
				return result;
			}
		},
		methods: {
			getURL: function getURL(mir) {
				if (mir.url !== undefined) {
					return mir.url;
				}
				return "/" + mir.name + "/";
			},
			refreshMirrorList: function refreshMirrorList() {
				var self = this;
				$.getJSON("static/tunasync.json", function (status_data) {
					var mirrors = [],
					    mir_data = $.merge(status_data, unlisted);
					var mir_uniq = {}; // for deduplication

					mir_data.sort(function (a, b) {
						return a.name < b.name ? -1 : 1;
					});

					for (var k in mir_data) {
						var d = mir_data[k];
						if (d.status == "disabled") {
							continue;
						}
						if (options[d.name] != undefined) {
							d = $.extend(d, options[d.name]);
						}
						d.label = label_map[d.status];
						d.help_url = help_url[d.name];
						d.is_new = new_mirrors[d.name];
						d.description = descriptions[d.name];
						d.show_status = d.status != "success";
						if (d.is_master === undefined) {
							d.is_master = true;
						}
						// Strip the second component of last_update
						if (d.last_update_ts) {
							var date = new Date(d.last_update_ts * 1000);
							if (date.getFullYear() > 2000) {
								d.last_update = ('000' + date.getFullYear()).substr(-4) + "-" + ('0' + (date.getMonth() + 1)).substr(-2) + "-" + ('0' + date.getDate()).substr(-2) + (" " + ('0' + date.getHours()).substr(-2) + ":" + ('0' + date.getMinutes()).substr(-2));
							} else {
								d.last_update = "0000-00-00 00:00";
							}
						} else {
							d.last_update = d.last_update.replace(/(\d\d:\d\d):\d\d(\s\+\d\d\d\d)?/, '$1');
						}
						if (d.name in mir_uniq) {
							var other = mir_uniq[d.name];
							if (other.last_update > d.last_update) {
								continue;
							}
						}
						mir_uniq[d.name] = d;
					}
					for (k in mir_uniq) {
						mirrors.push(mir_uniq[k]);
					}
					self.mirrorList = mirrors;
					setTimeout(function () {
						self.refreshMirrorList();
					}, 10000);
				});
			}
		}
	});

	var vmIso = new Vue({
		el: "#isoModal",
		data: {
			distroList: [],
			selected: {},
			curCategory: "os"
		},
		created: function created() {
			var self = this;
			$.getJSON("static/status/isoinfo.json", function (isoinfo) {
				self.distroList = isoinfo;
				self.selected = self.curDistroList[0];
				if (window.location.hash.match(/#iso-download(\?.*)?/)) {
					$('#isoModal').modal();
				}
			});
		},
		computed: {
			curDistroList: function curDistroList() {
				var _this = this;

				return this.distroList.filter(function (x) {
					return x.category === _this.curCategory;
				});
			}
		},
		methods: {
			switchDistro: function switchDistro(distro) {
				this.selected = distro;
			},
			switchCategory: function switchCategory(category) {
				this.curCategory = category;
				this.selected = this.curDistroList[0];
			}
		}
	});
});

// vim: ts=2 sts=2 sw=2 noexpandtab